import {
  Activity,
  Route as RouteIcon,
  ShieldCheck,
  Smartphone
} from "lucide-react";
import { AnimatePresence, motion, useInView, useReducedMotion } from "motion/react";
import { useEffect, useRef, useState } from "react";
import { demoCredential, demoRides } from "../../data/demo";
import {
  formatDistance,
  formatDuration,
  scoreBand
} from "../../lib/format";
import { RouteArt } from "../RouteArt";
import { SourceBadge } from "../SourceBadge";
import { PhoneFrame } from "./PhoneFrame";
import { PhoneHomePreview } from "./PhoneHomePreview";

const ride = demoRides[0]!;
const credential = demoCredential;

const CHAPTERS = [
  {
    id: "record",
    title: "Record without surveillance",
    text: "Start a ride and put the phone away. GPS, speed, and motion stay in a local file on your iPhone. No camera, no audio, no auto-upload."
  },
  {
    id: "explain",
    title: "Explain on the device",
    text: "Apple Foundation Models turn motion and route facts into a calm ride summary, risk moments, and one useful tip for next time."
  },
  {
    id: "prove",
    title: "Prove what matters",
    text: "When you are ready, share a signed safety band with an insurer. The proof carries the pattern, never your route or raw sensors."
  }
];

export function HowItWorks() {
  const [active, setActive] = useState(0);
  const reduce = useReducedMotion();

  return (
    <section id="how" className="border-t border-line/70 bg-white">
      <div className="mx-auto max-w-[1320px] px-4 py-20 sm:px-6 lg:py-28">
        <div className="max-w-2xl">
          <div className="mono-label">How it works</div>
          <h2 className="mt-2 text-3xl font-semibold tracking-[-0.03em] text-paper sm:text-[42px]">
            Record. Explain. Prove.
          </h2>
          <p className="mt-3 max-w-xl text-[16px] leading-relaxed text-muted">
            One ride becomes a private record, a useful explanation, and a
            signed proof — without turning your route into a dataset.
          </p>
        </div>

        <div className="mt-14 hidden gap-16 lg:grid lg:grid-cols-[0.82fr_1.18fr]">
          <div className="space-y-0">
            {CHAPTERS.map((chapter, index) => (
              <Chapter
                key={chapter.id}
                chapter={chapter}
                index={index}
                active={active === index}
                onActive={() => setActive(index)}
              />
            ))}
          </div>

          <div className="lg:sticky lg:top-24 lg:self-start">
            <div className="relative flex min-h-[520px] items-center justify-center overflow-hidden rounded-[2rem] border border-line bg-canvas-soft/70 p-8">
              <div className="pointer-events-none absolute -right-16 -top-16 h-48 w-48 rounded-full bg-sky-soft/70 blur-3xl" />
              <AnimatePresence mode="wait">
                <motion.div
                  key={active}
                  initial={reduce ? false : { opacity: 0, y: 14 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  transition={{ duration: 0.28, ease: [0.16, 1, 0.3, 1] }}
                  className="relative w-full"
                >
                  {active === 0 && <RecordVisual />}
                  {active === 1 && <ExplainVisual />}
                  {active === 2 && <ProofVisual />}
                </motion.div>
              </AnimatePresence>
            </div>
          </div>
        </div>

        <div className="mt-12 space-y-12 lg:hidden">
          {CHAPTERS.map((chapter, index) => (
            <div key={chapter.id}>
              <div className="flex gap-4">
                <StepNumber index={index} active />
                <div>
                  <h3 className="text-[20px] font-semibold tracking-[-0.02em] text-paper">
                    {chapter.title}
                  </h3>
                  <p className="mt-2 text-[15px] leading-relaxed text-muted">
                    {chapter.text}
                  </p>
                </div>
              </div>
              <div className="mt-5 rounded-[1.75rem] border border-line bg-canvas-soft/70 p-5">
                {index === 0 && <RecordVisual mobile />}
                {index === 1 && <ExplainVisual mobile />}
                {index === 2 && <ProofVisual mobile />}
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function Chapter({
  chapter,
  index,
  active,
  onActive
}: {
  chapter: (typeof CHAPTERS)[number];
  index: number;
  active: boolean;
  onActive: () => void;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const inView = useInView(ref, { amount: 0.15, margin: "-42% 0px -42% 0px" });

  useEffect(() => {
    if (inView) onActive();
  }, [inView, onActive]);

  return (
    <div
      ref={ref}
      className={`border-l-2 py-8 pl-7 transition-colors duration-300 first:pt-2 last:pb-2 ${
        active ? "border-sky" : "border-line/70"
      }`}
    >
      <div className="flex items-center gap-3">
        <StepNumber index={index} active={active} />
        <div
          className={`text-[12px] font-medium ${
            active ? "text-sky-deep" : "text-subtle"
          }`}
        >
          Step {String(index + 1).padStart(2, "0")}
        </div>
      </div>
      <h3
        className={`mt-4 text-[24px] font-semibold tracking-[-0.025em] ${
          active ? "text-paper" : "text-paper/70"
        }`}
      >
        {chapter.title}
      </h3>
      <p className="mt-2 max-w-md text-[15px] leading-relaxed text-muted">
        {chapter.text}
      </p>
    </div>
  );
}

function StepNumber({ index, active }: { index: number; active: boolean }) {
  return (
    <div
      className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-full text-[12px] font-semibold transition ${
        active ? "bg-sky-soft text-sky-deep" : "bg-canvas-soft text-muted"
      }`}
    >
      {index + 1}
    </div>
  );
}

function RecordVisual({ mobile = false }: { mobile?: boolean }) {
  return (
    <div className="flex flex-col items-center">
      <PhoneFrame className={mobile ? "w-44" : "w-52"}>
        <PhoneHomePreview />
      </PhoneFrame>
      <div className="mt-5 inline-flex items-center gap-2 rounded-full bg-white px-3 py-1.5 text-[12px] font-medium text-paper shadow-sm">
        <Smartphone size={13} className="text-sky" />
        Screen off. GPS and motion on.
      </div>
    </div>
  );
}

function ExplainVisual({ mobile = false }: { mobile?: boolean }) {
  return (
    <div className="mx-auto w-full max-w-md overflow-hidden rounded-[1.5rem] border border-line bg-white shadow-[0_18px_45px_rgba(23,23,23,0.08)]">
      <div className="relative h-32 overflow-hidden bg-sky-soft/35">
        <RouteArt
          route={ride.routePreview}
          className="absolute inset-0 h-full w-full"
        />
        <div className="absolute left-3 top-3">
          <SourceBadge source={ride.inferenceSource} />
        </div>
      </div>
      <div className="p-5">
        <div className="flex items-start justify-between gap-3">
          <div>
            <div className="text-[16px] font-semibold tracking-[-0.015em] text-paper">
              A steady evening commute
            </div>
            <div className="mt-1 text-[12px] text-muted">
              {formatDistance(ride.distanceM)} ·{" "}
              {formatDuration(ride.durationS)} · {formatDateTime(ride.startedAtMs)}
            </div>
          </div>
          <div className="text-right">
            <div className="text-[22px] font-semibold leading-none text-sky-deep">
              {ride.score}
            </div>
            <div className="mt-1 text-[11px] text-muted">B Band</div>
          </div>
        </div>

        <div className="mt-4 border-t border-line/70 pt-3.5">
          <div className="text-[13px] font-medium text-paper">
            Two moments worth reviewing
          </div>
          <div className="mt-2 space-y-2">
            {ride.events.slice(0, 2).map((event) => (
              <div key={event.id} className="flex gap-2.5">
                <div className="mt-0.5 flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-warning/12 text-warning">
                  <Activity size={12} />
                </div>
                <div>
                  <div className="text-[12px] font-medium text-paper">
                    {event.type.replaceAll("_", " ")}
                  </div>
                  <div className="text-[11px] leading-relaxed text-muted">
                    {event.summary}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="mt-4 rounded-xl bg-sky-soft/65 px-3.5 py-3 text-[12px] leading-relaxed text-paper">
          Leave a little more following distance at wet junctions.
        </div>
      </div>
      {mobile && <div className="h-1" />}
    </div>
  );
}

function ProofVisual({ mobile = false }: { mobile?: boolean }) {
  return (
    <div className="mx-auto w-full max-w-md overflow-hidden rounded-[1.5rem] border border-line bg-white shadow-[0_18px_45px_rgba(23,23,23,0.08)]">
      <div className="ios-hero-pastel flex flex-col items-center px-6 pb-9 pt-6 text-center">
        <div className="mono-label">Ridary Proof</div>
        <div className="ios-hero-badge mt-3 h-12 w-12">
          <ShieldCheck size={21} />
        </div>
        <div className="mt-3 text-[28px] font-semibold tracking-[-0.03em] text-paper">
          {scoreBand(credential.score)} Band
        </div>
        <div className="mt-0.5 text-[12px] text-muted">
          Score {credential.score}/100 · {credential.rideCount} rides
        </div>
      </div>
      <div className="-mt-4 rounded-t-[1.5rem] bg-white px-5 pt-5">
        <div className="grid grid-cols-3 divide-x divide-line/75 text-center">
          <div>
            <div className="text-[16px] font-semibold text-sky-deep">
              {credential.eventCount}
            </div>
            <div className="mt-0.5 text-[11px] text-muted">moments</div>
          </div>
          <div>
            <div className="text-[16px] font-semibold text-paper">
              {credential.rideCount}
            </div>
            <div className="mt-0.5 text-[11px] text-muted">rides</div>
          </div>
          <div>
            <div className="inline-flex items-center gap-1 text-[13px] font-semibold text-paper">
              <ShieldCheck size={13} className="text-sky" />
              Ed25519
            </div>
            <div className="mt-0.5 text-[11px] text-muted">signed</div>
          </div>
        </div>
        <div className="mt-4 flex items-center justify-between border-t border-line/70 pt-3 text-[11px] text-muted">
          <span>Issued by {credential.issuer}</span>
          <span className="inline-flex items-center gap-1 text-sky-deep">
            <RouteIcon size={12} /> route excluded
          </span>
        </div>
      </div>
      {mobile && <div className="h-1" />}
    </div>
  );
}

function formatDateTime(ms: number): string {
  return new Intl.DateTimeFormat("en", {
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit"
  }).format(new Date(ms));
}

