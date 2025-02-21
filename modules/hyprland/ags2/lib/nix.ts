import { readFileAsync } from "astal";

interface nix {
  show_clipboard: string;
  wifi_menu: string;
  bluetooth_menu: string;
}
export const nix: nix = JSON.parse(
  // FIXME: no hardcode wumpus >:(
  await readFileAsync(`/home/wumpus/.local/share/ags/nix.json`),
);
