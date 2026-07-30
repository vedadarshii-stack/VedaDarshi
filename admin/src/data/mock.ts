/** Static content for the click-through concept.
 *  Every value here is the placeholder copy from the Figma admin screens.
 *  Replace with Firestore-backed queries when the CMS is wired up (milestone 4). */

export type Tone = 'saffron' | 'gold' | 'purple' | 'green' | 'blue' | 'rose' | 'neutral';

/* ---------- E2 · Dashboard ---------- */

export type StatCard = {
  label: string;
  value: string;
  delta: string;
  icon: string;
  tone: Tone;
};

export const DASHBOARD_STATS: StatCard[] = [
  { label: 'Total Users', value: '48,320', delta: '▲ 12.4% this month', icon: '👥', tone: 'saffron' },
  { label: 'Active Subscriptions', value: '6,905', delta: '▲ 8.1% this month', icon: '👑', tone: 'gold' },
  { label: 'AI Questions Today', value: '12,441', delta: '▲ 3.2% vs yesterday', icon: '🔮', tone: 'purple' },
  { label: 'Revenue (July)', value: '₹11.4L', delta: '▲ 15.8% MoM', icon: '💰', tone: 'green' },
];

/** Bar heights are the literal Figma pixel values (nodes 31:93 – 31:119). */
export type ChartColumn = { month: string; users: number; revenue: number };

export const GROWTH_CHART: ChartColumn[] = [
  { month: 'Feb', users: 90, revenue: 60 },
  { month: 'Mar', users: 120, revenue: 75 },
  { month: 'Apr', users: 150, revenue: 95 },
  { month: 'May', users: 135, revenue: 110 },
  { month: 'Jun', users: 190, revenue: 140 },
  { month: 'Jul', users: 230, revenue: 170 },
];

export type ContentStatus = {
  icon: string;
  tone: 'ok' | 'warn' | 'pending' | 'scheduled';
  title: string;
  detail: string;
};

export const TODAYS_CONTENT: ContentStatus[] = [
  { icon: '✓', tone: 'ok', title: 'Daily horoscope', detail: 'Published · 5 languages' },
  { icon: '✓', tone: 'ok', title: 'Panchang data', detail: 'Synced 6:00 AM' },
  { icon: '⚠', tone: 'warn', title: 'Quote of the day', detail: 'Missing Telugu translation' },
  { icon: '◔', tone: 'pending', title: 'Festival banner', detail: 'Draft — Sawan Somvar' },
  { icon: '◷', tone: 'scheduled', title: 'Push notification', detail: 'Scheduled 7:00 PM' },
];

/* ---------- E3 · Users ---------- */

export type PlanBadge = { text: string; premium: boolean };

export type UserRow = {
  name: string;
  initial: string;
  tone: Tone;
  contact: string;
  joined: string;
  plan: PlanBadge;
  lastActive: string;
  language: string;
};

export const USERS: UserRow[] = [
  {
    name: 'Nagarjuna V',
    initial: 'N',
    tone: 'saffron',
    contact: '+91 98••• ••210',
    joined: '12 Jan 2026',
    plan: { text: 'Premium · Yearly', premium: true },
    lastActive: '2 min ago',
    language: 'Telugu',
  },
  {
    name: 'Ananya Iyer',
    initial: 'A',
    tone: 'blue',
    contact: 'ananya@gmail.com',
    joined: '03 Feb 2026',
    plan: { text: 'Premium · Monthly', premium: true },
    lastActive: '1 hr ago',
    language: 'Tamil',
  },
  {
    name: 'Rahul Mehta',
    initial: 'R',
    tone: 'purple',
    contact: '+91 88••• ••914',
    joined: '22 Mar 2026',
    plan: { text: 'Free', premium: false },
    lastActive: 'Yesterday',
    language: 'Hindi',
  },
  {
    name: 'Divya K',
    initial: 'D',
    tone: 'green',
    contact: 'divya.k@yahoo.in',
    joined: '28 Mar 2026',
    plan: { text: 'Free', premium: false },
    lastActive: '3 days ago',
    language: 'Kannada',
  },
  {
    name: 'Suresh Rao',
    initial: 'S',
    tone: 'rose',
    contact: '+91 96••• ••482',
    joined: '04 Apr 2026',
    plan: { text: 'Premium · Lifetime', premium: true },
    lastActive: '5 min ago',
    language: 'English',
  },
  {
    name: 'Meera Nair',
    initial: 'M',
    tone: 'saffron',
    contact: 'meera.n@gmail.com',
    joined: '19 May 2026',
    plan: { text: 'Free', premium: false },
    lastActive: '1 week ago',
    language: 'Hindi',
  },
];

