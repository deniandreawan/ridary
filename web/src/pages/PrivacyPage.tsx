import {
  Cloud,
  Cpu,
  Database,
  Lock,
  ShieldAlert,
  Smartphone,
  Trash2
} from "lucide-react";
import { SectionHeader } from "../components/Banners";

export default function PrivacyPage() {
  return (
    <div className="space-y-5">
      <header>
        <div className="mono-label">Privacy / Data model</div>
        <h1 className="mt-2 text-3xl font-semibold tracking-[-0.03em]">
          Your data has a home: your phone.
        </h1>
        <p className="mt-2 max-w-3xl text-sm leading-relaxed text-muted">
          Ridary is built as a local-first record. The useful details stay on
          the device; only the smallest aggregate leaves it, and only when you
          choose.
        </p>
      </header>

      <div className="grid gap-4 sm:grid-cols-2">
        <PrivacyCard
          icon={<Smartphone size={18} />}
          title="Stays on your phone"
          items={[
            "Raw GPS route and speed samples",
            "Accelerometer and gyroscope windows",
            "Incident evidence files and statements",
            "On-device AI snapshots and ride cards"
          ]}
          tone="text-teal"
        />
        <PrivacyCard
          icon={<Cloud size={18} />}
          title="Can sync with consent"
          items={[
            "Ride summary, score, and inference source",
            "Event type, severity, confidence, and coarse geohash",
            "Optional simplified route preview",
            "Signed credential and insurer view"
          ]}
          tone="text-accent"
        />
      </div>

      <section className="surface p-5">
        <SectionHeader
          eyebrow="Hybrid inference"
          title="A deliberate split, not a fallback accident"
        />
        <div className="mt-4 grid gap-3 md:grid-cols-2">
          <SplitCard
            icon={<Cpu size={16} />}
            title="On device"
            text="Apple Foundation Models on iOS, Gemini Nano in Chrome. The model explains a ride, interprets sensor candidates, and drafts sensitive incident notes while offline."
            tone="border-teal/20 bg-teal/6"
          />
          <SplitCard
            icon={<Cloud size={16} />}
            title="In the cloud"
            text="Gemini handles cross-rider risk patterns, weekly feedback, and the signed credential narrative. It never needs the raw route to do that."
            tone="border-accent/20 bg-accent/6"
          />
        </div>
        <div className="mt-4 rounded-xl border border-line bg-ink-soft p-4">
          <div className="flex items-start gap-3">
            <Lock size={16} className="mt-0.5 text-teal" />
            <p className="text-[11px] leading-relaxed text-muted">
              Sensitive features use the on-device-only mode. If the local model
              is unavailable, Ridary falls back to local rules instead of
              silently sending the evidence to the cloud.
            </p>
          </div>
        </div>
      </section>

      <div className="grid gap-4 md:grid-cols-2">
        <section className="surface p-5">
          <SectionHeader eyebrow="Control" title="What you can do" />
          <ul className="mt-4 space-y-3">
            <ControlRow
              icon={<Database size={14} />}
              text="Turn anonymized event sharing and route previews on or off independently."
            />
            <ControlRow
              icon={<Trash2 size={14} />}
              text="Delete local attendance, ride history, and evidence from the iOS app."
            />
            <ControlRow
              icon={<ShieldAlert size={14} />}
              text="Export an incident PDF from the phone; nothing is shared automatically."
            />
          </ul>
        </section>

        <section className="surface p-5">
          <SectionHeader eyebrow="Limits" title="What Ridary is not" />
          <ul className="mt-4 space-y-3 text-[11px] leading-relaxed text-muted">
            <li>
              <span className="font-semibold text-paper">Not court-grade.</span>{" "}
              This is a personal record and a signed safety credential, not a
              legal evidence certification.
            </li>
            <li>
              <span className="font-semibold text-paper">Not an emergency service.</span>{" "}
              Ridary does not call emergency services or promise that help is
              coming.
            </li>
            <li>
              <span className="font-semibold text-paper">Not a diagnosis.</span>{" "}
              Event explanations are screening signals, not medical or
              mechanical advice.
            </li>
            <li>
              <span className="font-semibold text-paper">Not continuous AI.</span>{" "}
              On-device inference runs only while the app is in the foreground;
              background capture records sensors only.
            </li>
          </ul>
        </section>
      </div>
    </div>
  );
}

function PrivacyCard({
  icon,
  title,
  items,
  tone
}: {
  icon: React.ReactNode;
  title: string;
  items: string[];
  tone: string;
}) {
  return (
    <section className="surface p-5">
      <div className={`inline-flex ${tone}`}>{icon}</div>
      <h2 className="mt-3 text-sm font-semibold text-paper">{title}</h2>
      <ul className="mt-3 space-y-2">
        {items.map((item) => (
          <li
            key={item}
            className="flex gap-2 text-[11px] leading-relaxed text-muted"
          >
            <span className={`mt-1.5 h-1 w-1 shrink-0 rounded-full bg-current ${tone}`} />
            {item}
          </li>
        ))}
      </ul>
    </section>
  );
}

function SplitCard({
  icon,
  title,
  text,
  tone
}: {
  icon: React.ReactNode;
  title: string;
  text: string;
  tone: string;
}) {
  return (
    <div className={`rounded-xl border p-4 ${tone}`}>
      <div className="flex items-center gap-2 text-xs font-semibold text-paper">
        {icon}
        {title}
      </div>
      <p className="mt-2 text-[11px] leading-relaxed text-muted">{text}</p>
    </div>
  );
}

function ControlRow({
  icon,
  text
}: {
  icon: React.ReactNode;
  text: string;
}) {
  return (
    <li className="flex gap-3 text-[11px] leading-relaxed text-muted">
      <span className="mt-0.5 text-accent">{icon}</span>
      {text}
    </li>
  );
}
