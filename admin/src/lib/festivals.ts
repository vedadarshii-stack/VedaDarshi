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

/** Festival calendar CMS, the second collection behind the Quotes & Festivals
 *  tab switcher. Same direct-Firestore approach as `articles.ts`/`quotes.ts`. */
export { LOCALE_CODES, LOCALE_LABELS };
export type { LocaleCode };

export type LocalizedText = Partial<Record<LocaleCode, string>>;
export type FestivalStatus = 'draft' | 'published';

export interface Festival {
  id: string;
  name: LocalizedText;
  description: LocalizedText;
  /** 'YYYY-MM-DD' */
  date: string;
  status: FestivalStatus;
  createdAt: Timestamp | null;
  updatedAt: Timestamp | null;
}

export type FestivalDraft = {
  name: LocalizedText;
  description: LocalizedText;
  date: string;
};

const festivalsRef = collection(db, 'festivals');

export async function listFestivals(): Promise<Festival[]> {
  // Ordered by the festival's own date, not last-edited — an editorial list
  // of upcoming festivals is far more useful sorted chronologically.
  const snap = await getDocs(query(festivalsRef, orderBy('date', 'asc')));
  return snap.docs.map((d) => ({ id: d.id, ...(d.data() as Omit<Festival, 'id'>) }));
}

export async function createFestival(input: FestivalDraft): Promise<string> {
  const ref = await addDoc(festivalsRef, {
    ...input,
    status: 'draft' satisfies FestivalStatus,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
  return ref.id;
}

export async function updateFestival(
  id: string,
  patch: Partial<Omit<Festival, 'id'>>,
): Promise<void> {
  await updateDoc(doc(db, 'festivals', id), { ...patch, updatedAt: serverTimestamp() });
}

export async function setFestivalPublished(
  festival: Festival,
  published: boolean,
): Promise<void> {
  await updateFestival(festival.id, { status: published ? 'published' : 'draft' });
}

export async function removeFestival(id: string): Promise<void> {
  await deleteDoc(doc(db, 'festivals', id));
}
