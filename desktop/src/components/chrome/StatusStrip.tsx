import styles from "./StatusStrip.module.css";

type Props = {
  left: string;
  right: string;
};

export function StatusStrip({ left, right }: Props) {
  return (
    <footer className={styles.bar}>
      <span>{left}</span>
      <span className={styles.sep} aria-hidden>
        |
      </span>
      <span className={styles.dim}>{right}</span>
    </footer>
  );
}
