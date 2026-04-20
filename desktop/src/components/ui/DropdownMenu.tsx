import { useCallback, useId, useRef, useState } from "react";
import { useClickOutside } from "../../hooks/useClickOutside";
import { Icon } from "../icons/Icon";
import styles from "./DropdownMenu.module.css";

export type MenuEntry =
  | { type: "item"; id: string; label: string; shortcut?: string; disabled?: boolean }
  | { type: "sep" };

type Props = {
  label: string;
  items: MenuEntry[];
  onPick: (id: string) => void;
};

export function DropdownMenu({ label, items, onPick }: Props) {
  const [open, setOpen] = useState(false);
  const rootRef = useRef<HTMLDivElement>(null);
  const btnId = useId();
  const menuId = `${btnId}-menu`;
  const close = useCallback(() => setOpen(false), []);

  useClickOutside(rootRef, close, open);

  return (
    <div className={styles.root} ref={rootRef}>
      <button
        id={btnId}
        type="button"
        className={`${styles.trigger} ${open ? styles.triggerOn : ""}`}
        aria-haspopup="menu"
        aria-expanded={open}
        aria-controls={menuId}
        onClick={() => setOpen((v) => !v)}
      >
        <span>{label}</span>
        <Icon name="chevronDown" size={10} className={styles.chev} />
      </button>
      {open ? (
        <div id={menuId} className={styles.menu} role="menu" aria-labelledby={btnId}>
          {items.map((it, idx) =>
            it.type === "sep" ? (
              <div key={`sep-${idx}`} className={styles.sep} role="separator" />
            ) : (
              <button
                key={it.id}
                type="button"
                role="menuitem"
                className={styles.item}
                disabled={it.disabled}
                onClick={() => {
                  if (it.disabled) return;
                  onPick(it.id);
                  close();
                }}
              >
                <span className={styles.itemLabel}>{it.label}</span>
                {it.shortcut ? <span className={styles.shortcut}>{it.shortcut}</span> : null}
              </button>
            ),
          )}
        </div>
      ) : null}
    </div>
  );
}
