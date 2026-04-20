import styles from "./ToolRail.module.css";

const TOOLS = [
  { id: "selection", label: "Selection", hotkey: "V" },
  { id: "hand", label: "Hand", hotkey: "H" },
  { id: "zoom", label: "Zoom", hotkey: "Z" },
  { id: "rotation", label: "Rotation", hotkey: "W" },
  { id: "pen", label: "Pen", hotkey: "G" },
  { id: "text", label: "Text", hotkey: "T" },
] as const;

export function ToolRail() {
  return (
    <aside className={styles.rail} aria-label="Tools">
      {TOOLS.map((t, i) => (
        <button
          key={t.id}
          type="button"
          className={`${styles.tool} ${i === 0 ? styles.toolActive : ""}`}
          title={`${t.label} (${t.hotkey})`}
        >
          <span className={styles.hotkey}>{t.hotkey}</span>
        </button>
      ))}
      <div className={styles.spacer} />
    </aside>
  );
}
