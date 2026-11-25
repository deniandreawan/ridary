import {
  ArrowUpRight,
  CheckCircle2,
  Cloud,
  Cpu,
  Lock,
  ShieldCheck,
  Smartphone
} from "lucide-react";
import { motion, useReducedMotion } from "motion/react";
import { Link } from "react-router-dom";
import { LandingNav } from "../components/landing/LandingNav";
import { ProductStage } from "../components/landing/ProductStage";
import { HowItWorks } from "../components/landing/HowItWorks";
import { TrustBoundary } from "../components/landing/TrustBoundary";
import { ProofShowcase } from "../components/landing/ProofShowcase";
import { Logo } from "../components/Logo";

const TRUST_FACTS = [
  { value: "0 raw GPS", label: "shared with the cloud" },
  { value: "3 rides", label: "to issue a signed proof" },
  { value: "30 sec", label: "local evidence window" }
];

const BUILT_WITH = [
  { icon: <Cpu size={14} />, label: "Firebase AI Logic" },
  { icon: <Smartphone size={14} />, label: "Apple Foundation Models" },
  { icon: <Cpu size={14} />, label: "Chrome Nano" },
  { icon: <Cloud size={14} />, label: "Gemini" },
  { icon: <ShieldCheck size={14} />, label: "App Check" },
  { icon: <Lock size={14} />, label: "Ed25519" }
];

