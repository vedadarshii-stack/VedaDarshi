import { useNavigate } from 'react-router-dom';
import { useAuth } from '../lib/authContext';
import { exitConceptMode } from '../lib/conceptMode';
import './AccessNotice.css';

/** Full-bleed message for the states where the console cannot show a screen:
 *  signed in but not console staff, role lacks the permission, or the role
 *  lookup failed. Always offers a way out so nobody gets stranded. */
export function AccessNotice({
  title,
  detail,
  hint,
}: {
  title: string;
  detail: string;
  hint?: string;
}) {
  const navigate = useNavigate();
  const { signOut } = useAuth();

  async function leave() {
    exitConceptMode();
    await signOut();
    navigate('/login', { replace: true });
  }

  return (
    <div className="accessNotice">
      <div className="accessNotice__card">
        <span className="accessNotice__mark vd-om">ॐ</span>
        <h1 className="accessNotice__title">{title}</h1>
        <p className="accessNotice__detail">{detail}</p>
        {hint && <p className="accessNotice__hint">{hint}</p>}
        <button type="button" className="accessNotice__action" onClick={() => void leave()}>
          Back to sign-in
        </button>
      </div>
    </div>
  );
}
