import { useId, useState } from "react";
import type { ChatMessage } from "../../hooks/useChat";
import { Icon } from "../icons/Icon";
import styles from "./ChatPanel.module.css";

type Props = {
  messages: ChatMessage[];
  onSend: (text: string) => void;
  pending: boolean;
};

export function ChatPanel({ messages, onSend, pending }: Props) {
  const [draft, setDraft] = useState("");
  const inputId = useId();

  return (
    <div className={styles.root}>
      <div className={styles.head}>
        <Icon name="chat" size={14} />
        <span>AI assistant</span>
        <span className={styles.sub}>C++ sidecar</span>
      </div>
      <div className={styles.thread} role="log" aria-live="polite">
        {messages.map((m, idx) => (
          <div
            key={`${m.at}-${idx}`}
            className={`${styles.bubble} ${m.role === "user" ? styles.user : m.role === "assistant" ? styles.assistant : styles.system}`}
          >
            <div className={styles.role}>{m.role}</div>
            <div className={styles.text}>{m.text}</div>
          </div>
        ))}
      </div>
      <form
        className={styles.composer}
        onSubmit={(e) => {
          e.preventDefault();
          onSend(draft);
          setDraft("");
        }}
      >
        <label className={styles.srOnly} htmlFor={inputId}>
          Message
        </label>
        <textarea
          id={inputId}
          className={styles.input}
          rows={2}
          value={draft}
          placeholder="Ask the engine… (routes to `chat`)"
          onChange={(e) => setDraft(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter" && !e.shiftKey) {
              e.preventDefault();
              onSend(draft);
              setDraft("");
            }
          }}
        />
        <button type="submit" className={styles.send} disabled={pending || !draft.trim()}>
          {pending ? "Sending…" : "Send"}
        </button>
      </form>
    </div>
  );
}
