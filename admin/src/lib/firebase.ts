import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

/** Firebase project vedadarshi-20989 (client-owned), web app
 *  `vedadarshi-admin (web)` = 1:1029956122:web:16ac52d8bbb0f35e0327a3.
 *
 *  Values come from .env (committed — the web config is a public identifier,
 *  see the note in that file). Refresh them with the Firebase MCP tool
 *  `firebase_get_sdk_config` using the app id above. */
const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
  measurementId: import.meta.env.VITE_FIREBASE_MEASUREMENT_ID,
};

export const firebaseApp = initializeApp(firebaseConfig);
export const auth = getAuth(firebaseApp);
export const db = getFirestore(firebaseApp);

export const FIREBASE_PROJECT_ID = firebaseConfig.projectId;
