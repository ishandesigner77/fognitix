import { useEngineHealth } from "./hooks/useEngineHealth";
import { AppShell } from "./shell/AppShell";

export default function App() {
  const { status, detail, probe } = useEngineHealth();
  return <AppShell engineStatus={status} engineDetail={detail} onEngineRetest={() => void probe()} />;
}
