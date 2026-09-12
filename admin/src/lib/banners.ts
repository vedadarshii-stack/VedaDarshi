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
import { LOCALE_CODES, LOCALE_LABELS, type LocaleCode } from './articles';

/**
 * Home-screen banner carousel CMS.
 *
 * Locale vocabulary (`LOCALE_CODES`/`LOCALE_LABELS`) is re-exported from
 * `articles.ts` rather than redefined — one place decides which five
 * languages the console edits, so the two can never drift apart.
 *
 * Writes go straight to Firestore, same reasoning as `articles.ts`: banners
 * are editorial content with nothing to hide, unlike `/users`.
 */
export { LOCALE_CODES, LOCALE_LABELS };
export type { LocaleCode };

export type LocalizedText = Partial<Record<LocaleCode, string>>;

export const CTA_TARGETS = ['paywall', 'store', 'reports', 'articles', 'none'] as const;
export type BannerCtaTarget = (typeof CTA_TARGETS)[number];

export type BannerStatus = 'draft' | 'published';

export interface Banner {
  id: string;
  title: LocalizedText;
  subtitle: LocalizedText;
  emoji: string;
  ctaLabel: LocalizedText;
  ctaTarget: BannerCtaTarget;
  status: BannerStatus;
  sortOrder: number;
  /** 'YYYY-MM-DD', or null for "no start/end limit". */
  startsAt: string | null;
  endsAt: string | null;
  createdAt: Timestamp | null;
  updatedAt: Timestamp | null;
}

export type BannerDraft = {
  title: LocalizedText;
  subtitle: LocalizedText;
  emoji: string;
  ctaLabel: LocalizedText;
  ctaTarget: BannerCtaTarget;
  sortOrder: number;
  startsAt: string | null;
  endsAt: string | null;
};

const bannersRef = collection(db, 'banners');

export async function listBanners(): Promise<Banner[]> {
  // Ordered by sortOrder, not recency — this drives a carousel, so display
  // order is an editorial decision the console must show and let you change,
  // unlike Articles where "last touched first" is the useful order.
  const snap = await getDocs(query(bannersRef, orderBy('sortOrder', 'asc')));
  return snap.docs.map((d) => ({ id: d.id, ...(d.data() as Omit<Banner, 'id'>) }));
}

export async function createBanner(input: BannerDraft): Promise<string> {
  const ref = await addDoc(bannersRef, {
    ...input,
    // Always created as a draft — publishing is a deliberate second step,
    // same convention as Articles.
    status: 'draft' satisfies BannerStatus,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
  return ref.id;
}

export async function updateBanner(
  id: string,
  patch: Partial<Omit<Banner, 'id'>>,
): Promise<void> {
  await updateDoc(doc(db, 'banners', id), { ...patch, updatedAt: serverTimestamp() });
}

export async function setBannerPublished(banner: Banner, published: boolean): Promise<void> {
  await updateBanner(banner.id, { status: published ? 'published' : 'draft' });
}

export async function removeBanner(id: string): Promise<void> {
  await deleteDoc(doc(db, 'banners', id));
}
