import { doc, getDoc, serverTimestamp, setDoc, type Timestamp } from 'firebase/firestore';

import { db } from './firebase';
import { LOCALE_CODES, LOCALE_LABELS, type LocaleCode } from './articles';

/**
 * Muhurat content CMS — `muhuratContent/{kind}`, where `kind` is one of a
 * FIXED set of 12 ids. Unlike Articles/Banners/Quotes/Festivals, this is not
 * an open collection an editor adds rows to: the app's astrology engine only
 * ever asks for these 12 windows, so the console must render exactly these
 * 12 editable rows, no more and no fewer, and must not offer a way to create
 * an arbitrary 13th one.
 */
export { LOCALE_CODES, LOCALE_LABELS };
export type { LocaleCode };

export type LocalizedText = Partial<Record<LocaleCode, string>>;
export type MuhuratStatus = 'draft' | 'published';

export const MUHURAT_KINDS = [
  'rahuKaal',
  'yamaganda',
  'gulika',
  'abhijit',
  'brahmaMuhurta',
  'choghadiyaKaal',
  'choghadiyaShubh',
  'choghadiyaRog',
  'choghadiyaUdveg',
  'choghadiyaChar',
  'choghadiyaLabh',
  'choghadiyaAmrit',
] as const;
export type MuhuratKind = (typeof MUHURAT_KINDS)[number];

export const MUHURAT_LABELS: Record<MuhuratKind, string> = {
  rahuKaal: 'Rahu Kaal',
  yamaganda: 'Yamaganda',
  gulika: 'Gulika',
  abhijit: 'Abhijit',
  brahmaMuhurta: 'Brahma Muhurta',
  choghadiyaKaal: 'Choghadiya — Kaal',
  choghadiyaShubh: 'Choghadiya — Shubh',
  choghadiyaRog: 'Choghadiya — Rog',
  choghadiyaUdveg: 'Choghadiya — Udveg',
  choghadiyaChar: 'Choghadiya — Char',
  choghadiyaLabh: 'Choghadiya — Labh',
  choghadiyaAmrit: 'Choghadiya — Amrit',
};

export interface MuhuratContent {
  kind: MuhuratKind;
  description: LocalizedText;
  status: MuhuratStatus;
  updatedAt: Timestamp | null;
}

const muhuratDocRef = (kind: MuhuratKind) => doc(db, 'muhuratContent', kind);

/** A kind with no document yet comes back as `null` — the caller renders that
 *  as an empty, fully-editable row rather than an error or a missing row. */
export async function listMuhuratContent(): Promise<
  Record<MuhuratKind, MuhuratContent | null>
> {
  // Read each of the 12 known docs individually rather than scanning the
  // collection — a collection scan would also surface any stray doc someone
  // created by hand with an unrecognised id, which this screen must never
  // render (see the file comment above).
  const snaps = await Promise.all(MUHURAT_KINDS.map((kind) => getDoc(muhuratDocRef(kind))));
  const result = {} as Record<MuhuratKind, MuhuratContent | null>;
  MUHURAT_KINDS.forEach((kind, index) => {
    const snap = snaps[index];
    result[kind] = snap.exists()
      ? { kind, ...(snap.data() as Omit<MuhuratContent, 'kind'>) }
      : null;
  });
  return result;
}

export async function saveMuhuratContent(
  kind: MuhuratKind,
  patch: { description: LocalizedText; status: MuhuratStatus },
): Promise<void> {
  // `setDoc` with merge, not `updateDoc` — a kind with no document yet has
  // nothing to update, and the doc id itself (the kind) never needs writing
  // since it is not a field.
  await setDoc(muhuratDocRef(kind), { ...patch, updatedAt: serverTimestamp() }, { merge: true });
}
