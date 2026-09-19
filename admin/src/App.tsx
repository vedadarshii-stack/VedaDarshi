import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { AuthProvider } from './lib/AuthProvider';
import { AdminProfileProvider } from './lib/AdminProfileProvider';
import { PERMISSIONS } from './lib/permissions';
import { RequireAuth } from './components/RequireAuth';
import { RequirePermission } from './components/RequirePermission';
import { AdminLayout } from './components/AdminLayout';
import { LoginPage } from './pages/login/LoginPage';
import { DashboardPage } from './pages/dashboard/DashboardPage';
import { UsersPage } from './pages/users/UsersPage';
import { ArticlesPage } from './pages/articles/ArticlesPage';
import { NotificationsPage } from './pages/notifications/NotificationsPage';
import { PlansPage } from './pages/plans/PlansPage';
import { AiUsagePage } from './pages/ai-usage/AiUsagePage';
import { QuotesPage } from './pages/quotes/QuotesPage';
import { MuhuratPage } from './pages/muhurat/MuhuratPage';
import { ConfigPage } from './pages/config/ConfigPage';

/** Screens follow the Figma "E · Admin CMS (React Web)" concept.
 *
 *  Auth and role resolution are real (Firebase project vedadarshi-20989):
 *  RequireAuth checks the session, RequirePermission checks the role loaded from
 *  adminUsers/{uid} → adminRoles/{roleId}. Editorial content (Articles,
 *  Quotes & Festivals, Muhurat Content, App Config) reads/writes Firestore
 *  directly — see the comment in src/lib/articles.ts for why that differs from
 *  Users, which needs a Cloud Function because the rules refuse `list`.
 *  `src/lib/useCollection.ts` is what a screen falls back to when it isn't. */
function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <AdminProfileProvider>
          <Routes>
            <Route path="/login" element={<LoginPage />} />
            <Route element={<RequireAuth />}>
              <Route element={<AdminLayout />}>
                <Route
                  path="/dashboard"
                  element={
                    <RequirePermission need={PERMISSIONS.dashboardView}>
                      <DashboardPage />
                    </RequirePermission>
                  }
                />
                <Route
                  path="/users"
                  element={
                    <RequirePermission need={PERMISSIONS.usersView}>
                      <UsersPage />
                    </RequirePermission>
                  }
                />
                <Route
                  path="/articles"
                  element={
                    <RequirePermission need={PERMISSIONS.articlesView}>
                      <ArticlesPage />
                    </RequirePermission>
                  }
                />
                <Route
                  path="/notifications"
                  element={
                    <RequirePermission need={PERMISSIONS.notificationsSend}>
                      <NotificationsPage />
                    </RequirePermission>
                  }
                />
                <Route
                  path="/ai-usage"
                  element={
                    <RequirePermission need={PERMISSIONS.aiView}>
                      <AiUsagePage />
                    </RequirePermission>
                  }
                />
                <Route
                  path="/plans"
                  element={
                    <RequirePermission need={PERMISSIONS.plansManage}>
                      <PlansPage />
                    </RequirePermission>
                  }
                />
                <Route
                  path="/quotes"
                  element={
                    <RequirePermission need={PERMISSIONS.quotesManage}>
                      <QuotesPage />
                    </RequirePermission>
                  }
                />
                <Route
                  path="/muhurat"
                  element={
                    <RequirePermission need={PERMISSIONS.muhuratManage}>
                      <MuhuratPage />
                    </RequirePermission>
                  }
                />
                <Route
                  path="/config"
                  element={
                    <RequirePermission need={PERMISSIONS.configManage}>
                      <ConfigPage />
                    </RequirePermission>
                  }
                />
              </Route>
            </Route>
            <Route path="*" element={<Navigate to="/login" replace />} />
          </Routes>
        </AdminProfileProvider>
      </BrowserRouter>
    </AuthProvider>
  );
}

export default App;
