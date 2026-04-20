import { PanelFrame } from "../panels/PanelFrame";
import styles from "./TimelineWorkspace.module.css";

const TRACKS = [
  { id: "v3", label: "3", kind: "video" as const },
  { id: "v2", label: "2", kind: "video" as const },
  { id: "v1", label: "1", kind: "video" as const },
  { id: "a1", label: "1", kind: "audio" as const },
  { id: "a2", label: "2", kind: "audio" as const },
];

export function TimelineWorkspace() {
  return (
    <PanelFrame title="Timeline" className={styles.panel} activeTab="timeline" tabs={[{ id: "timeline", label: "Standard" }]}>
      <div className={styles.root}>
        <div className={styles.toolbar}>
          <span className={styles.tbLabel}>Composition: Comp 1</span>
          <span className={styles.tbDim}>Work Area</span>
        </div>
        <div className={styles.split}>
          <div className={styles.headers}>
            {TRACKS.map((t) => (
              <div key={t.id} className={`${styles.hcell} ${t.kind === "audio" ? styles.hAudio : ""}`}>
                <span className={styles.hTag}>{t.kind === "video" ? "V" : "A"}</span>
                <span>{t.label}</span>
              </div>
            ))}
          </div>
          <div className={styles.lanes}>
            <div className={styles.ruler} aria-hidden />
            <div className={styles.cti} title="Current time indicator" />
            {TRACKS.map((t) => (
              <div key={t.id} className={styles.lane}>
                {t.id === "v1" ? <div className={styles.clipVideo} /> : null}
                {t.id === "a1" ? <div className={styles.clipAudio} /> : null}
              </div>
            ))}
          </div>
        </div>
      </div>
    </PanelFrame>
  );
}
