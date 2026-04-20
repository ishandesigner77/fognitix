import type { SVGProps } from "react";

export type IconName =
  | "chevronDown"
  | "folder"
  | "search"
  | "chat"
  | "cursor"
  | "hand"
  | "zoom"
  | "pen"
  | "text"
  | "play"
  | "stepBack"
  | "stepFwd"
  | "toStart"
  | "toEnd"
  | "grid"
  | "rotate";

type Props = {
  name: IconName;
  size?: number;
  className?: string;
} & Omit<SVGProps<SVGSVGElement>, "width" | "height" | "viewBox" | "children">;

export function Icon({ name, size = 14, className, ...rest }: Props) {
  const s = size;
  return (
    <svg
      width={s}
      height={s}
      viewBox="0 0 16 16"
      className={className}
      aria-hidden
      focusable="false"
      fill="currentColor"
      {...rest}
    >
      {glyph(name)}
    </svg>
  );
}

function glyph(name: IconName) {
  switch (name) {
    case "chevronDown":
      return <path d="M4 6l4 4 4-4H4z" opacity="0.9" />;
    case "folder":
      return <path d="M2 4h4l1 1h7v8H2V4zm1 2v6h10V7H6.4L5.6 6H3z" />;
    case "search":
      return (
        <>
          <path d="M6.5 2a4.5 4.5 0 013.2 7.7l3.3 3.3-.7.7-3.3-3.3A4.5 4.5 0 116.5 2zm0 1a3.5 3.5 0 100 7 3.5 3.5 0 000-7z" />
        </>
      );
    case "chat":
      return <path d="M2 3h12v8H5l-3 2v-2H2V3zm1 1v6h10V4H3zm2 2h6v1H5V6zm0 2h4v1H5V8z" />;
    case "cursor":
      return <path d="M3 2l7 7-3 1-1 3-1-2-2-1 1-3-1-5z" />;
    case "hand":
      return <path d="M8 2v3h1V3h1v4h1V4h1v5.5c0 1.4-1 2.5-2.3 2.5H7.2C5.7 12 4 10.6 4 9V6h1V5h1V2h2z" />;
    case "zoom":
      return (
        <>
          <path d="M6.5 2a4.5 4.5 0 013.2 7.7l3.3 3.3-.7.7-3.3-3.3A4.5 4.5 0 116.5 2zm0 1a3.5 3.5 0 100 7 3.5 3.5 0 000-7z" />
          <path d="M6 5h1v4H6V5zm-1 2h3v1H5V7z" opacity="0.85" />
        </>
      );
    case "pen":
      return <path d="M11.7 2.3c.4-.4 1-.4 1.4 0l.6.6c.4.4.4 1 0 1.4L6.5 11.5 4 12l.5-2.5 7.2-7.2zM3 13h5v1H3v-1z" />;
    case "text":
      return <path d="M4 3h8v2h-3v8H7V5H4V3z" />;
    case "play":
      return <path d="M5 3l8 5-8 5V3z" />;
    case "stepBack":
      return <path d="M9 3h2v10H9V5.5L4 8l5 2.5V3z" />;
    case "stepFwd":
      return <path d="M5 3h2v4.5L12 3v10l-5-4.5V13H5V3z" />;
    case "toStart":
      return <path d="M2 3h2v10H2V3zm3.5 5L12 13V3L5.5 8z" />;
    case "toEnd":
      return <path d="M4 3h2v10H4V3zm3.5 5L11 3v10L7.5 8z" />;
    case "grid":
      return (
        <>
          <path d="M2 2h5v5H2V2zm7 0h5v5H9V2zM2 9h5v5H2V9zm7 0h5v5H9V9z" opacity="0.85" />
        </>
      );
    case "rotate":
      return <path d="M8 2v2a5 5 0 104.9 4h-2.1l2.5 3 2.5-3H14A7 7 0 118 2z" />;
    default:
      return null;
  }
}
