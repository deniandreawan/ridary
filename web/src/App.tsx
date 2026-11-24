import {
  Activity,
  CheckCircle2,
  Cloud,
  Cpu,
  LogOut,
  Map,
  ShieldCheck,
  Smartphone
} from "lucide-react";
import type { ReactNode } from "react";
import {
  NavLink,
  Navigate,
  Outlet,
  Route,
  Routes
} from "react-router-dom";
import {
  DemoBanner,
  ErrorBanner,
  LoadingScreen
} from "./components/Banners";
import { Logo } from "./components/Logo";
import { useApp } from "./context/AppContext";
import CredentialPage from "./pages/CredentialPage";
import InsurerPage from "./pages/InsurerPage";
import LoginPage from "./pages/LoginPage";
import OverviewPage from "./pages/OverviewPage";
import PrivacyPage from "./pages/PrivacyPage";
import RidesPage from "./pages/RidesPage";

const NAV_ITEMS = [
  { to: "/", label: "Overview", icon: Activity },
  { to: "/rides", label: "Rides", icon: Map },
  { to: "/credential", label: "Ridary Proof", icon: ShieldCheck },
  { to: "/privacy", label: "Privacy", icon: Cpu }
];

function ProtectedRoute() {
  const { loading, user, demoMode } = useApp();
  if (loading) {
    return (
      <div className="min-h-screen px-6 py-10">
        <LoadingScreen />
      </div>
    );
  }
  if (!user && !demoMode) {
    return <LoginPage />;
  }
  return <Outlet />;
}

function DashboardLayout() {
  const { demoMode, user, signOut, error } = useApp();
  const initial = (user?.email ?? "R").trim().charAt(0).toUpperCase() || "R";

  return (
    <div className="min-h-screen bg-canvas">
      <header className="sticky top-0 z-30 border-b border-line/75 bg-white/88 backdrop-blur-xl">
        <div className="mx-auto flex max-w-6xl items-center justify-between gap-4 px-4 py-3 sm:px-6">
          <Logo />

          <nav className="hidden items-center gap-1 rounded-full border border-line/80 bg-canvas-soft p-1 md:flex">
            {NAV_ITEMS.map(({ to, label, icon: Icon }) => (
              <NavLink
                key={to}
                to={to}
                end={to === "/"}
                className={({ isActive }) =>
                  `focus-ring flex items-center gap-2 rounded-full px-4 py-1.5 text-[13px] font-medium transition ${
                    isActive
                      ? "bg-white text-paper shadow-[0_2px_8px_rgba(23,23,23,0.06)]"
                      : "text-muted hover:text-paper"
                  }`
                }
              >
                <Icon size={14} strokeWidth={1.9} />
                {label}
              </NavLink>
            ))}
          </nav>

          <div className="flex items-center gap-2.5">
            <span
              className={`inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-[12px] font-medium ${
                demoMode
                  ? "bg-sky-soft text-sky-deep"
                  : "bg-canvas-soft text-paper"
              }`}
            >
              <span
                className={`h-1.5 w-1.5 rounded-full ${
                  demoMode ? "bg-sky" : "bg-sky-deep"
                }`}
              />
              {demoMode ? "Sample data" : "Live sync"}
            </span>

            <div
              className="hidden h-8 w-8 items-center justify-center rounded-full bg-sky-soft text-[13px] font-semibold text-sky-deep sm:flex"
              title={user?.email ?? "Local demo"}
            >
              {initial}
            </div>

            <button
              type="button"
              onClick={() => void signOut()}
              className="btn-glass focus-ring h-8 w-8 p-0 text-muted hover:text-paper"
              aria-label="Sign out"
              title="Sign out"
            >
              <LogOut size={14} />
            </button>
          </div>
        </div>

        <nav className="flex gap-1 overflow-x-auto border-t border-line/60 px-4 py-2 scrollbar-thin md:hidden">
          {NAV_ITEMS.map(({ to, label, icon: Icon }) => (
            <NavLink
              key={to}
              to={to}
              end={to === "/"}
              className={({ isActive }) =>
                `focus-ring flex shrink-0 items-center gap-1.5 rounded-full px-3.5 py-1.5 text-[12px] font-medium transition ${
                  isActive
                    ? "bg-sky-soft text-sky-deep"
                    : "text-muted hover:text-paper"
                }`
              }
            >
              <Icon size={13} strokeWidth={1.9} />
              {label}
            </NavLink>
          ))}
        </nav>
      </header>

      <main className="mx-auto max-w-6xl px-4 py-6 sm:px-6 lg:py-8">
        <div className="space-y-5">
          {demoMode && <DemoBanner />}
          {error && <ErrorBanner message={error} />}
          <Outlet />
        </div>
      </main>

      <footer className="mx-auto max-w-6xl px-4 pb-10 pt-4 sm:px-6">
        <div className="flex flex-col gap-3 border-t border-line/75 pt-5 text-[12px] text-muted sm:flex-row sm:items-center sm:justify-between">
          <div className="flex items-center gap-2">
            <CheckCircle2 size={13} className="text-sky" />
            <span>Private at the edge. Collective in the cloud.</span>
          </div>
          <div className="flex flex-wrap gap-x-4 gap-y-1 text-subtle">
            <span className="inline-flex items-center gap-1">
              <Smartphone size={12} /> Apple Foundation Models · Chrome Nano
            </span>
            <span className="inline-flex items-center gap-1">
              <Cloud size={12} /> Gemini fallback
            </span>
            <span>Apache-2.0 · Personal record, not legal advice</span>
          </div>
        </div>
      </footer>
    </div>
  );
}

function PublicShell({ children }: { children: ReactNode }) {
  return (
    <div className="min-h-screen bg-canvas">
      <header className="border-b border-line/75 bg-white/90 backdrop-blur-xl">
        <div className="mx-auto flex max-w-4xl items-center justify-between px-4 py-3.5 sm:px-6">
          <Logo compact />
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
    <Routes>
      <Route
        path="/insurer/:token"
        element={
          <PublicShell>
            <InsurerPage />
          </PublicShell>
        }
      />
      <Route element={<ProtectedRoute />}>
        <Route element={<DashboardLayout />}>
          <Route index element={<OverviewPage />} />
          <Route path="rides" element={<RidesPage />} />
          <Route path="credential" element={<CredentialPage />} />
          <Route path="privacy" element={<PrivacyPage />} />
        </Route>
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
