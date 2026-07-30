import { createContext, useContext } from 'react';
import type { User } from 'firebase/auth';

export type AuthState = {
  /** null once resolved and nobody is signed in. */
  user: User | null;
  /** True until Firebase has restored any persisted session. */
  loading: boolean;
  signInWithGoogle: () => Promise<void>;
  signInWithEmail: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
};

export const AuthContext = createContext<AuthState | null>(null);

export function useAuth(): AuthState {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used inside <AuthProvider>');
  }
  return context;
}
