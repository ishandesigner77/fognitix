import styles from "./MenuBar.module.css";

const MENUS = ["File", "Edit", "Composition", "Layer", "Effect", "Animation", "View", "Window", "Help"] as const;

type Props = {
  engineStatus: string;
  engineDetail: string;
};

export function MenuBar({ engineStatus, engineDetail }: Props) {
  const dot =
    engineStatus.includes("online") ? styles.dotOk : engineStatus.includes("offline") ? styles.dotBad : "";

  return (
    <header className={styles.bar}>
      <div className={styles.brand}>Fognitix</div>
      <nav className={styles.menus} aria-label="Application menu">
        {MENUS.map((m) => (
          <button key={m} type="button" className={styles.menuItem}>
            {m}
          </button>
        ))}
      </nav>
      <div className={styles.flex} />
      <div className={styles.searchWrap}>
        <input className={styles.search} type="search" placeholder="Search (bins, effects, properties)…" />
      </div>
      <div className={styles.engine} title={engineDetail}>
        <span className={`${styles.dot} ${dot}`} aria-hidden />
        <span className={styles.engineText}>{engineStatus}</span>
      </div>
    </header>
  );
}
