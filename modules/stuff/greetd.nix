# shamelessly stolen from https://gitlab.com/fazzi/nixohess/-/blob/main/modules/services/greetd.nix

{
  lib,
  inputs,
  pkgs,
  ...
}: let
  inherit (lib) getExe;
  tuigreet = pkgs.callPackage "${inputs.tuigreet}/nix/package.nix" {};
  cmd = pkgs.writeShellScriptBin "greetd-hyprland" ''
    Hyprland
    systemctl --user stop hyprland-session.target
  '';
in {
  config = {
    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings.default_session = {
        command = getExe tuigreet;
        user = "greeter";
      };
    };
    environment.etc."tuigreet/config.toml".source = (pkgs.formats.toml {}).generate "tuigreet-config.toml" {
      display = {
        greeting = "Oohb im nixxing it rn,,,";
        show_time = true;
        show_title = false;
      };
      layout = {
        window_padding = 1;
        widgets = {
          time_position = "top";
          status_position = "hidden";
        };
      };
      # silence cmd output also
      session.command = "${getExe cmd} >/dev/null 2>&1";
      secret = {
        mode = "characters";
        characters = "*";
      };
      remember = {
        default_user = "wumpus";
        username = true;
      };
      power = {
        use_setsid = false;
        shutdown = "systemctl poweroff";
        reboot = "systemctl reboot";
      };
    };
  };
}

