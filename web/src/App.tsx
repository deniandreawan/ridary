import { lazy, Suspense, type ReactNode } from "react";
import {
  Link,
  Navigate,
  Route,
  Routes,
  useLocation
} from "react-router-dom";
import { Logo } from "./components/Logo";
import LandingPage from "./pages/LandingPage";

const AppShell = lazy(() => import("./app/AppShell"));
const ProtectedRoute = lazy(() => import("./app/ProtectedRoute"));
const DashboardLayout = lazy(() => import("./app/DashboardLayout"));
const LoginPage = lazy(() => import("./pages/LoginPage"));
const OverviewPage = lazy(() => import("./pages/OverviewPage"));
const RidesPage = lazy(() => import("./pages/RidesPage"));
const CredentialPage = lazy(() => import("./pages/CredentialPage"));
const PrivacyPage = lazy(() => import("./pages/PrivacyPage"));
const InsurerPage = lazy(() => import("./pages/InsurerPage"));

function RouteFallback() {
  return (
    <div className="flex min-h-[100dvh] items-center justify-center bg-canvas">
      <div className="inline-flex items-center gap-2.5 rounded-full bg-white px-4 py-2 text-[13px] font-medium text-muted shadow-sm">
        <span className="h-2 w-2 animate-pulse rounded-full bg-sky" />
        Loading Ridary…
      </div>
    </div>
  );
}

function LegacyRedirect({ to }: { to: string }) {
  const location = useLocation();
  return <Navigate to={{ pathname: to, search: location.search }} replace />;
}

function PublicShell({ children }: { children: ReactNode }) {
  return (
    <div className="min-h-[100dvh] bg-canvas">
      <header className="border-b border-line/75 bg-white/90 backdrop-blur-xl">
        <div className="mx-auto flex max-w-4xl items-center justify-between px-4 py-3.5 sm:px-6">
          <Link to="/" className="focus-ring rounded-full" aria-label="Back to Ridary site">
            <Logo compact />
          </Link>
          <span className="inline-flex items-center gap-1.5 rounded-full bg-sky-soft px-3 py-1 text-[12px] font-medium text-sky-deep">
            <span className="h-1.5 w-1.5 rounded-full bg-sky" />
            Insurer view
          </span>
        </div>
      </header>
      <main className="mx-auto max-w-4xl px-4 py-8 sm:px-6">{children}</main>
    </div>
  );
}

export default function App() {
  return (
    <Suspense fallback={<RouteFallback />}>
      <Routes>
        <Route index element={<LandingPage />} />

        <Route element={<AppShell />}>
          <Route path="login" element={<LoginPage />} />
          <Route
            path="insurer/:token"
            element={
              <PublicShell>
                <InsurerPage />
              </PublicShell>
            }
          />

          <Route element={<ProtectedRoute />}>
            <Route path="app" element={<DashboardLayout />}>
              <Route index element={<OverviewPage />} />
              <Route path="rides" element={<RidesPage />} />
              <Route path="credential" element={<CredentialPage />} />
              <Route path="privacy" element={<PrivacyPage />} />
            </Route>
          </Route>
        </Route>

        <Route path="rides" element={<LegacyRedirect to="/app/rides" />} />
        <Route path="credential" element={<LegacyRedirect to="/app/credential" />} />
        <Route path="privacy" element={<LegacyRedirect to="/app/privacy" />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Suspense>
  );
}
