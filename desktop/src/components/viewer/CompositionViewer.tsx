import { PanelFrame } from "../panels/PanelFrame";
import { TransportBar } from "./TransportBar";
import styles from "./CompositionViewer.module.css";

export function CompositionViewer() {
  return (
    <PanelFrame
      title="Composition"
      tabs={[
        { id: "comp", label: "Comp 1" },
        { id: "layer", label: "Layer" },
      ]}
      activeTab="comp"
      right={<span className={styles.meta}>1920 × 1080 · 24 fps</span>}
    >
      <div className={styles.stack}>
        <div className={styles.stage}>
          <div className={styles.letterbox}>
            <div className={styles.grid} aria-hidden />
            <p className={styles.hint}>GPU preview / engine frame buffer</p>
          </div>
        </div>
        <TransportBar timecode="00:00:00:00" />
      </div>
    </PanelFrame>
  );
}
