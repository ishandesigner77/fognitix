import { useState } from "react";
import { Icon } from "../icons/Icon";
import { PanelFrame } from "../panels/PanelFrame";
import { TransportBar } from "./TransportBar";
import styles from "./CompositionViewer.module.css";

const PRESETS = [
  { id: "hd24", label: "1920 × 1080 · 24 fps" },
  { id: "hd30", label: "1920 × 1080 · 30 fps" },
  { id: "uhd24", label: "3840 × 2160 · 24 fps" },
  { id: "sq1080", label: "1080 × 1080 · 30 fps" },
] as const;

export function CompositionViewer() {
  const [preset, setPreset] = useState<string>(PRESETS[0].id);
  const label = PRESETS.find((p) => p.id === preset)?.label ?? PRESETS[0].label;

  return (
    <PanelFrame
      title="Composition"
      tabs={[
        { id: "comp", label: "Comp 1" },
        { id: "layer", label: "Layer" },
      ]}
      activeTab="comp"
      right={
        <div className={styles.presetWrap}>
          <Icon name="grid" size={12} className={styles.presetIcon} />
          <label className={styles.srOnly} htmlFor="comp-preset">
            Composition preset
          </label>
          <select id="comp-preset" className={styles.select} value={preset} onChange={(e) => setPreset(e.target.value)}>
            {PRESETS.map((p) => (
              <option key={p.id} value={p.id}>
                {p.label}
              </option>
            ))}
          </select>
        </div>
      }
    >
      <div className={styles.stack}>
        <div className={styles.stage}>
          <div className={styles.letterbox}>
            <div className={styles.grid} aria-hidden />
            <p className={styles.hint}>
              Preview · <span className={styles.hintStrong}>{label}</span>
            </p>
          </div>
        </div>
        <TransportBar timecode="00:00:00:00" />
      </div>
    </PanelFrame>
  );
}
