import { DropdownMenu } from "../ui/DropdownMenu";
import {
  ANIM_MENU,
  COMP_MENU,
  EDIT_MENU,
  EFFECT_MENU,
  FILE_MENU,
  HELP_MENU,
  LAYER_MENU,
  VIEW_MENU,
  WINDOW_MENU,
} from "./menuModel";
import styles from "./MenuBar.module.css";

type Props = {
  engineStatus: string;
  engineDetail: string;
  onMenuCommand: (id: string) => void;
};

export function MenuBar({ engineStatus, engineDetail, onMenuCommand }: Props) {
  const dot =
    engineStatus.includes("online") ? styles.dotOk : engineStatus.includes("offline") ? styles.dotBad : "";

  return (
    <header className={styles.bar}>
      <div className={styles.brand}>Fognitix</div>
      <nav className={styles.menus} aria-label="Application menu">
        <DropdownMenu label="File" items={FILE_MENU} onPick={onMenuCommand} />
        <DropdownMenu label="Edit" items={EDIT_MENU} onPick={onMenuCommand} />
        <DropdownMenu label="Composition" items={COMP_MENU} onPick={onMenuCommand} />
        <DropdownMenu label="Layer" items={LAYER_MENU} onPick={onMenuCommand} />
        <DropdownMenu label="Effect" items={EFFECT_MENU} onPick={onMenuCommand} />
        <DropdownMenu label="Animation" items={ANIM_MENU} onPick={onMenuCommand} />
        <DropdownMenu label="View" items={VIEW_MENU} onPick={onMenuCommand} />
        <DropdownMenu label="Window" items={WINDOW_MENU} onPick={onMenuCommand} />
        <DropdownMenu label="Help" items={HELP_MENU} onPick={onMenuCommand} />
      </nav>
      <div className={styles.flex} />
      <div className={styles.searchWrap}>
        <input className={styles.search} type="search" placeholder="Search (bins, effects, properties)…" />
      </div>
      <div className={styles.engine} title={engineDetail}>
        <span className={`${styles.dot} ${dot}`} aria-hidden />
        <span className={styles.engineText}>{engineStatus}</span>
      </div>
    </header>
  );
}
