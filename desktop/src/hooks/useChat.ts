import { useCallback, useRef, useState } from "react";
import { engineChat } from "../engine";

export type ChatMessage = { role: "user" | "assistant" | "system"; text: string; at: number };

export function useChat() {
  const [messages, setMessages] = useState<ChatMessage[]>([
    { role: "system", text: "AI panel: messages go through the C++ engine sidecar (`chat`).", at: Date.now() },
  ]);
  const [pending, setPending] = useState(false);
  const busy = useRef(false);

  const send = useCallback(async (text: string) => {
    const trimmed = text.trim();
    if (!trimmed || busy.current) return;
    busy.current = true;
    const at = Date.now();
    setMessages((m) => [...m, { role: "user", text: trimmed, at }]);
    setPending(true);
    try {
      const raw = await engineChat(at, trimmed);
      const parsed = JSON.parse(raw) as { id?: number; result?: { role?: string; text?: string }; error?: unknown };
      const reply =
        parsed.result?.text ??
        (parsed.error ? `Engine error: ${JSON.stringify(parsed.error)}` : raw);
      setMessages((m) => [...m, { role: "assistant", text: String(reply), at: Date.now() }]);
    } catch (e) {
      setMessages((m) => [
        ...m,
        { role: "assistant", text: e instanceof Error ? e.message : String(e), at: Date.now() },
      ]);
    } finally {
      busy.current = false;
      setPending(false);
    }
  }, []);

  return { messages, send, pending };
}
