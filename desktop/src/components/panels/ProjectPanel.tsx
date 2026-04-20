import { Icon } from "../icons/Icon";
import { PanelFrame } from "./PanelFrame";
import styles from "./ProjectPanel.module.css";

const FAKE_ROWS = ["Compositions", "Solids", "Footage", "Fonts", "Scripts"] as const;

export function ProjectPanel() {
  return (
    <PanelFrame
      title="Project"
      tabs={[
        { id: "project", label: "Project" },
        { id: "effects", label: "Effects & Presets" },
      ]}
      activeTab="project"
    >
      <div className={styles.wrap}>
        <div className={styles.treeHeader}>
          <span className={styles.colName}>Name</span>
          <span className={styles.colType}>Type</span>
        </div>
        <ul className={styles.tree} role="tree">
          {FAKE_ROWS.map((name, i) => (
            <li key={name} className={`${styles.row} ${i === 0 ? styles.rowSel : ""}`} role="treeitem">
              <span className={styles.chev} aria-hidden>
                ▸
              </span>
              <span className={styles.nameCell}>
                <Icon name="folder" size={12} className={styles.folder} />
                <span className={styles.name}>{name}</span>
              </span>
              <span className={styles.type}>Folder</span>
            </li>
          ))}
        </ul>
      </div>
    </PanelFrame>
  );
}
