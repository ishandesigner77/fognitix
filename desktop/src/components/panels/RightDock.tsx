import { useState } from "react";
import type { ChatMessage } from "../../hooks/useChat";
import { ChatPanel } from "./ChatPanel";
import { InspectorPanel } from "./InspectorPanel";
import styles from "./RightDock.module.css";

type Tab = "inspector" | "chat";

type Props = {
  engineDetail: string;
  onRetest: () => void;
  messages: ChatMessage[];
  onChatSend: (text: string) => void;
  chatPending: boolean;
};

export function RightDock({ engineDetail, onRetest, messages, onChatSend, chatPending }: Props) {
  const [tab, setTab] = useState<Tab>("inspector");

  return (
    <section className={styles.dock} aria-label="Right dock">
      <header className={styles.tabs} role="tablist">
        <button
          type="button"
          role="tab"
          aria-selected={tab === "inspector"}
          className={`${styles.tab} ${tab === "inspector" ? styles.tabOn : ""}`}
          onClick={() => setTab("inspector")}
        >
          Effect controls
        </button>
        <button
          type="button"
          role="tab"
          aria-selected={tab === "chat"}
          className={`${styles.tab} ${tab === "chat" ? styles.tabOn : ""}`}
          onClick={() => setTab("chat")}
        >
          AI chat
        </button>
      </header>
      <div className={styles.body} role="tabpanel">
        {tab === "inspector" ? (
          <InspectorPanel frameless engineDetail={engineDetail} onRetest={onRetest} />
        ) : (
          <ChatPanel messages={messages} onSend={onChatSend} pending={chatPending} />
        )}
      </div>
    </section>
  );
}
