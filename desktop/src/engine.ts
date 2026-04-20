import { invoke } from "@tauri-apps/api/core";

export async function engineRequest(request: unknown): Promise<string> {
  const line = JSON.stringify(request);
  return invoke<string>("engine_request", { line });
}
