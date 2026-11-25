import { ArrowUpRight, Check, ShieldCheck } from "lucide-react";
import { motion, useReducedMotion } from "motion/react";
import { demoCredential } from "../../data/demo";
import {
  formatISODate,
  formatPeriod,
  scoreBand
} from "../../lib/format";

const credential = demoCredential;

export function ProofShowcase() {
  const reduce = useReducedMotion();

  return (
    <section id="proof" className="scroll-mt-24 border-t border-line/70 bg-white">
      <div className="mx-auto grid max-w-[1320px] gap-12 px-4 py-20 sm:px-6 lg:grid-cols-[0.92fr_1.08fr] lg:items-center lg:py-28">
        <div>
          <div className="mono-label">Ridary Proof</div>
          <h2 className="mt-2 max-w-md text-3xl font-semibold tracking-[-0.03em] text-paper sm:text-[42px]">
            Proof, not surveillance.
          </h2>
          <p className="mt-3 max-w-md text-[16px] leading-relaxed text-muted">
            A signed safety credential that shows the pattern, not the route.
            Insurers can verify the signature without receiving raw GPS or
            sensor windows.
          </p>

          <div className="mt-6 space-y-3">
            {[
              "Ed25519 signature over a canonical payload",
              "Aggregate score, period, ride and moment count",
              "No route, no raw sensors, no rider identity",
              "Expires automatically; revocable at any time"
            ].map((item) => (
              <div key={item} className="flex items-start gap-2.5 text-[14px] text-paper">
                <Check size={15} className="mt-0.5 shrink-0 text-sky-deep" />
                {item}
              </div>
            ))}
          </div>

          <div className="mt-8 flex flex-wrap items-center gap-3">
            <a
              href="/insurer/demo"
              className="btn-glass-sky focus-ring px-4 py-2.5 text-[13px]"
            >
              Open a sample insurer view
              <ArrowUpRight size={14} />
            </a>
            <a
              href="/app?demo=1"
              className="btn-glass focus-ring px-4 py-2.5 text-[13px]"
            >
              Open the dashboard
            </a>
          </div>
          <p className="mt-3 text-[12px] text-subtle">
            Sample credential. Ridary Proof is a personal safety record, not a
            legal or insurance determination.
          </p>
        </div>

        <motion.div
          initial={reduce ? false : { opacity: 0, y: 20, rotate: -0.5 }}
          whileInView={{ opacity: 1, y: 0, rotate: 0 }}
          viewport={{ once: true, amount: 0.3 }}
          transition={{ duration: 0.7, ease: [0.16, 1, 0.3, 1] }}
          className="mx-auto w-full max-w-[520px] overflow-hidden rounded-[2rem] border border-line bg-white shadow-[0_28px_80px_rgba(23,23,23,0.1)]"
        >
          <div className="ios-hero-pastel flex flex-col items-center px-6 pb-10 pt-8 text-center">
            <div className="mono-label">
              Valid until {formatISODate(credential.expiresAt)}
            </div>
            <div className="ios-hero-badge mt-3.5">
              <ShieldCheck size={26} />
            </div>
            <div className="mt-3.5 text-[36px] font-semibold tracking-[-0.03em] text-paper">
              {scoreBand(credential.score)} Band
            </div>
            <div className="mt-1 text-[13px] text-muted">
              {formatPeriod(credential.periodStart, credential.periodEnd)} ·{" "}
              {credential.mode}
            </div>
          </div>

          <div className="relative -mt-5 rounded-t-[2rem] bg-white px-6 pb-6 pt-6">
            <div className="grid grid-cols-3 divide-x divide-line/75 text-center">
              <ProofMetric value={`${scoreBand(credential.score)} Band`} label="Safety tier" accent />
              <ProofMetric value={String(credential.score)} label="Out of 100" />
              <ProofMetric value={`${credential.rideCount} rides`} label={`${credential.eventCount} moments`} />
            </div>

            <div className="mt-5 border-t border-line/75 pt-4">
              <div className="flex items-center justify-between gap-3">
                <div className="flex items-center gap-2.5">
                  <div className="ios-icon-circle h-8 w-8">
                    <ShieldCheck size={14} />
                  </div>
                  <div>
                    <div className="text-[13px] font-medium text-paper">
                      Signed by {credential.issuer}
                    </div>
                    <div className="text-[11px] text-muted">
                      Key {credential.publicKeyId} · Ed25519
                    </div>
                  </div>
                </div>
                <span className="rounded-full bg-sky-soft px-2.5 py-1 text-[11px] font-medium text-sky-deep">
                  Verifiable
                </span>
              </div>
            </div>

            <div className="mt-4 flex items-center justify-between border-t border-line/75 pt-4 text-[11px] text-subtle">
              <span>No raw GPS shared</span>
              <span>{credential.rideCount} eligible rides</span>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}

function ProofMetric({
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
      <div className={`text-[18px] font-semibold tracking-tight ${accent ? "text-sky-deep" : "text-paper"}`}>
        {value}
      </div>
      <div className="mt-0.5 text-[11px] text-muted">{label}</div>
    </div>
  );
}
