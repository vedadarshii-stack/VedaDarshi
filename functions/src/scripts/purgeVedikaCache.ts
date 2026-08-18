import * as admin from "firebase-admin";

/**
 * WHY THIS SCRIPT EXISTS.
 *
 * Every function that talks to Vedika (the live `vedika` proxy in
 * ../index.ts, and the scheduled ../dailyPrewarm.ts) has, up to now, only
 * ever been able to reach Vedika's FREE SANDBOX — there is no paid key yet
 * (see VEDIKA_BASE_URL in ../config.ts). The sandbox does not compute
 * anything from the request you send it: it serves ONE fixed sample chart
 * (a stranger's kundli, Delhi, 1995-01-01) to every caller regardless of
 * birth details, sign or city. Every document these functions have written
 * to `vedikaCache`, `dailyHoroscopes` and `dailyPanchang` is therefore
 * fake sample data wearing the shape of a real response.
 *
 * That would be a harmless throwaway if the cache were short-lived. It is
 * not: `cacheTtlSeconds()` in ../index.ts caches kundli and guna-milan
 * responses for up to ONE YEAR, because a natal chart never changes for the
 * same inputs — a reasonable optimization once the data is real, and a
 * landmine while it is sandbox junk. The moment `VEDIKA_BASE_URL` is
 * switched to production and a real `VEDIKA_API_KEY` is set, the proxy
 * would keep serving the pre-cutover sandbox data as a cache HIT (see the
 * `X-Vedika-Cache: HIT` path in ../index.ts) for as long as a year, with no
 * visible failure — it would just be silently, confidently wrong. The same
 * applies to the pre-warmed `dailyHoroscopes`/`dailyPanchang` documents:
 * they would keep being read by the app in preference to a fresh call,
 * because their existence is exactly what the pre-warm job is designed to
 * make Firestore-reads prefer.
 *
 * So purging these three collections has to be a deliberate step in the
 * go-live cutover — done once, right after `VEDIKA_BASE_URL` and
 * `VEDIKA_API_KEY` are updated to production, so the very next request for
 * any given kundli/guna-milan/horoscope/panchang is forced to hit the real
 * API and repopulate the cache with real data.
 *
 * HOW TO RUN.
 *
 *   npm --prefix functions run purge-cache -- --project=vedadarshi-20989
 *
 * With no flags this is a DRY RUN: it counts and prints what it would
 * delete, and deletes nothing. Add `--yes` to actually delete:
 *
 *   npm --prefix functions run purge-cache -- --project=vedadarshi-20989 --yes
 *
 * To purge only some of the three collections, pass `--only` (repeatable,
 * or comma-separated):
 *
 *   npm --prefix functions run purge-cache -- --only=vedikaCache --yes
 *   npm --prefix functions run purge-cache -- --only=dailyHoroscopes,dailyPanchang --yes
 *
 * Auth is Application Default Credentials (`gcloud auth application-default
 * login`, or a service account via `GOOGLE_APPLICATION_CREDENTIALS`) — the
 * same mechanism the Firebase CLI itself relies on, not a key baked into
 * this repo.
 *
 * ⚠️ THIS IS IRREVERSIBLE. There is no undo, no soft-delete, no trash can —
 * a document deleted here is gone. Always run without `--yes` first, read
 * the counts, and only then re-run with `--yes` once they look right.
 */

/**
 * The exact set of collections that can hold Vedika sandbox data — see
 * ../index.ts (`vedikaCache`) and ../dailyPrewarm.ts (`dailyHoroscopes`,
 * `dailyPanchang`) for where each one is written. Kept as ONE exported
 * array, rather than scattered through this file, so "what does this
 * script touch" is answerable with a single grep for
 * `PURGEABLE_COLLECTIONS` instead of reading the whole script.
 */
export const PURGEABLE_COLLECTIONS = ["vedikaCache", "dailyHoroscopes", "dailyPanchang"] as const;

type PurgeableCollection = (typeof PURGEABLE_COLLECTIONS)[number];

/**
 * Firestore hard-caps a single WriteBatch at 500 operations, so a
 * collection of any real size has to be paged and deleted a batch at a
 * time rather than loaded into memory and deleted in one shot.
 */
const BATCH_SIZE = 500;

interface ParsedArgs {
  project?: string;
  yes: boolean;
  only: string[] | null;
}

