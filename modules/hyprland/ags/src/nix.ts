interface nix {
  bun: string;
  show_clipboard: string;
  audio_changer: string;
}
export const nix: nix = JSON.parse(
  Utils.readFile(`/home/${Utils.USER}/.local/share/ags/nix.json`),
);
