import { Outlet } from 'react-router-dom';
import { Sidebar } from './Sidebar';
import './AdminLayout.css';

/** Shell shared by every console screen: fixed sidebar + scrollable work area.
 *  Matches the 248px sidebar / 28px-24px content padding of Figma E2–E6. */
export function AdminLayout() {
  return (
    <div className="adminLayout">
      <Sidebar />
      <main className="adminLayout__content">
        <Outlet />
      </main>
    </div>
  );
}
