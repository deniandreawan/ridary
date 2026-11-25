import { ArrowUpRight, Menu, X } from "lucide-react";
import { AnimatePresence, motion, useReducedMotion } from "motion/react";
import { useState } from "react";
import { Link } from "react-router-dom";
import { Logo } from "../Logo";

const LINKS = [
  { href: "#how", label: "Product" },
  { href: "#privacy", label: "Privacy" },
  { href: "#proof", label: "Proof" }
];

export function LandingNav() {
  const [open, setOpen] = useState(false);
  const reduce = useReducedMotion();

  return (
    <header className="sticky top-0 z-40 border-b border-line/70 bg-white/82 backdrop-blur-xl">
      <div className="mx-auto flex h-16 max-w-[1320px] items-center justify-between gap-4 px-4 sm:px-6">
        <Link to="/" className="focus-ring rounded-full" aria-label="Ridary home">
          <Logo />
        </Link>

        <nav className="hidden items-center gap-7 md:flex">
          {LINKS.map((link) => (
            <a
              key={link.href}
              href={link.href}
              className="focus-ring text-[13px] font-medium text-muted transition hover:text-paper"
            >
              {link.label}
            </a>
          ))}
        </nav>

        <div className="hidden items-center gap-2.5 md:flex">
          <Link
            to="/login"
            className="focus-ring rounded-full px-3 py-1.5 text-[13px] font-medium text-muted transition hover:text-paper"
          >
            Sign in
          </Link>
          <a
            href="/app?demo=1"
            className="btn-glass-sky focus-ring px-4 py-2 text-[13px]"
          >
            Open live demo
            <ArrowUpRight size={14} />
          </a>
        </div>

        <button
          type="button"
          onClick={() => setOpen((value) => !value)}
          className="btn-glass focus-ring h-9 w-9 p-0 md:hidden"
          aria-label={open ? "Close menu" : "Open menu"}
          aria-expanded={open}
        >
          {open ? <X size={17} /> : <Menu size={17} />}
        </button>
      </div>

      <AnimatePresence initial={false}>
        {open && (
          <motion.div
            initial={reduce ? false : { opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: "auto" }}
            exit={{ opacity: 0, height: 0 }}
            transition={{ duration: 0.22, ease: [0.16, 1, 0.3, 1] }}
            className="overflow-hidden border-t border-line/60 bg-white md:hidden"
          >
            <div className="space-y-1 px-4 py-4">
              {LINKS.map((link) => (
                <a
                  key={link.href}
                  href={link.href}
                  onClick={() => setOpen(false)}
                  className="focus-ring block rounded-xl px-3 py-2.5 text-[14px] font-medium text-paper hover:bg-canvas-soft"
                >
                  {link.label}
                </a>
              ))}
              <Link
                to="/login"
                onClick={() => setOpen(false)}
                className="focus-ring block rounded-xl px-3 py-2.5 text-[14px] font-medium text-paper hover:bg-canvas-soft"
              >
                Sign in
              </Link>
              <a
                href="/app?demo=1"
                className="btn-glass-sky focus-ring mt-2 w-full px-4 py-2.5 text-[13px]"
              >
                Open live demo
                <ArrowUpRight size={14} />
              </a>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </header>
  );
}
