import {
  addDoc,
  collection,
  deleteDoc,
  doc,
  getDocs,
  orderBy,
  query,
  serverTimestamp,
  updateDoc,
  type Timestamp,
} from 'firebase/firestore';

import { db } from './firebase';

/**
 * The Articles CMS data layer.
 *
 * BUILT 10 Sep 2026. The console's Articles screen had been reading an empty
 * `articles` collection, failing, and silently falling back to six invented
 * articles from `mock.ts` — presented as if they were the real catalogue,
 * with a header claiming "142 total · 8 drafts · 3 scheduled".
 *
 * ## Why this writes Firestore directly, unlike Users
 *
 * `/users` needs a Cloud Function because the rules refuse `list` — those
 * documents hold birth details. Articles are editorial content with nothing
 * to hide, so the rules allow admin writes directly and a plain client SDK
 * call is simpler and cheaper than a callable round trip.
 *
 * ## The five-language shape is not optional
 *
 * `projects/CLAUDE.md` requires CMS content to carry per-language fields with
 * an English fallback. So `title` and `body` are maps keyed by locale rather
 * than plain strings — retrofitting that later would mean migrating every
 * document written in the meantime.
 */

export const LOCALE_CODES = ['en', 'hi', 'te', 'ta', 'kn'] as const;
export type LocaleCode = (typeof LOCALE_CODES)[number];

export const LOCALE_LABELS: Record<LocaleCode, string> = {
  en: 'English',
  hi: 'हिन्दी',
  te: 'తెలుగు',
  ta: 'தமிழ்',
  kn: 'ಕನ್ನಡ',
};

/** Mirrors `ArticleCategoryId` in the app's `articles_static_data.dart`. */
export const CATEGORIES = [
  'festivals',
  'remedies',
  'planets',
  'rituals',
  'numerology',
  'gemstones',
] as const;
export type CategoryId = (typeof CATEGORIES)[number];

export type ArticleStatus = 'draft' | 'published';

export interface Article {
  id: string;
  status: ArticleStatus;
  categoryId: CategoryId;
  author: string;
  readMinutes: number;
  isFeatured: boolean;
  /** Locale → title. `en` is required; the app falls back to it. */
  title: Partial<Record<LocaleCode, string>>;
  /** Locale → body. Blank-line-separated paragraphs. */
  body: Partial<Record<LocaleCode, string>>;
  publishedAt: Timestamp | null;
  updatedAt: Timestamp | null;
}

const articlesRef = collection(db, 'articles');

export async function listArticles(): Promise<Article[]> {
  // Ordered by last edit, so an editor's work-in-progress is at the top
  // rather than buried under whatever was published longest ago.
  const snap = await getDocs(query(articlesRef, orderBy('updatedAt', 'desc')));
  return snap.docs.map((d) => ({ id: d.id, ...(d.data() as Omit<Article, 'id'>) }));
}

export async function createArticle(input: {
  title: Partial<Record<LocaleCode, string>>;
  body: Partial<Record<LocaleCode, string>>;
  categoryId: CategoryId;
  author: string;
  readMinutes: number;
  isFeatured: boolean;
}): Promise<string> {
  const ref = await addDoc(articlesRef, {
    ...input,
    // ⚠️ Always created as a DRAFT, never published on create. Publishing is
    // a separate, deliberate action — one stray Enter in a form should not
    // put half-written content in front of users.
    status: 'draft' satisfies ArticleStatus,
    publishedAt: null,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
  return ref.id;
}

export async function updateArticle(
  id: string,
  patch: Partial<Omit<Article, 'id'>>,
): Promise<void> {
  await updateDoc(doc(db, 'articles', id), {
    ...patch,
    updatedAt: serverTimestamp(),
  });
}

/**
 * Publish or unpublish.
 *
 * `publishedAt` is stamped on the FIRST publish and left alone afterwards, so
 * re-publishing an edited article does not make it look brand new and jump to
 * the top of the app's list.
 */
export async function setPublished(
  article: Article,
  published: boolean,
): Promise<void> {
  await updateArticle(article.id, {
    status: published ? 'published' : 'draft',
    ...(published && !article.publishedAt
      ? { publishedAt: serverTimestamp() as unknown as Timestamp }
      : {}),
  });
}

export async function removeArticle(id: string): Promise<void> {
  await deleteDoc(doc(db, 'articles', id));
}

/** Locales with a non-empty title AND body — what the app can actually show. */
export function translatedLocales(article: Article): LocaleCode[] {
  return LOCALE_CODES.filter(
    (code) => (article.title[code] ?? '').trim() && (article.body[code] ?? '').trim(),
  );
}
