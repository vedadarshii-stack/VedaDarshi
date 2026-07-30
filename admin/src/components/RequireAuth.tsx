import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useAuth } from '../lib/authContext';
import { isConceptMode } from '../lib/conceptMode';
import { BrandLoader } from './BrandLoader';

/** Gate for every console route. Concept mode (see lib/conceptMode.ts) lets the
 *  static screens be reviewed before real admin accounts exist. */
export function RequireAuth() {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return <BrandLoader message="Restoring your session" />;
  }

  if (!user && !isConceptMode()) {
    return <Navigate to="/login" replace state={{ from: location.pathname }} />;
  }

  return <Outlet />;
}