export default function LandingPage() {
  const reduce = useReducedMotion();

  return (
    <div className="min-h-[100dvh] bg-canvas">
      <a
        href="#landing-main"
        className="sr-only focus:not-sr-only focus:fixed focus:left-4 focus:top-4 focus:z-[60] focus:rounded-full focus:bg-white focus:px-4 focus:py-2 focus:text-[13px] focus:font-medium focus:text-paper focus:shadow-lg"
      >
        Skip to content
      </a>

      <LandingNav />

      <main id="landing-main">
        <section className="relative overflow-hidden">
          <div className="pointer-events-none absolute -left-32 top-20 h-80 w-80 rounded-full bg-sky-soft/60 blur-3xl" />
          <div className="mx-auto grid max-w-[1320px] items-center gap-12 px-4 py-12 sm:px-6 lg:grid-cols-[1.02fr_0.98fr] lg:gap-8 lg:py-20">
            <motion.div
              initial={reduce ? false : { opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.7, ease: [0.16, 1, 0.3, 1] }}
              className="relative z-10 max-w-xl"
            >
              <div className="inline-flex items-center gap-2 rounded-full bg-sky-soft px-3.5 py-1.5 text-[12px] font-medium text-sky-deep">
                <span className="h-1.5 w-1.5 rounded-full bg-sky" />
                Private ride witness
              </div>

              <h1 className="mt-5 text-[46px] font-semibold leading-[0.98] tracking-[-0.045em] text-paper sm:text-[58px] lg:text-[66px]">
                Every ride.
                <br />
                On record.
              </h1>

              <p className="mt-5 max-w-md text-[16px] leading-relaxed text-muted sm:text-[17px]">
                A private witness for riders. On-device AI explains the ride;
                the cloud sees only what you share.
              </p>

              <div className="mt-7 flex flex-wrap items-center gap-3">
                <a
                  href="/app?demo=1"
                  className="btn-glass-sky focus-ring px-5 py-3 text-[14px]"
                >
                  Open the live demo
                  <ArrowUpRight size={15} />
                </a>
                <a
                  href="#how"
                  className="btn-glass focus-ring px-5 py-3 text-[14px]"
                >
                  See how it works
                </a>
              </div>

              <div className="mt-10 flex items-center gap-2.5 text-[12px] text-subtle">
                <span className="inline-flex items-center gap-1.5">
                  <CheckCircle2 size={13} className="text-sky" />
                  No raw GPS in the cloud
                </span>
                <span className="h-3 w-px bg-line" />
                <span className="inline-flex items-center gap-1.5">
                  <Lock size={13} className="text-sky" />
                  Local-first by design
                </span>
              </div>
            </motion.div>

            <div className="relative z-0">
              <ProductStage />
            </div>
          </div>
        </section>

        <section className="border-y border-line/70 bg-white">
          <div className="mx-auto grid max-w-[1320px] grid-cols-1 divide-y divide-line/70 px-4 sm:px-6 md:grid-cols-3 md:divide-x md:divide-y-0">
            {TRUST_FACTS.map((fact) => (
              <div key={fact.label} className="flex items-baseline gap-3 px-0 py-6 md:justify-center md:px-8">
                <div className="text-[24px] font-semibold tracking-[-0.025em] text-paper">
                  {fact.value}
                </div>
                <div className="text-[13px] text-muted">{fact.label}</div>
              </div>
            ))}
          </div>
        </section>

        <HowItWorks />
        <TrustBoundary />
        <ProofShowcase />

        <section className="border-t border-line/70 bg-white">
          <div className="mx-auto flex max-w-[1320px] flex-col gap-5 px-4 py-9 sm:px-6 lg:flex-row lg:items-center lg:justify-between">
            <div>
              <div className="mono-label">Built for #BuildHybridAI 2026</div>
              <div className="mt-1 text-[15px] font-medium text-paper">
                A hybrid safety record, running on the edge and in the cloud.
              </div>
            </div>
            <div className="flex flex-wrap gap-2">
              {BUILT_WITH.map((item) => (
                <span
                  key={item.label}
                  className="inline-flex items-center gap-1.5 rounded-full border border-line/80 bg-white px-3 py-1.5 text-[12px] font-medium text-muted"
                >
                  <span className="text-sky-deep">{item.icon}</span>
                  {item.label}
                </span>
              ))}
            </div>
          </div>
        </section>

        <section className="bg-sky-soft/55">
          <div className="mx-auto max-w-[1320px] px-4 py-20 sm:px-6 lg:py-28">
            <div className="relative overflow-hidden rounded-[2rem] border border-white/80 bg-white px-6 py-12 text-center shadow-[0_24px_70px_rgba(23,23,23,0.06)] sm:px-10 sm:py-16">
              <div className="pointer-events-none absolute -right-16 -top-20 h-56 w-56 rounded-full bg-sky-soft/60 blur-3xl" />
              <div className="relative mx-auto max-w-2xl">
                <div className="ios-hero-badge mx-auto">
                  <ShieldCheck size={26} />
                </div>
                <h2 className="mt-5 text-3xl font-semibold tracking-[-0.035em] text-paper sm:text-[44px]">
                  Keep the ride. Share the proof.
                </h2>
                <p className="mx-auto mt-3 max-w-xl text-[16px] leading-relaxed text-muted">
                  Ride with a private record. Share a signed safety band when
                  you choose. Keep the route, the sensors, and the story for
                  yourself.
                </p>
                <div className="mt-7 flex flex-wrap items-center justify-center gap-3">
                  <a
                    href="/app?demo=1"
                    className="btn-glass-sky focus-ring px-5 py-3 text-[14px]"
                  >
                    Open the live demo
                    <ArrowUpRight size={15} />
                  </a>
                  <Link
                    to="/login"
                    className="btn-glass focus-ring px-5 py-3 text-[14px]"
                  >
                    Sign in
                  </Link>
                </div>
                <div className="mt-4 text-[12px] text-subtle">
                  Sample data · No credit card · No route upload
                </div>
              </div>
            </div>
          </div>
        </section>
      </main>

      <footer className="border-t border-line/70 bg-white">
        <div className="mx-auto max-w-[1320px] px-4 py-12 sm:px-6">
          <div className="grid gap-10 md:grid-cols-[1.4fr_0.8fr_0.8fr_0.8fr]">
            <div>
              <Logo />
              <p className="mt-4 max-w-xs text-[13px] leading-relaxed text-muted">
                A private ride witness for people who move on two wheels. Built
                for the edge, ready for the cloud.
              </p>
            </div>
            <div>
              <div className="text-[12px] font-semibold text-paper">Product</div>
              <div className="mt-3 space-y-2 text-[13px] text-muted">
                <a href="#how" className="block hover:text-paper">How it works</a>
                <a href="#proof" className="block hover:text-paper">Ridary Proof</a>
                <a href="#privacy" className="block hover:text-paper">Privacy model</a>
              </div>
            </div>
            <div>
              <div className="text-[12px] font-semibold text-paper">Demo</div>
              <div className="mt-3 space-y-2 text-[13px] text-muted">
                <a href="/app?demo=1" className="block hover:text-paper">Live dashboard</a>
                <a href="/insurer/demo" className="block hover:text-paper">Sample insurer view</a>
                <Link to="/login" className="block hover:text-paper">Sign in</Link>
              </div>
            </div>
            <div>
              <div className="text-[12px] font-semibold text-paper">Built with</div>
              <div className="mt-3 space-y-2 text-[13px] text-muted">
                <span className="block">Firebase AI Logic</span>
                <span className="block">Apple Foundation Models</span>
                <span className="block">Chrome Nano</span>
              </div>
            </div>
          </div>

          <div className="mt-10 flex flex-col gap-2 border-t border-line/70 pt-5 text-[12px] leading-relaxed text-subtle sm:flex-row sm:items-center sm:justify-between">
            <div>Apache-2.0 · Personal record, not legal or medical advice.</div>
            <div className="inline-flex items-center gap-1.5">
              <Lock size={12} />
              Not an emergency service · No automatic dispatch
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
