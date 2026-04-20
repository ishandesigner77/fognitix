import { useCallback, useEffect, useState } from "react";
import { engineRequest } from "../engine";

type EngineLine = { id: number; result?: unknown; error?: unknown };

function parseEngineResponse(raw: string): EngineLine {
  try {
    return JSON.parse(raw) as EngineLine;
  } catch {
    return { id: 0, error: { message: "invalid JSON from engine" } };
  }
}

export function useEngineHealth() {
  const [status, setStatus] = useState("Connecting…");
  const [detail, setDetail] = useState("");

  const probe = useCallback(async () => {
    setStatus("Connecting…");
    setDetail("");
    try {
      const rawPing = await engineRequest({ id: 1, method: "ping" });
      const ping = parseEngineResponse(rawPing);
      if (ping.error) {
        setStatus("Engine error");
        setDetail(JSON.stringify(ping.error));
        return;
      }
      const rawVer = await engineRequest({ id: 2, method: "version" });
      const ver = parseEngineResponse(rawVer);
      setStatus("Engine online");
      setDetail(JSON.stringify(ver.result ?? ver, null, 2));
    } catch (e) {
      setStatus("Engine offline");
      setDetail(e instanceof Error ? e.message : String(e));
    }
  }, []);

  useEffect(() => {
    void probe();
  }, [probe]);

  return { status, detail, probe };
}
