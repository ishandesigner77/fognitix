import type { MenuEntry } from "../ui/DropdownMenu";

export const FILE_MENU: MenuEntry[] = [
  { type: "item", id: "file.new.project", label: "New Project…", shortcut: "Ctrl+Alt+N" },
  { type: "item", id: "file.new.comp", label: "New Composition…", shortcut: "Ctrl+N" },
  { type: "sep" },
  { type: "item", id: "file.open.project", label: "Open Project…", shortcut: "Ctrl+O" },
  { type: "item", id: "file.open.recent", label: "Open Recent", shortcut: "" },
  { type: "sep" },
  { type: "item", id: "file.save", label: "Save", shortcut: "Ctrl+S" },
  { type: "item", id: "file.save.as", label: "Save As…", shortcut: "Ctrl+Shift+S" },
  { type: "sep" },
  { type: "item", id: "file.import", label: "Import…", shortcut: "Ctrl+I" },
  { type: "item", id: "file.export", label: "Export…", shortcut: "Ctrl+M" },
  { type: "sep" },
  { type: "item", id: "file.quit", label: "Quit", shortcut: "Alt+F4" },
];

export const EDIT_MENU: MenuEntry[] = [
  { type: "item", id: "edit.undo", label: "Undo", shortcut: "Ctrl+Z" },
  { type: "item", id: "edit.redo", label: "Redo", shortcut: "Ctrl+Shift+Z" },
  { type: "sep" },
  { type: "item", id: "edit.cut", label: "Cut", shortcut: "Ctrl+X" },
  { type: "item", id: "edit.copy", label: "Copy", shortcut: "Ctrl+C" },
  { type: "item", id: "edit.paste", label: "Paste", shortcut: "Ctrl+V" },
  { type: "sep" },
  { type: "item", id: "edit.prefs", label: "Preferences…", shortcut: "Ctrl+," },
];

export const COMP_MENU: MenuEntry[] = [
  { type: "item", id: "comp.settings", label: "Composition Settings…", shortcut: "Ctrl+K" },
  { type: "item", id: "comp.clean", label: "Clean Preview Cache", shortcut: "" },
  { type: "sep" },
  { type: "item", id: "comp.preview", label: "Preview", shortcut: "0" },
  { type: "item", id: "comp.ram", label: "RAM Preview", shortcut: "0 (numpad)" },
];

export const LAYER_MENU: MenuEntry[] = [
  { type: "item", id: "layer.new", label: "New", shortcut: "Ctrl+Alt+Shift+N" },
  { type: "item", id: "layer.precomp", label: "Pre-compose…", shortcut: "Ctrl+Shift+C" },
  { type: "sep" },
  { type: "item", id: "layer.split", label: "Split", shortcut: "Ctrl+Shift+D" },
];

export const EFFECT_MENU: MenuEntry[] = [
  { type: "item", id: "fx.browser", label: "Effects & Presets", shortcut: "" },
  { type: "item", id: "fx.reset", label: "Reset", shortcut: "" },
  { type: "sep" },
  { type: "item", id: "fx.expression", label: "Add Expression", shortcut: "Alt+Shift+=" },
];

export const ANIM_MENU: MenuEntry[] = [
  { type: "item", id: "anim.keyframe", label: "Keyframe Assistant", shortcut: "" },
  { type: "item", id: "anim.graph", label: "Graph Editor", shortcut: "" },
];

export const VIEW_MENU: MenuEntry[] = [
  { type: "item", id: "view.zoom.in", label: "Zoom In", shortcut: "=" },
  { type: "item", id: "view.zoom.out", label: "Zoom Out", shortcut: "-" },
  { type: "item", id: "view.zoom.fit", label: "Fit", shortcut: "/" },
  { type: "sep" },
  { type: "item", id: "view.grid", label: "Show Grid", shortcut: "Ctrl+'" },
  { type: "item", id: "view.guides", label: "Show Guides", shortcut: "Ctrl+;" },
];

export const WINDOW_MENU: MenuEntry[] = [
  { type: "item", id: "win.workspace.default", label: "Workspace: Default", shortcut: "" },
  { type: "item", id: "win.workspace.reset", label: "Reset Panels", shortcut: "Alt+Shift+0" },
  { type: "sep" },
  { type: "item", id: "win.float", label: "Float Active Panel", shortcut: "Ctrl+\\" },
];

export const HELP_MENU: MenuEntry[] = [
  { type: "item", id: "help.docs", label: "Documentation", shortcut: "F1" },
  { type: "item", id: "help.engine", label: "Engine diagnostics", shortcut: "" },
  { type: "sep" },
  { type: "item", id: "help.about", label: "About Fognitix", shortcut: "" },
];
