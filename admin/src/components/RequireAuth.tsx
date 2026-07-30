import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useAuth } from '../lib/authContext';
import { isConceptMode } from '../lib/conceptMode';
import './RequireAuth.css';

/** Gate for every console route. Concept mode (see lib/conceptMode.ts) lets the
 *  static screens be reviewed before real admin accounts exist. */
export function RequireAuth() {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return (
      <div className="authGate">
        <span className="authGate__mark vd-om">ॐ</span>
        <p className="authGate__text">Checking your session…</p>
      </div>
    );
  }

  if (!user && !isConceptMode()) {
    return <Navigate to="/login" replace state={{ from: location.pathname }} />;
  }

  return <Outlet />;
}
