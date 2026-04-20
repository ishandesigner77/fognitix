import type { ReactNode } from "react";
import styles from "./PanelFrame.module.css";

type Tab = { id: string; label: string };

type Props = {
  title: string;
  tabs?: Tab[];
  activeTab?: string;
  right?: ReactNode;
  children: ReactNode;
  className?: string;
};

export function PanelFrame({ title, tabs, activeTab, right, children, className }: Props) {
  return (
    <section className={`${styles.panel} ${className ?? ""}`}>
      <header className={styles.head}>
        <span className={styles.title}>{title}</span>
        {tabs?.map((t) => (
          <span key={t.id} className={`${styles.tab} ${activeTab === t.id ? styles.tabOn : ""}`} role="tab" aria-selected={activeTab === t.id}>
            {t.label}
          </span>
        ))}
        {right ? <div className={styles.right}>{right}</div> : null}
      </header>
      <div className={styles.body}>{children}</div>
    </section>
  );
}
