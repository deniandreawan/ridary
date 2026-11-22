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
  { to: "/", label: "Home", icon: Activity },
  { to: "/rides", label: "Rides", icon: Map },
  { to: "/credential", label: "Proof", icon: ShieldCheck },
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

  return (
    <div className="min-h-screen">
      <header className="sticky top-0 z-30 border-b border-line bg-canvas/85 backdrop-blur-xl">
        <div className="mx-auto flex max-w-7xl flex-col gap-4 px-4 py-4 sm:px-6 lg:flex-row lg:items-center lg:justify-between">
          <div className="flex items-center justify-between gap-4">
            <Logo />
            <div className="flex items-center gap-2 lg:hidden">
              <span
                className={`inline-flex items-center gap-1.5 rounded-full border px-2.5 py-1 font-mono text-[9px] uppercase tracking-[0.12em] ${
                  demoMode
                    ? "border-accent/30 bg-accent/10 text-accent"
                    : "border-teal/30 bg-teal/10 text-teal"
                }`}
              >
                <span className="h-1.5 w-1.5 rounded-full bg-current" />
                {demoMode ? "Demo" : "Live"}
              </span>
              <button
                type="button"
                onClick={() => void signOut()}
                className="focus-ring rounded-lg border border-line p-2 text-muted hover:text-paper"
                aria-label="Sign out"
              >
                <LogOut size={14} />
              </button>
            </div>
          </div>

          <nav className="flex gap-1 overflow-x-auto pb-1 scrollbar-thin lg:pb-0">
            {NAV_ITEMS.map(({ to, label, icon: Icon }) => (
              <NavLink
                key={to}
                to={to}
                end={to === "/"}
                className={({ isActive }) =>
                  `focus-ring flex shrink-0 items-center gap-2 rounded-xl px-3 py-2 text-xs font-medium transition ${
                    isActive
                      ? "bg-card-soft text-paper"
                      : "text-muted hover:bg-ink/5 hover:text-paper"
                  }`
                }
              >
                <Icon size={14} strokeWidth={1.9} />
                {label}
              </NavLink>
            ))}
          </nav>

          <div className="hidden items-center gap-3 lg:flex">
            <span
              className={`inline-flex items-center gap-1.5 rounded-full border px-2.5 py-1 font-mono text-[9px] uppercase tracking-[0.12em] ${
                demoMode
                  ? "border-accent/30 bg-accent/10 text-accent"
                  : "border-teal/30 bg-teal/10 text-teal"
              }`}
            >
              <span className="h-1.5 w-1.5 rounded-full bg-current" />
              {demoMode ? "Demo data" : "Live data"}
            </span>
            <div className="text-right">
              <div className="font-mono text-[9px] uppercase tracking-[0.14em] text-muted">
                Signed in
              </div>
              <div className="max-w-[160px] truncate text-xs text-paper">
                {user?.email ?? "Local demo"}
              </div>
            </div>
            <button
              type="button"
              onClick={() => void signOut()}
              className="focus-ring rounded-xl border border-line p-2 text-muted transition hover:text-paper"
              aria-label="Sign out"
            >
              <LogOut size={14} />
            </button>
          </div>
        </div>
      </header>

      <main className="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:py-8">
        <div className="space-y-4">
          {demoMode && <DemoBanner />}
          {error && <ErrorBanner message={error} />}
          <Outlet />
        </div>
      </main>

      <footer className="mx-auto max-w-7xl px-4 pb-10 pt-4 sm:px-6">
        <div className="flex flex-col gap-3 border-t border-line pt-5 text-[10px] leading-relaxed text-muted sm:flex-row sm:items-center sm:justify-between">
          <div className="flex items-center gap-2">
            <CheckCircle2 size={12} className="text-teal" />
            Private at the edge. Collective in the cloud.
          </div>
          <div className="flex flex-wrap gap-x-4 gap-y-1">
            <span className="inline-flex items-center gap-1">
              <Smartphone size={11} /> Apple Foundation Models / Chrome Nano
            </span>
            <span className="inline-flex items-center gap-1">
              <Cloud size={11} /> Gemini fallback
            </span>
            <span>Apache-2.0 · not legal advice</span>
          </div>
        </div>
      </footer>
    </div>
  );
}

function PublicShell({ children }: { children: ReactNode }) {
  return (
    <div className="min-h-screen">
      <header className="border-b border-line bg-canvas/85 backdrop-blur-xl">
        <div className="mx-auto flex max-w-4xl items-center justify-between px-4 py-4 sm:px-6">
          <Logo compact />
          <span className="inline-flex items-center gap-1.5 rounded-full border border-teal/30 bg-teal/10 px-2.5 py-1 font-mono text-[9px] uppercase tracking-[0.12em] text-teal">
            <span className="h-1.5 w-1.5 rounded-full bg-current" />
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
