import { PanelFrame } from "./PanelFrame";
import styles from "./InspectorPanel.module.css";

type Props = {
  engineDetail: string;
  onRetest: () => void;
};

export function InspectorPanel({ engineDetail, onRetest }: Props) {
  return (
    <PanelFrame
      title="Effect Controls"
      tabs={[
        { id: "fx", label: "Effect Controls" },
        { id: "align", label: "Align" },
      ]}
      activeTab="fx"
    >
      <div className={styles.wrap}>
        <div className={styles.group}>
          <div className={styles.groupHead}>Engine bridge</div>
          <div className={styles.row}>
            <span className={styles.label}>Status</span>
            <button type="button" className={styles.link} onClick={onRetest}>
              Ping again
            </button>
          </div>
          <pre className={styles.pre}>{engineDetail || "—"}</pre>
        </div>
        <div className={styles.group}>
          <div className={styles.groupHead}>Transform</div>
          <div className={styles.prop}>
            <span className={styles.pLabel}>Anchor Point</span>
            <span className={styles.pValue}>960.0, 540.0</span>
          </div>
          <div className={styles.prop}>
            <span className={styles.pLabel}>Position</span>
            <span className={styles.pValue}>960.0, 540.0</span>
          </div>
          <div className={styles.prop}>
            <span className={styles.pLabel}>Scale</span>
            <span className={styles.pValue}>100.0, 100.0%</span>
          </div>
        </div>
      </div>
    </PanelFrame>
  );
}
