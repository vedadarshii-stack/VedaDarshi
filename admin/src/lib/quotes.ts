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

/** Daily-quote CMS. Same direct-Firestore approach as `articles.ts` — quotes
 *  carry nothing personal, so the console writes them straight through. */
export { LOCALE_CODES, LOCALE_LABELS };
export type { LocaleCode };

export type LocalizedText = Partial<Record<LocaleCode, string>>;
export type QuoteStatus = 'draft' | 'published';

export interface Quote {
  id: string;
  text: LocalizedText;
  author: string;
  status: QuoteStatus;
  createdAt: Timestamp | null;
  updatedAt: Timestamp | null;
}

export type QuoteDraft = {
  text: LocalizedText;
  author: string;
};

const quotesRef = collection(db, 'quotes');

export async function listQuotes(): Promise<Quote[]> {
  const snap = await getDocs(query(quotesRef, orderBy('updatedAt', 'desc')));
  return snap.docs.map((d) => ({ id: d.id, ...(d.data() as Omit<Quote, 'id'>) }));
}

export async function createQuote(input: QuoteDraft): Promise<string> {
  const ref = await addDoc(quotesRef, {
    ...input,
    status: 'draft' satisfies QuoteStatus,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
  return ref.id;
}

export async function updateQuote(id: string, patch: Partial<Omit<Quote, 'id'>>): Promise<void> {
  await updateDoc(doc(db, 'quotes', id), { ...patch, updatedAt: serverTimestamp() });
}

export async function setQuotePublished(quote: Quote, published: boolean): Promise<void> {
  await updateQuote(quote.id, { status: published ? 'published' : 'draft' });
}

export async function removeQuote(id: string): Promise<void> {
  await deleteDoc(doc(db, 'quotes', id));
}
