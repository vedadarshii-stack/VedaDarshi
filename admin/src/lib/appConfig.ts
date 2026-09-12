import { doc, getDoc, serverTimestamp, setDoc, type Timestamp } from 'firebase/firestore';

import { db } from './firebase';
import { LOCALE_CODES, LOCALE_LABELS, type LocaleCode } from './articles';

/** App Config CMS — a single document, `appConfig/global`, not a list. */
export { LOCALE_CODES, LOCALE_LABELS };
export type { LocaleCode };

export type LocalizedText = Partial<Record<LocaleCode, string>>;

export interface MaintenanceMode {
  enabled: boolean;
  message: LocalizedText;
}

export interface AppConfig {
  supportEmail: string;
  minSupportedVersion: string;
  maintenanceMode: MaintenanceMode;
  featureFlags: Record<string, boolean>;
  updatedAt: Timestamp | null;
}

export type AppConfigDraft = Omit<AppConfig, 'updatedAt'>;

const EMPTY_CONFIG: AppConfigDraft = {
  supportEmail: '',
  minSupportedVersion: '',
  maintenanceMode: { enabled: false, message: {} },
  featureFlags: {},
};

const configRef = doc(db, 'appConfig', 'global');

/** No document ever saved comes back as `EMPTY_CONFIG` rather than an error —
 *  the form renders fully editable and the first Save creates the document. */
export async function getAppConfig(): Promise<AppConfig> {
  const snap = await getDoc(configRef);
  if (!snap.exists()) {
    return { ...EMPTY_CONFIG, updatedAt: null };
  }
  const data = snap.data() as Partial<AppConfig>;
  return {
    supportEmail: data.supportEmail ?? '',
    minSupportedVersion: data.minSupportedVersion ?? '',
    maintenanceMode: data.maintenanceMode ?? { enabled: false, message: {} },
    featureFlags: data.featureFlags ?? {},
    updatedAt: data.updatedAt ?? null,
  };
}

export async function saveAppConfig(draft: AppConfigDraft): Promise<void> {
  await setDoc(configRef, { ...draft, updatedAt: serverTimestamp() });
}