export const USER_FILTERS = ['Plan: All', 'Status: Active', 'Language: All'];

/* ---------- E4 · Articles ---------- */

export const LOCALES = ['EN', 'HI', 'TE', 'TA', 'KN'] as const;
export type LocaleCode = (typeof LOCALES)[number];

export type ArticleStatus = 'Published' | 'Scheduled' | 'Draft';

export type ArticleRow = {
  title: string;
  meta: string;
  /** Thumbnail gradient start; the concept fades each one into navy. */
  thumbFrom: string;
  translated: LocaleCode[];
  status: ArticleStatus;
};

export const ARTICLES: ArticleRow[] = [
  {
    title: 'Sawan Somvar: fasting rules, rituals & significance',
    meta: 'Festivals · 12 Jul 2026',
    thumbFrom: '#22315e',
    translated: ['EN', 'HI', 'TE', 'TA', 'KN'],
    status: 'Published',
  },
  {
    title: 'Ganesha Chaturthi 2026: dates & muhurat',
    meta: 'Festivals · 20 Jul 2026',
    thumbFrom: '#7a3e12',
    translated: ['EN', 'HI'],
    status: 'Scheduled',
  },
  {
    title: 'Understanding your Moon sign',
    meta: 'Basics · 08 Jul 2026',
    thumbFrom: '#1f3c88',
    translated: ['EN', 'HI', 'TE', 'TA'],
    status: 'Published',
  },
  {
    title: '5 mantras for peaceful sleep',
    meta: 'Mantras · 05 Jul 2026',
    thumbFrom: '#6b3fa0',
    translated: ['EN', 'HI', 'TE', 'TA', 'KN'],
    status: 'Published',
  },
  {
    title: 'Vastu tips for your work-from-home desk',
    meta: 'Vastu · —',
    thumbFrom: '#2e9e6b',
    translated: ['EN'],
    status: 'Draft',
  },
];

export const ARTICLE_TABS = ['All (142)', 'Published', 'Drafts', 'Scheduled', 'Needs translation ⚠'];

/* ---------- E5 · Notification composer ---------- */

export type TranslationChip = { label: string; font: string; ready: boolean };

export const NOTIFICATION_TRANSLATIONS: TranslationChip[] = [
  { label: 'English', font: 'var(--vd-font-ui)', ready: true },
  { label: 'हिन्दी', font: 'var(--vd-font-deva)', ready: true },
  { label: 'తెలుగు', font: 'var(--vd-font-telu)', ready: true },
  { label: 'தமிழ்', font: 'var(--vd-font-tamil)', ready: false },
  { label: 'ಕನ್ನಡ', font: 'var(--vd-font-kannada)', ready: false },
];

/* ---------- E6 · Plans & Billing ---------- */

export type Plan = {
  name: string;
  price: string;
  period: string;
  subscribers: string;
  productId: string;
  featured: boolean;
  badge?: string;
};

export const PLANS: Plan[] = [
  {
    name: 'Monthly',
    price: '₹299',
    period: '/month',
    subscribers: '1,204 active subscribers',
    productId: 'vd_premium_monthly',
    featured: false,
  },
  {
    name: 'Yearly',
    price: '₹1,999',
    period: '/year',
    subscribers: '5,312 active subscribers',
    productId: 'vd_premium_yearly',
    featured: true,
    badge: 'BEST SELLER',
  },
  {
    name: 'Lifetime',
    price: '₹4,999',
    period: 'one-time',
    subscribers: '389 lifetime members',
    productId: 'vd_premium_lifetime',
    featured: false,
  },
];

export type FeatureGate = { feature: string; free: string; premium: string };

export const FEATURE_GATES: FeatureGate[] = [
  { feature: 'AI Astrologer questions', free: '3 / day', premium: 'Unlimited' },
  { feature: 'Premium reports (9 types)', free: 'Locked', premium: 'All included + PDF' },
  { feature: 'Kundli charts', free: 'Basic chart', premium: 'Dasha, dosha & remedies' },
  { feature: 'Ads', free: 'Banner ads', premium: 'Ad-free' },
];
