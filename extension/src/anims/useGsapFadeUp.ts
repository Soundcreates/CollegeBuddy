import { useLayoutEffect } from "react";
import gsap from "gsap";

export const useGsapFadeUp = (target: React.RefObject<HTMLElement | null>) => {
  useLayoutEffect(() => {
    if (!target.current) return;

    const el = target.current;

    gsap.from(el, {
      opacity: 0,
      y: 30,
      duration: 0.8,
      ease: "power3.out",
    });

  }, [target]);
};
