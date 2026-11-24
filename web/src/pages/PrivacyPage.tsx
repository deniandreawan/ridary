import {
  Cloud,
  Cpu,
  Database,
  Lock,
  ShieldAlert,
  Smartphone,
  Trash2
} from "lucide-react";
import type { ReactNode } from "react";

export default function PrivacyPage() {
  return (
    <div className="mx-auto max-w-3xl">
      <article className="surface overflow-hidden">
        <div className="ios-hero-pastel flex flex-col items-center px-6 pb-11 pt-9 text-center">
          <div className="mono-label">Data model</div>
          <div className="ios-hero-badge mt-3.5">
            <Lock size={24} strokeWidth={1.9} />
          </div>
          <div className="mt-3.5 text-[30px] font-semibold tracking-[-0.03em] text-paper">
            Private by default
          </div>
          <div className="mt-1 text-[13px] text-muted">
            Local-first capture · Hybrid AI trust boundary
          </div>
        </div>

        <div className="relative -mt-6 rounded-t-[1.625rem] bg-white pt-7 shadow-[0_-6px_20px_rgba(23,23,23,0.04)]">
          <div className="mx-auto max-w-xl px-6 pb-6 text-center">
            <h1 className="text-[23px] font-semibold tracking-[-0.025em] text-paper">
              Your data has a home: your phone
            </h1>
            <p className="mt-2.5 text-[15px] leading-relaxed text-muted">
              Ridary is built as a local-first record. Raw routes and sensor
              windows stay on your iPhone; only the smallest aggregate leaves
              it, and only when you choose.
            </p>
          </div>

          <div className="mx-6 h-px bg-line/75" />

          <div className="grid grid-cols-3 divide-x divide-line/75 items-center px-6 py-5 text-center">
            <CenteredPrivacyMetric
              value="On iPhone"
              label="Raw GPS & IMU"
              accent
            />
            <CenteredPrivacyMetric
              value="On-device"
              label="Incident AI"
            />
            <CenteredPrivacyMetric
              value="SHA-256"
              label="Evidence lock"
            />
          </div>

          <div className="mx-6 h-px bg-line/75" />

          <div className="grid gap-6 px-6 py-6 sm:grid-cols-2">
            <div>
              <div className="flex items-center gap-3">
                <div className="ios-icon-circle">
                  <Smartphone size={15} />
                </div>
                <h2 className="text-[16px] font-semibold text-paper">
                  Stays on your phone
                </h2>
              </div>
              <ul className="mt-3.5 space-y-2.5 pl-12 text-[13px] text-muted">
                <li>Raw GPS route and speed samples</li>
                <li>Accelerometer and gyroscope windows</li>
                <li>Incident evidence files and statements</li>
                <li>On-device AI snapshots and ride cards</li>
              </ul>
            </div>

            <div>
              <div className="flex items-center gap-3">
                <div className="ios-icon-circle">
                  <Cloud size={15} />
                </div>
                <h2 className="text-[16px] font-semibold text-paper">
                  Can sync with consent
                </h2>
              </div>
              <ul className="mt-3.5 space-y-2.5 pl-12 text-[13px] text-muted">
                <li>Ride summary, score, and inference source</li>
                <li>Event type, severity, and coarse geohash</li>
                <li>Optional simplified route preview</li>
                <li>Signed credential and insurer view</li>
              </ul>
            </div>
          </div>

          <div className="mx-6 h-px bg-line/75" />

          <div className="space-y-4 px-6 py-6">
            <h2 className="text-[17px] font-semibold tracking-[-0.015em] text-paper">
              Hybrid AI split
            </h2>

            <PrivacyRow
              icon={<Cpu size={15} />}
              title="On device (Apple Foundation Models · Chrome Nano)"
              subtitle="Explains a ride, answers Ask Ridary, and drafts sensitive incident notes offline. If unavailable on sensitive records, Ridary uses local rules—never silent cloud upload."
            />
            <PrivacyRow
              icon={<Cloud size={15} />}
              title="In cloud (Gemini via Firebase AI Logic)"
              subtitle="Analyzes anonymized community risk cells and cross-ride weekly patterns without needing raw routes."
            />
          </div>

          <div className="mx-6 h-px bg-line/75" />

          <div className="space-y-4 px-6 py-6">
            <h2 className="text-[17px] font-semibold tracking-[-0.015em] text-paper">
              Your controls
            </h2>

            <PrivacyRow
              icon={<Database size={15} />}
              title="Independent sharing toggles"
              subtitle="Turn anonymized safety points and simplified route previews on or off separately in Settings."
            />
            <PrivacyRow
              icon={<Trash2 size={15} />}
              title="Swipe to delete"
              subtitle="Delete any ride and its linked incident evidence directly from your iPhone."
            />
            <PrivacyRow
              icon={<ShieldAlert size={15} />}
              title="Personal record, not emergency or legal dispatch"
              subtitle="Ridary does not call emergency services, decide fault, or certify court-grade evidence."
            />
          </div>
        </div>
      </article>
    </div>
  );
}

function CenteredPrivacyMetric({
  value,
  label,
  accent = false
}: {
  value: string;
  label: string;
  accent?: boolean;
}) {
  return (
    <div>
      <div
        className={`text-[17px] font-semibold tracking-tight ${
          accent ? "text-sky-deep" : "text-paper"
        }`}
      >
        {value}
      </div>
      <div className="mt-0.5 text-[12px] text-muted">{label}</div>
    </div>
  );
}

function PrivacyRow({
  icon,
  title,
  subtitle
}: {
  icon: ReactNode;
  title: string;
  subtitle: string;
}) {
  return (
    <div className="flex items-start gap-3.5">
      <div className="ios-icon-circle mt-0.5">{icon}</div>
      <div>
        <div className="text-[15px] font-medium text-paper">{title}</div>
        <div className="mt-0.5 text-[13px] leading-relaxed text-muted">
          {subtitle}
        </div>
      </div>
    </div>
  );
}