function parseArgs(argv: string[]): ParsedArgs {
  let project: string | undefined;
  let yes = false;
  const only: string[] = [];

  for (const arg of argv) {
    if (arg === "--yes") {
      yes = true;
    } else if (arg.startsWith("--project=")) {
      project = arg.slice("--project=".length);
    } else if (arg.startsWith("--only=")) {
      only.push(...arg.slice("--only=".length).split(","));
    }
  }

  return { project, yes, only: only.length > 0 ? only : null };
}

/**
 * Uses a Firestore COUNT aggregation query rather than reading every
 * document, so even a very large collection can be sized up cheaply — this
 * is the number shown in the dry-run report, and it deliberately never
 * loads a single document's contents into memory.
 */
async function countDocuments(db: admin.firestore.Firestore, collection: string): Promise<number> {
  const snapshot = await db.collection(collection).count().get();
  return snapshot.data().count;
}

/**
 * Deletes every document in `collection`, one page of at most
 * `BATCH_SIZE` at a time. Re-querying `.limit(BATCH_SIZE)` after each
 * commit (rather than reading a cursor up front) is what keeps this from
 * ever holding the whole collection in memory: each iteration only ever
 * touches the documents still left to delete.
 */
async function deleteAllDocuments(db: admin.firestore.Firestore, collection: string): Promise<number> {
  let deleted = 0;

  for (;;) {
    const snapshot = await db.collection(collection).limit(BATCH_SIZE).get();
    if (snapshot.empty) {
      return deleted;
    }

    const batch = db.batch();
    for (const doc of snapshot.docs) {
      batch.delete(doc.ref);
    }
    await batch.commit();
    deleted += snapshot.size;
  }
}

interface PurgeSummary {
  collection: string;
  matched: number;
  deleted: number;
}

function isPurgeableCollection(name: string): name is PurgeableCollection {
  return (PURGEABLE_COLLECTIONS as readonly string[]).includes(name);
}

async function main(): Promise<void> {
  const { project, yes, only } = parseArgs(process.argv.slice(2));

  const targets: string[] = only ?? [...PURGEABLE_COLLECTIONS];
  for (const name of targets) {
    if (!isPurgeableCollection(name)) {
      throw new Error(
        `Unknown collection "${name}" passed to --only. Valid values: ${PURGEABLE_COLLECTIONS.join(", ")}`
      );
    }
  }

  // Defaulting to the client's own project id (see ../../../CLAUDE.md) means
  // a bare `--yes` run against no flags still does the right thing in this
  // repo's normal working context, while `--project=` / the env vars still
  // let it target a different project (e.g. a staging Firebase project)
  // without editing this file.
  const projectId = project ?? process.env.GCLOUD_PROJECT ?? process.env.FIREBASE_PROJECT ?? "vedadarshi-20989";

  admin.initializeApp({ projectId });
  const db = admin.firestore();

  console.log(`Vedika cache purge — project "${projectId}"${yes ? "" : " (DRY RUN)"}`);
  console.log(`Collections: ${targets.join(", ")}`);
  console.log("");

  const summaries: PurgeSummary[] = [];

  for (const collection of targets) {
    const matched = await countDocuments(db, collection);

    if (!yes) {
      summaries.push({ collection, matched, deleted: 0 });
      console.log(`  ${collection}: ${matched} document(s) would be deleted`);
      continue;
    }

    const deleted = await deleteAllDocuments(db, collection);
    summaries.push({ collection, matched, deleted });
    console.log(`  ${collection}: deleted ${deleted} document(s)`);
  }

  const totalMatched = summaries.reduce((sum, s) => sum + s.matched, 0);
  const totalDeleted = summaries.reduce((sum, s) => sum + s.deleted, 0);

  console.log("");
  if (!yes) {
    console.log(
      `DRY RUN — NOTHING WAS DELETED. ${totalMatched} document(s) across ` +
        `${targets.length} collection(s) would be purged. Re-run with --yes ` +
        `to actually delete them — this cannot be undone.`
    );
  } else {
    console.log(`Deleted ${totalDeleted} document(s) across ${targets.length} collection(s).`);
  }
}

main().catch((e) => {
  console.error("purgeVedikaCache failed:", e);
  process.exitCode = 1;
});
