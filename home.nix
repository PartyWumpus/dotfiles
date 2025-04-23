{
  config,
  pkgs,
  lib,
  inputs,
  osConfig,
  ...
}:

{
  imports = [
    ./modules/hyprland
    ./modules/zsh
  ];

  config = {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    home.username = "wumpus";
    home.homeDirectory = "/home/wumpus";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "23.11"; # Please read the comment before changing.

    catppuccin = {
      accent = "mauve";
      flavor = "macchiato";
      kitty.enable = true;
      tofi.enable = false;
      foot.enable = true;
      fzf.enable = true;
    };

    programs.fzf.enable = true;
    programs.foot = {
      enable = true;
      settings = {
        main = {
          font = "MesloLGS NF:size=12";
          resize-delay-ms = 200;
          pad = "4x4 center";
        };
        scrollback = {
          lines = 100000;
          multiplier = 3.5; # scroll speed
        };
      };
    };

    programs.kitty = {
      enable = true;
      settings = {
        scrollback_lines = 10000;
        enable_audio_bell = false;
        window_padding_width = 2;
        background_opacity = 1;
      };
    };

    # The home.packages option allows you to install Nix packages into your
    # environment.
    home.packages = with pkgs; [
      micro
      wget
      tldr
      unzip
      /*
        (htop.overrideAttrs (
        finalAttrs: previousAttrs: {
          nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ pkgs.git ];
          patches = [./nix.patch];
        }
        ))
      */
      htop
      #fzf

      neofetch
      pipes
      eza
      # # Adds the 'hello' command to your environment. It prints a friendly
      # # "Hello, world!" when run.
      # pkgs.hello

      google-chrome
      firefox-bin
      transmission_3-gtk
      pinta
      ranger
      kdenlive
      feishin

      radicle-node
    ];

    gtk = {
      enable = true;
      theme = {
        name = "catppuccin-macchiato-mauve-compact+rimless";
        package = pkgs.catppuccin-gtk.override {
          accents = [ "mauve" ];
          size = "compact";
          tweaks = [ "rimless" ];
          variant = "macchiato";
        };
      };
      iconTheme.package = pkgs.tela-icon-theme;
      iconTheme.name = "Tela-dark";
    };

    home.pointerCursor = {
      gtk.enable = true;
      name = "Qogir";
      package = pkgs.qogir-icon-theme;
      size = 22;
    };

    qt = {
      enable = true;
      platformTheme.name = "qtct";
      style.name = "kvantum";
    };

    xdg.enable = true;

    home.activation.create_folders =
      lib.hm.dag.entryAfter [ "writeBoundary" ] # bash
        ''
          mkdir -p Videos/clips
          mkdir -p Code
        '';

    xdg.configFile = {
      "gtk-4.0/assets".source =
        "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
      "gtk-4.0/gtk.css".source =
        "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
      "gtk-4.0/gtk-dark.css".source =
        "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
      "Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini { }).generate "kvantum.kvconfig" {
        General.theme = "Catppuccin-Macchiato-Mauve";
      };
      "Kvantum/Catppuccin-Macchiato-Mauve".source = "${
        (pkgs.catppuccin-kvantum.override {
          accent = "mauve";
          variant = "macchiato";
        })
      }/share/Kvantum/Catppuccin-Macchiato-Mauve";
    };

    xdg.configFile = {
      "distrobox/distrobox.conf".text = ''
        container_additional_volumes="/nix:/nix:ro /etc/profiles/per-user/wumpus/etc/profile.d:/etc/profiles/per-user/wumpus/etc/profile.d:ro"
        PATH="$PATH:${pkgs.zsh}/bin"
        container_init_hook="${pkgs.zsh}/bin/zsh"
      '';
    };

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    home.file =
      {
        # # Building this configuration will create a copy of 'dotfiles/screenrc' in
        # # the Nix store. Activating the configuration will then make '~/.screenrc' a
        # # symlink to the Nix store copy.
        # ".screenrc".source = dotfiles/screenrc;
        #".config/nvim".source = ./modules/nvim;

        # # You can also set the file content immediately.
        # ".gradle/gradle.properties".text = ''
        #		org.gradle.console=verbose
        #		org.gradle.daemon.idletimeout=3600000
        # '';
      }
      // (
        if osConfig.local.isDesktop then
          {
            Downloads.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Downloads";
            Pictures.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Pictures";
            Videos.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Videos";
          }
        else
          { }
      );

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. If you don't want to manage your shell through Home
    # Manager then you have to manually source 'hm-session-vars.sh' located at
    # either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/wumpus/etc/profile.d/hm-session-vars.sh
    #
    home.sessionVariables = {
      EDITOR = "nvim";
      MANPAGER = "nvim +Man!";
      TERMINAL = "kitty";
    };

    programs.git = {
      enable = true;
      userName = "PartyWumpus";
      userEmail = "48649272+PartyWumpus@users.noreply.github.com";
      aliases = {
        dft = "difftool";
      };
      extraConfig = {
        diff.tool = ''difftastic'';
        difftool.prompt = false;
        difftool.difftastic.cmd = ''${pkgs.difftastic}/bin/difft "$LOCAL" "$REMOTE"'';
        pager.difftool = true;
      };
    };

    programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };

    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          normal.family = "MesloLGS NF";
        };
        import = [ "${pkgs.alacritty-theme.outPath}/catppuccin_macchiato.toml" ];
      };
    };

    # nix flake new -t github:nix-community/nix-direnv .
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    programs.obs-studio = {
      enable = true;
      #plugins = [ pkgs.obs-studio-plugins.droidcam-obs ];
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
