import { useCallback, useState } from "react";
import { useChat } from "./hooks/useChat";
import { useEngineHealth } from "./hooks/useEngineHealth";
import { AppShell } from "./shell/AppShell";

export default function App() {
  const { status, detail, probe } = useEngineHealth();
  const { messages, send, pending } = useChat();
  const [menuLine, setMenuLine] = useState("Ready");

  const onMenuCommand = useCallback(
    (id: string) => {
      setMenuLine(id);
      if (id === "help.engine") {
        void probe();
      }
    },
    [probe],
  );

  return (
    <AppShell
      engineStatus={status}
      engineDetail={detail}
      onEngineRetest={() => void probe()}
      menuLine={menuLine}
      onMenuCommand={onMenuCommand}
      chatMessages={messages}
      onChatSend={(t) => void send(t)}
      chatPending={pending}
    />
  );
}
