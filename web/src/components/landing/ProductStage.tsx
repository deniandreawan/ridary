import { ShieldCheck, Smartphone } from "lucide-react";
import { motion, useReducedMotion } from "motion/react";
import { demoRides } from "../../data/demo";
import { formatDistance } from "../../lib/format";
import { RouteArt } from "../RouteArt";
import { PhoneFrame } from "./PhoneFrame";
import { PhoneHomePreview } from "./PhoneHomePreview";

const sampleRide = demoRides[0]!;

export function ProductStage() {
  const reduce = useReducedMotion();

  return (
    <div className="relative mx-auto w-full max-w-[560px] pb-20 pt-2 sm:min-h-[540px] sm:pb-10">
      <div className="pointer-events-none absolute -right-10 -top-4 h-60 w-60 rounded-full bg-sky-soft/75 blur-3xl" />
      <div className="pointer-events-none absolute bottom-10 left-6 h-40 w-40 rounded-full bg-sky-soft/55 blur-3xl" />

      <motion.div
        initial={reduce ? false : { opacity: 0, y: 18, scale: 0.985 }}
        animate={{ opacity: 1, y: 0, scale: 1 }}
        transition={{ duration: 0.7, delay: 0.1, ease: [0.16, 1, 0.3, 1] }}
        className="relative z-10 ml-auto w-full overflow-hidden rounded-[1.75rem] border border-line bg-white shadow-[0_22px_60px_rgba(23,23,23,0.1)] sm:w-[92%]"
      >
        <div className="relative h-[270px] overflow-hidden bg-sky-soft/35 sm:h-[350px]">
          <RouteArt
            route={sampleRide.routePreview}
            className="absolute inset-0 h-full w-full"
          />
          <div className="absolute left-4 top-4 inline-flex items-center gap-1.5 rounded-full bg-white/88 px-2.5 py-1 text-[11px] font-medium text-sky-deep backdrop-blur-md">
            <Smartphone size={11} />
            Sample map
          </div>
          <div className="absolute right-4 top-4 rounded-full bg-white/90 px-2.5 py-1 text-[11px] font-semibold text-sky-deep shadow-sm backdrop-blur-md">
            84 · B Band
          </div>
          <div className="absolute bottom-4 left-4 inline-flex items-center gap-1.5 rounded-full bg-white/82 px-2.5 py-1 text-[11px] font-medium text-muted backdrop-blur-md">
            <ShieldCheck size={11} className="text-sky" />
            Private snapshot
          </div>
        </div>
      </motion.div>

      <motion.div
        initial={reduce ? false : { opacity: 0, y: 26 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8, delay: 0.26, ease: [0.16, 1, 0.3, 1] }}
        className="absolute -bottom-1 left-0 z-20 hidden w-[39%] max-w-[196px] sm:block"
      >
        <motion.div
          animate={reduce ? undefined : { y: [0, -6, 0] }}
          transition={
            reduce ? undefined : { duration: 6, repeat: Infinity, ease: "easeInOut" }
          }
        >
          <PhoneFrame>
            <PhoneHomePreview />
          </PhoneFrame>
        </motion.div>
      </motion.div>

      <motion.div
        initial={reduce ? false : { opacity: 0, x: 14 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ duration: 0.7, delay: 0.4, ease: [0.16, 1, 0.3, 1] }}
        className="absolute bottom-1 right-0 z-30 w-[62%] max-w-[248px] rounded-2xl border border-white/80 bg-white/85 p-3.5 shadow-[0_14px_34px_rgba(23,23,23,0.1)] backdrop-blur-xl sm:bottom-3"
      >
        <div className="text-[11px] font-medium text-sky-deep">This week</div>
        <div className="mt-1 text-[24px] font-semibold tracking-[-0.03em] text-paper">
          {formatDistance(27_800)}
        </div>
        <div className="mt-0.5 text-[11px] text-muted">3 rides · 84 avg safety</div>
        <div className="mt-2.5 flex items-center justify-between gap-2">
          <span className="text-[11px] font-medium text-paper">B Band</span>
          <span className="rounded-full bg-sky-soft px-2 py-0.5 text-[10px] font-medium text-sky-deep">
            Sample
          </span>
        </div>
      </motion.div>
    </div>
  );
}
