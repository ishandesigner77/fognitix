import { Icon } from "../icons/Icon";
import styles from "./TransportBar.module.css";

type Props = {
  timecode: string;
};

export function TransportBar({ timecode }: Props) {
  return (
    <div className={styles.bar}>
      <div className={styles.group}>
        <button type="button" className={styles.btn} title="Go to start">
          <Icon name="toStart" size={14} />
        </button>
        <button type="button" className={styles.btn} title="Step back">
          <Icon name="stepBack" size={14} />
        </button>
        <button type="button" className={`${styles.btn} ${styles.play}`} title="Play / Pause">
          <Icon name="play" size={14} />
        </button>
        <button type="button" className={styles.btn} title="Step forward">
          <Icon name="stepFwd" size={14} />
        </button>
        <button type="button" className={styles.btn} title="Go to end">
          <Icon name="toEnd" size={14} />
        </button>
      </div>
      <div className={styles.tc} aria-live="polite">
        {timecode}
      </div>
    </div>
  );
}
