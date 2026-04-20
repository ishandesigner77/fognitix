import { MenuBar } from "../components/chrome/MenuBar";
import { StatusStrip } from "../components/chrome/StatusStrip";
import { ToolRail } from "../components/chrome/ToolRail";
import { InspectorPanel } from "../components/panels/InspectorPanel";
import { ProjectPanel } from "../components/panels/ProjectPanel";
import { TimelineWorkspace } from "../components/timeline/TimelineWorkspace";
import { CompositionViewer } from "../components/viewer/CompositionViewer";
import styles from "./AppShell.module.css";

type Props = {
  engineStatus: string;
  engineDetail: string;
  onEngineRetest: () => void;
};

export function AppShell({ engineStatus, engineDetail, onEngineRetest }: Props) {
  return (
    <div className={styles.shell}>
      <MenuBar engineStatus={engineStatus} engineDetail={engineDetail} />
      <div className={styles.body}>
        <ToolRail />
        <div className={styles.workspace}>
          <div className={styles.upper}>
            <div className={styles.colProject}>
              <ProjectPanel />
            </div>
            <div className={styles.colCenter}>
              <CompositionViewer />
            </div>
            <div className={styles.colRight}>
              <InspectorPanel engineDetail={engineDetail} onRetest={onEngineRetest} />
            </div>
          </div>
          <TimelineWorkspace />
        </div>
      </div>
      <StatusStrip left="Ready" right="Desktop shell · engine IPC" />
    </div>
  );
}
