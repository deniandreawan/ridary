import {
  Cloud,
  Cpu,
  Lock,
  ShieldCheck,
  Smartphone,
  Sparkles
} from "lucide-react";
import { motion, useReducedMotion } from "motion/react";

export function TrustBoundary() {
  const reduce = useReducedMotion();

  return (
    <section id="privacy" className="scroll-mt-24 border-t border-line/70 bg-sky-soft/45">
      <div className="mx-auto max-w-[1320px] px-4 py-20 sm:px-6 lg:py-28">
        <motion.div
          initial={reduce ? false : { opacity: 0, y: 18 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, amount: 0.25 }}
          transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
          className="overflow-hidden rounded-[2rem] border border-white/80 bg-white shadow-[0_24px_70px_rgba(23,23,23,0.06)]"
        >
          <div className="mx-auto max-w-3xl px-6 pb-8 pt-10 text-center sm:px-10">
            <div className="mono-label">The trust boundary</div>
            <h2 className="mt-2 text-3xl font-semibold tracking-[-0.03em] text-paper sm:text-[42px]">
              Private at the edge.
              <br />
              Collective in the cloud.
            </h2>
            <p className="mt-3 text-[16px] leading-relaxed text-muted">
              Raw routes, sensor windows, and incident notes stay on your
              iPhone. Only derived summaries can leave it through Firebase AI
              Logic — and every answer shows where it came from.
            </p>
          </div>

          <div className="mx-6 h-px bg-line/75 sm:mx-10" />

          <div className="grid lg:grid-cols-[1fr_auto_1fr]">
            <BoundarySide
              icon={<Smartphone size={17} />}
              label="On device"
              title="The record stays local"
              items={[
                "Raw GPS route, speed, and altitude",
                "Accelerometer and gyroscope windows",
                "Incident evidence and statements",
                "Apple Foundation Models · Chrome Nano"
              ]}
              tone="sky"
            />

            <div className="flex items-center justify-center border-y border-line/70 px-6 py-3 lg:border-x lg:border-y-0 lg:px-5">
              <span className="inline-flex items-center gap-1.5 rounded-full bg-sky-soft px-3 py-1.5 text-[11px] font-medium text-sky-deep">
                <Lock size={11} />
                derived only
              </span>
            </div>

            <BoundarySide
              icon={<Cloud size={17} />}
              label="In cloud"
              title="Only the smallest aggregate"
              items={[
                "Ride score, summary, and inference source",
                "Event type, severity, and coarse geohash",
                "Community risk cells and weekly patterns",
                "Signed Ed25519 credential"
              ]}
              tone="neutral"
            />
          </div>

          <div className="mx-6 h-px bg-line/75 sm:mx-10" />

          <div className="grid gap-4 px-6 py-6 sm:grid-cols-3 sm:px-10">
            <TrustNote
              icon={<Cpu size={15} />}
              title="On-device first"
              text="Sensitive features never fall back to the cloud without saying so."
            />
            <TrustNote
              icon={<Sparkles size={15} />}
              title="Ask Ridary"
              text="Answers come from local summaries; cloud fallback sees the same derived context."
            />
            <TrustNote
              icon={<ShieldCheck size={15} />}
              title="No surveillance model"
              text="No audio recording, no camera capture, no automatic emergency calls."
            />
          </div>
        </motion.div>
      </div>
    </section>
  );
}

function BoundarySide({
  icon,
  label,
  title,
  items,
  tone
}: {
  icon: React.ReactNode;
  label: string;
  title: string;
  items: string[];
  tone: "sky" | "neutral";
}) {
  return (
    <div className="px-6 py-8 sm:px-10">
      <div className="flex items-center gap-3">
        <div className="ios-icon-circle">{icon}</div>
        <div>
          <div className="mono-label">{label}</div>
          <div className="mt-0.5 text-[17px] font-semibold tracking-[-0.015em] text-paper">
            {title}
          </div>
        </div>
      </div>
      <ul className="mt-5 space-y-3">
        {items.map((item) => (
          <li key={item} className="flex items-start gap-2.5 text-[13px] leading-relaxed text-muted">
            <span
              className={`mt-1.5 h-1.5 w-1.5 shrink-0 rounded-full ${
                tone === "sky" ? "bg-sky" : "bg-subtle"
              }`}
            />
            {item}
          </li>
        ))}
      </ul>
    </div>
  );
}

function TrustNote({
  icon,
  title,
  text
}: {
  icon: React.ReactNode;
  title: string;
  text: string;
}) {
  return (
    <div className="flex gap-3">
      <span className="mt-0.5 text-sky-deep">{icon}</span>
      <div>
        <div className="text-[13px] font-medium text-paper">{title}</div>
        <div className="mt-0.5 text-[12px] leading-relaxed text-muted">{text}</div>
      </div>
    </div>
  );
}
