import type { LucideIcon } from "lucide-react";

export function StatCard({
  label,
  value,
  hint,
  icon: Icon,
  tone = "text-paper"
}: {
  label: string;
  value: string;
  hint?: string;
  icon: LucideIcon;
  tone?: string;
}) {
  return (
    <div className="surface-soft flex flex-col gap-3 p-4">
      <div className="flex items-center justify-between">
        <span className="mono-label">{label}</span>
        <Icon size={15} className={tone} strokeWidth={1.8} />
      </div>
      <div className={`font-mono text-2xl font-semibold ${tone}`}>{value}</div>
      {hint && <div className="text-[11px] leading-snug text-muted">{hint}</div>}
    </div>
  );
}
