import { GLib, readFileAsync } from "astal";

interface nix {
  show_clipboard: string;
  wifi_menu: string;
  bluetooth_menu: string;
  record: string;
}
export const nix: nix = JSON.parse(
  // FIXME: no hardcode wumpus >:(
  await readFileAsync(`${GLib.getenv("HOME")}.local/share/ags/nix.json`),
);

export type audioFormFactor =
  | "internal"
  | "speaker"
  | "handset"
  | "tv"
  | "webcam"
  | "microphone"
  | "headset"
  | "headphone"
  | "hands-free"
  | "car"
  | "hifi"
  | "computer"
  | "portable"
  | "unknown";
