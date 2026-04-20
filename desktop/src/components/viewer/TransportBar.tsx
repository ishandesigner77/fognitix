import type { ReactNode } from "react";
import styles from "./TransportBar.module.css";

function Icon({ children }: { children: ReactNode }) {
  return (
    <svg className={styles.svg} viewBox="0 0 16 16" aria-hidden>
      {children}
    </svg>
  );
}

type Props = {
  timecode: string;
};

export function TransportBar({ timecode }: Props) {
  return (
    <div className={styles.bar}>
      <div className={styles.group}>
        <button type="button" className={styles.btn} title="Go to start">
          <Icon>
            <path fill="currentColor" d="M2 3h2v10H2V3zm3.5 5L12 13V3L5.5 8z" />
          </Icon>
        </button>
        <button type="button" className={styles.btn} title="Step back">
          <Icon>
            <path fill="currentColor" d="M9 3h2v10H9V5.5L4 8l5 2.5V3z" />
          </Icon>
        </button>
        <button type="button" className={`${styles.btn} ${styles.play}`} title="Play / Pause">
          <Icon>
            <path fill="currentColor" d="M4 3l10 5-10 5V3z" />
          </Icon>
        </button>
        <button type="button" className={styles.btn} title="Step forward">
          <Icon>
            <path fill="currentColor" d="M5 3h2v4.5L12 3v10l-5-4.5V13H5V3z" />
          </Icon>
        </button>
        <button type="button" className={styles.btn} title="Go to end">
          <Icon>
            <path fill="currentColor" d="M4 3h2v10H4V3zm3.5 5L11 3v10L7.5 8z" />
          </Icon>
        </button>
      </div>
      <div className={styles.tc} aria-live="polite">
        {timecode}
      </div>
    </div>
  );
}
