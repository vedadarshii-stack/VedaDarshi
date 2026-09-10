import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useAuth } from '../lib/authContext';
import { BrandLoader } from './BrandLoader';

/** Gate for every console route.
 *
 *  REMOVED 9 Sep 2026: a "concept mode" bypass that let anyone browse the
 *  console without signing in. It existed so the Figma click-through could be
 *  reviewed before admin accounts existed — they exist now, and the screens
 *  read real data, so the bypass had outlived its reason and was the only
 *  path into the console that skipped authentication. */
export function RequireAuth() {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return <BrandLoader message="Restoring your session" />;
  }

  if (!user) {
    return <Navigate to="/login" replace state={{ from: location.pathname }} />;
  }

  return <Outlet />;
}
