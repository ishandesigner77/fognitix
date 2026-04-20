import { invoke } from "@tauri-apps/api/core";

export async function engineRequest(request: unknown): Promise<string> {
  const line = JSON.stringify(request);
  return invoke<string>("engine_request", { line });
}

/** Chat / command text routed through the C++ sidecar (`chat` method). */
export async function engineChat(id: number, text: string): Promise<string> {
  return engineRequest({ id, method: "chat", text });
}
