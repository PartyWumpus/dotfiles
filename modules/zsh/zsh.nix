{
  options,
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;
    historySubstringSearch.searchDownKey = [
      "^[[B"
      "$terminfo[kcud1]"
    ];
    historySubstringSearch.searchUpKey = [
      "^[[A"
      "$terminfo[kcuu1]"
    ];

    shellAliases = {
      update = "sudo nixos-rebuild switch --flake ~/nixos#${builtins.getEnv "HOSTNAME"} --impure";
      test = ''manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --preview="manix '{}'" | xargs manix '';
      #update = "sudo nixos-rebuild switch --flake ~/nixos#default --impure";
    };

    history.size = 10000;
    history.path = "${config.xdg.dataHome}/zsh/history";

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = ./plugins;
        file = "p10k.zsh";
      }
    ];
  };

  /*
    	programs.starship = {
        enable = true;
    		settings = {
            #format = "$all"; # Remove this line to disable the default prompt format
            palette = "catppuccin_macchiato";

          } // builtins.fromTOML (builtins.readFile
            (pkgs.fetchFromGitHub
              {
                owner = "catppuccin";
                repo = "starship";
                rev = "5629d2356f62a9f2f8efad3ff37476c19969bd4f"; # Replace with the latest commit hash
                sha256 = "sha256-nsRuxQFKbQkyEI4TXgvAjcroVdG+heKX5Pauq/4Ota0=";
              } + /palettes/macchiato.toml))
    					#// builtins.fromTOML (builtins.readFile ./starship/nerd-font-symbols.toml)
    					// builtins.fromTOML (builtins.readFile ./starship/pastel-powerline.toml);
      };
  */
}
