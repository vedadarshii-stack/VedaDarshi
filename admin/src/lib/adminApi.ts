import { getFunctions, httpsCallable } from 'firebase/functions';

import { firebaseApp } from './firebase';

/**
 * Typed wrappers over the console's Cloud Function callables
 * (`functions/src/adminApi.ts`).
 *
 * BUILT 9 Sep 2026 — before this the console had no server-side capability
 * at all: every screen fell back to `src/data/mock.ts`, and Users showed a
 * permanent "denied" banner because the security rules refuse `list` on
 * `/users` (deliberately, since those documents carry birth details).
 *
 * ⚠️ **Region matters.** All functions are deployed to `asia-south1`. The
 * default `getFunctions(app)` targets `us-central1` and would fail with a
 * CORS error that looks like a permissions problem — an easy hour to lose.
 */
const functions = getFunctions(firebaseApp, 'asia-south1');

/** Shape returned by `adminVedikaUsage`. */
export interface VedikaUsage {
  wallet: {
    balance?: number;
    balanceUnit?: string;
    balanceUsd?: string;
    currency?: string;
  } | null;
  summary: {
    data?: {
      totalCost?: string;
      totalQueries?: number;
      averageCostPerQuery?: string;
      currency?: string;
      byService?: Record<string, { cost?: string; queries?: number }>;
      dateRange?: { start?: string; end?: string };
      truncated?: boolean;
      scanLimit?: number;
    };
  } | null;
  fetchedAtMs: number;
}

export interface AdminUserRow {
  uid: string;
  displayName: string | null;
  email: string | null;
  photoUrl: string | null;
  providers: string[];
  locale: string | null;
  createdAt: number | null;
  updatedAt: number | null;
  tier: string;
}

export interface AdminUsersPage {
  users: AdminUserRow[];
  nextCursor: string | null;
}

export type NotificationTarget = 'all' | 'locale' | 'token';

export interface SendNotificationInput {
  title: string;
  body: string;
  target: NotificationTarget;
  locale?: string;
  token?: string;
  route?: string;
}

export function fetchVedikaUsage(): Promise<VedikaUsage> {
  return httpsCallable<void, VedikaUsage>(
    functions,
    'adminVedikaUsage',
  )().then((r) => r.data);
}

export function fetchUsers(params?: {
  limit?: number;
  startAfter?: string | null;
}): Promise<AdminUsersPage> {
  return httpsCallable<typeof params, AdminUsersPage>(
    functions,
    'adminListUsers',
  )(params).then((r) => r.data);
}

export function sendNotification(
  input: SendNotificationInput,
): Promise<{ messageId: string; destination: string }> {
  return httpsCallable<SendNotificationInput, { messageId: string; destination: string }>(
    functions,
    'adminSendNotification',
  )(input).then((r) => r.data);
}

/**
 * Turns a callable failure into console copy.
 *
 * The server distinguishes "not signed in", "not an admin" and "missing
 * permission" on purpose — collapsing them into "something went wrong" would
 * make a revoked admin look like a broken console.
 */
export function callableErrorMessage(error: unknown): string {
  const code = (error as { code?: string } | null)?.code ?? '';
  const message = (error as { message?: string } | null)?.message ?? '';
  if (code.includes('unauthenticated')) return 'Your session expired — sign in again.';
  if (code.includes('permission-denied')) {
    return message || 'Your role does not allow this.';
  }
  if (code.includes('invalid-argument')) return message || 'Check the fields and try again.';
  if (code.includes('unavailable') || code.includes('deadline')) {
    return 'Could not reach the server. Check your connection and retry.';
  }
  return message || 'Something went wrong.';
}

export interface DashboardStats {
  totalUsers: number | null;
  paidSubscribers: number | null;
  sandboxEntitlements: number | null;
  vedikaBalanceUsd: string | null;
  vedikaQueries: number | null;
  vedikaSpendUsd: string | null;
  activeSubscriptions: number | null;
  revenue28d: string | null;
  fetchedAtMs: number;
}

export function fetchDashboardStats(): Promise<DashboardStats> {
  return httpsCallable<void, DashboardStats>(
    functions,
    'adminDashboardStats',
  )().then((r) => r.data);
}

export interface PlanPeriod {
  id: string;
  state: string | null;
  billingPeriod: string | null;
  prices: { region: string; amount: number; currency: string | null }[];
}

export interface PlansData {
  plans: {
    productId: string | null;
    storeIdentifier: string | null;
    displayName: string | null;
    storeStatus: string | null;
    periods: PlanPeriod[];
  }[];
  oneTime: {
    productId: string | null;
    storeIdentifier: string | null;
    displayName: string | null;
  }[];
  fetchedAtMs: number;
}

export function fetchPlans(): Promise<PlansData> {
  return httpsCallable<void, PlansData>(functions, 'adminPlans')().then(
    (r) => r.data,
  );
}
