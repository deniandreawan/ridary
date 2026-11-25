import type { ReactNode } from "react";

export function PhoneFrame({
  src,
  alt,
  children,
  className = ""
}: {
  src?: string;
  alt?: string;
  children?: ReactNode;
  className?: string;
}) {
  return (
    <div
      className={`relative rounded-[2.6rem] border border-line bg-white p-2 shadow-[0_24px_60px_rgba(23,23,23,0.14)] ${className}`}
      style={{ aspectRatio: "9 / 19.2" }}
    >
      <div className="relative h-full overflow-hidden rounded-[2rem] bg-canvas-soft">
        {children ?? (
          <img
            src={src}
            alt={alt ?? "Ridary app screen"}
            className="h-full w-full object-cover object-top"
            loading="eager"
          />
        )}
        <div className="pointer-events-none absolute left-1/2 top-2 h-4 w-16 -translate-x-1/2 rounded-full bg-paper/80" />
      </div>
    </div>
  );
}
