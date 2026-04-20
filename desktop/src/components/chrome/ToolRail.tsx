import type { IconName } from "../icons/Icon";
import { Icon } from "../icons/Icon";
import styles from "./ToolRail.module.css";

const TOOLS: readonly { id: string; icon: IconName; label: string; hotkey: string }[] = [
  { id: "selection", icon: "cursor", label: "Selection", hotkey: "V" },
  { id: "hand", icon: "hand", label: "Hand", hotkey: "H" },
  { id: "zoom", icon: "zoom", label: "Zoom", hotkey: "Z" },
  { id: "rotation", icon: "rotate", label: "Rotation", hotkey: "W" },
  { id: "pen", icon: "pen", label: "Pen", hotkey: "G" },
  { id: "text", icon: "text", label: "Text", hotkey: "T" },
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
          <Icon name={t.icon} size={15} />
        </button>
      ))}
      <div className={styles.spacer} />
    </aside>
  );
}
