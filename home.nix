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
    ./modules/nvim
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
    };

    programs.fzf.enable = true;
    programs.fzf.catppuccin.enable = true;
    programs.foot = {
      enable = true;
      catppuccin.enable = true;
      settings = {
        main = {
          font = "MesloLGS NF:size=12";
          resize-delay-ms = 200;
          pad = "5x5 center";
        };
        scrollback = {
          lines = 100000;
          multiplier = 3.5; # scroll speed
        };
      };
    };

    # The home.packages option allows you to install Nix packages into your
    # environment.
    home.packages = with pkgs; [
      micro
      wget
      tldr
      unzip
      htop
      #fzf

      neofetch
      pipes
      # # Adds the 'hello' command to your environment. It prints a friendly
      # # "Hello, world!" when run.
      # pkgs.hello

      alacritty
      google-chrome
      transmission_3-gtk
      pinta
      ranger
      kdenlive
      feishin

      # for yazi
      file # find mimetypes
      ffmpegthumbnailer # video thumbnails
      p7zip # archive preview
      jq # JSON preview
      poppler # PDF preview
      fd # file searching
      ripgrep # file content searching
      fzf # quick file subtree navigation
      zoxide # historical directories navigation
      imagemagick # font preview i think

      qogir-icon-theme
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
      cursorTheme = {
        name = "Qogir";
        package = pkgs.qogir-icon-theme;
      };
      iconTheme = {
        name = "Qogir";
        package = pkgs.qogir-icon-theme;
      };
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
      "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
      "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
      "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
      "Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini { }).generate "kvantum.kvconfig" {
        General.theme = "Catppuccin-Macchiato-Mauve";
      };
      "Kvantum/Catppuccin-Macchiato-Mauve".source = "${
        (pkgs.catppuccin-kvantum.override {
          accent = "Mauve";
          variant = "Macchiato";
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

    programs.yazi = {
      enable = true;
      enableZshIntegration = true;

      package = pkgs.yazi-unwrapped.overrideAttrs (
        finalAttrs: previousAttrs: {
          buildInputs = previousAttrs.buildInputs ++ [

          ];
        }
      );

      flavors = {
        catppuccin-macchiato = "${inputs.yazi-flavors}/catppuccin-macchiato.yazi";
      };

      plugins = {
        full-border = "${inputs.yazi-plugins}/full-border.yazi";
      };

      settings = {
        manager = {
          show_hidden = true;
        };
        preview = {
          max_width = 1000;
          max_height = 1000;
        };
      };

      theme =
        /*
          (builtins.fromTOML (
            builtins.readFile "${
              pkgs.fetchFromGitHub {
                owner = "Mellbourn";
                repo = "ls-colors.yazi";
                rev = "1401880b1a44e2c1809af75adb3da2a9ccb6b472";
                hash = "sha256-oAoRBD0FFxVuaQ8AAA35x5eTptVtDV7/qNYR+XrGSGE=";
              }
            }/theme.toml"
          ))
          //
        */
        # ls-colors was ugly
        {
          flavor = {
            use = "catppuccin-macchiato";
          };
        };
    };

    #home.pointerCursor = {
    #  gtk.enable = true;
    #  package = pkgs.bibata-cursors;
    #  name = "Bibata-Modern-Classic";
    #  size = 24;
    #};

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
      TERMINAL = "alacritty";
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
      plugins = [ pkgs.obs-studio-plugins.droidcam-obs ];
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
