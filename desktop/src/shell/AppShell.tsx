import { MenuBar } from "../components/chrome/MenuBar";
import { StatusStrip } from "../components/chrome/StatusStrip";
import { ToolRail } from "../components/chrome/ToolRail";
import type { ChatMessage } from "../hooks/useChat";
import { ProjectPanel } from "../components/panels/ProjectPanel";
import { RightDock } from "../components/panels/RightDock";
import { TimelineWorkspace } from "../components/timeline/TimelineWorkspace";
import { CompositionViewer } from "../components/viewer/CompositionViewer";
import styles from "./AppShell.module.css";

type Props = {
  engineStatus: string;
  engineDetail: string;
  onEngineRetest: () => void;
  menuLine: string;
  onMenuCommand: (id: string) => void;
  chatMessages: ChatMessage[];
  onChatSend: (text: string) => void;
  chatPending: boolean;
};

export function AppShell({
  engineStatus,
  engineDetail,
  onEngineRetest,
  menuLine,
  onMenuCommand,
  chatMessages,
  onChatSend,
  chatPending,
}: Props) {
  return (
    <div className={styles.shell}>
      <MenuBar engineStatus={engineStatus} engineDetail={engineDetail} onMenuCommand={onMenuCommand} />
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
              <RightDock
                engineDetail={engineDetail}
                onRetest={onEngineRetest}
                messages={chatMessages}
                onChatSend={onChatSend}
                chatPending={chatPending}
              />
            </div>
          </div>
          <TimelineWorkspace />
        </div>
      </div>
      <StatusStrip left={menuLine} right="Desktop shell · engine IPC (`ping`, `version`, `chat`)" />
    </div>
  );
}
