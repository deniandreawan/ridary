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
import {
  Link,
  NavLink,
  Outlet
} from "react-router-dom";
import { DemoBanner, ErrorBanner } from "../components/Banners";
import { Logo } from "../components/Logo";
import { useApp } from "../context/AppContext";

const NAV_ITEMS = [
  { to: "/app", label: "Overview", icon: Activity, end: true },
  { to: "/app/rides", label: "Rides", icon: Map, end: false },
  { to: "/app/credential", label: "Ridary Proof", icon: ShieldCheck, end: false },
  { to: "/app/privacy", label: "Privacy", icon: Cpu, end: false }
];

export default function DashboardLayout() {
  const { demoMode, user, signOut, error } = useApp();
  const initial = (user?.email ?? "R").trim().charAt(0).toUpperCase() || "R";

  return (
    <div className="min-h-[100dvh] bg-canvas">
      <a
        href="#dashboard-main"
        className="sr-only focus:not-sr-only focus:fixed focus:left-4 focus:top-4 focus:z-[60] focus:rounded-full focus:bg-white focus:px-4 focus:py-2 focus:text-[13px] focus:font-medium focus:text-paper focus:shadow-lg"
      >
        Skip to content
      </a>

      <header className="sticky top-0 z-30 border-b border-line/75 bg-white/88 backdrop-blur-xl">
        <div className="mx-auto flex max-w-[1320px] items-center justify-between gap-4 px-4 py-3 sm:px-6">
          <Link to="/app" className="focus-ring rounded-full" aria-label="Ridary overview">
            <Logo />
          </Link>

          <nav className="hidden items-center gap-1 rounded-full border border-line/80 bg-canvas-soft p-1 md:flex">
            {NAV_ITEMS.map(({ to, label, icon: Icon, end }) => (
              <NavLink
                key={to}
                to={to}
                end={end}
                className={({ isActive }) =>
                  `focus-ring flex items-center gap-2 rounded-full px-3.5 py-1.5 text-[13px] font-medium transition ${
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
              className={`hidden items-center gap-1.5 rounded-full px-3 py-1 text-[12px] font-medium sm:inline-flex ${
                demoMode ? "bg-sky-soft text-sky-deep" : "bg-canvas-soft text-paper"
              }`}
            >
              <span
                className={`h-1.5 w-1.5 rounded-full ${demoMode ? "bg-sky" : "bg-sky-deep"}`}
              />
              {demoMode ? "Sample data" : "Live sync"}
            </span>

            <Link
              to="/"
              className="focus-ring rounded-full px-2.5 py-1.5 text-[12px] font-medium text-muted transition hover:text-paper lg:px-3"
            >
              Site
            </Link>

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

      </header>

      <main id="dashboard-main" className="mx-auto max-w-[1320px] px-4 pb-28 pt-5 sm:px-6 md:pb-8 lg:pt-7">
        <div className="space-y-5">
          {demoMode && <DemoBanner />}
          {error && <ErrorBanner message={error} />}
          <Outlet />
        </div>
      </main>

      <footer className="mx-auto max-w-[1320px] px-4 pb-24 pt-2 sm:px-6 md:pb-8">
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

      <nav className="fixed inset-x-0 bottom-0 z-40 border-t border-line/75 bg-white/92 pb-[env(safe-area-inset-bottom)] backdrop-blur-xl md:hidden">
        <div className="grid grid-cols-4">
          {NAV_ITEMS.map(({ to, label, icon: Icon, end }) => (
            <NavLink
              key={to}
              to={to}
              end={end}
              className={({ isActive }) =>
                `focus-ring flex flex-col items-center gap-1 px-2 py-2.5 text-[10px] font-medium transition ${
                  isActive ? "text-sky-deep" : "text-muted"
                }`
              }
            >
              <Icon size={18} strokeWidth={1.8} />
              {label === "Ridary Proof" ? "Proof" : label}
            </NavLink>
          ))}
        </div>
      </nav>
    </div>
  );
}
