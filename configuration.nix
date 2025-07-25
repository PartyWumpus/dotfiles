{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  options.local.isDesktop = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = {
    programs.partition-manager.enable = true;

    nix.settings.system-features = [
      "benchmark"
      "big-parallel"
      "kvm"
      "nixos-test"
      "gccarch-znver4"
      "gccarch-x86-64-v2"
      "gccarch-x86-64-v3"
    ];

    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.permittedInsecurePackages = [
      "electron-33.4.11"
    ];

    systemd.services.bluetooth.serviceConfig = {
      TimeoutStopSec = 15;
    };

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    nix.settings = {
      substituters = [
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    #nix.package = pkgs.nixVersions.latest;
    #nix.package = pkgs.nixVersions.git;
    nix.package = pkgs.lix;

    systemd.extraConfig = "DefaultLimitNOFILE=4096";

    nix.registry.system.flake = inputs.self;

    nix.settings.auto-optimise-store = true;

    virtualisation.containers.enable = true;

    virtualisation.podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };

    boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    boot.kernelModules = [ "v4l2loopback" ];

    boot.extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';
    security.polkit.enable = true;

    nix.gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Enable networking
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "Europe/London";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_GB.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "gb";
      variant = "";
    };

    # Configure console keymap
    console.keyMap = "uk";

    # this is just so nix doesn't worry about zsh being missing
    programs.zsh.enable = true;
    programs.command-not-found.enable = false;
    programs.nix-index.enable = true;
    programs.nix-index-database.comma.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.wumpus = {
      isNormalUser = true;
      description = "wumpus";
      extraGroups = [
        "dialout"
        "networkmanager"
        "wheel"
      ];
      shell = pkgs.zsh;
      packages = with pkgs; [
      ];
    };

    home-manager = {
      extraSpecialArgs = {
        inherit inputs;
      };
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "tmp.${inputs.self.my_timestamp}";
      users = {
        "wumpus" = ./home.nix;
      };
    };

    environment.interactiveShellInit = # bash
      ''
        unlink-copy() {
          cp "$1" "$1.tmp"
          unlink "$1"
          mv "$1.tmp" "$1"
          chmod -R 777 "$1"
        }

        dev() {
          nix develop system#"$1" -c zsh
        }
      '';

    #nixpkgs.overlays = [ inputs.neovim.overlay ];
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      sof-firmware

      # bluetooth info for ags
      gnome-bluetooth
      manix

      steam-run
      mpv
      distrobox
      docker-compose
      gdu

      # themes
      libsForQt5.qtstyleplugin-kvantum
      libsForQt5.qt5ct
      (pkgs.catppuccin-sddm.override {
        flavor = "macchiato";
        font = "Noto Sans";
        fontSize = "15";
        background = "${./assets/nix.jpg}";
        loginBackground = true;
      })

      # git packages
      git
      gh
      libsecret

      # apps
      spotify
      vesktop
      kid3
      yt-dlp
      prismlauncher
      r2modman
      bitwarden-desktop
      pavucontrol

      # productivity
      libreoffice-qt
      hunspell
      hunspellDicts.en_GB-ize

      inputs.self.packages.${pkgs.system}.nvim
    ];

    # thunar
    programs.thunar.enable = true;
    programs.xfconf.enable = true;
    services.tumbler.enable = true;

    ## AGS
    # power info
    services.upower.enable = true;
    # caching of cover art
    services.gvfs.enable = true;

    services.flatpak.debug = true;
    services.flatpak.enable = true;
    # docs: https://github.com/GermanBread/declarative-flatpak/blob/dev/docs/definition.md
    services.flatpak.overrides = {
      "global" = {
        filesystems = [
          #"host"
          "/mnt"
        ];
      };
      #"dev.bambosh.UnofficialHomestuckCollection".filesystems = [ "host" "xdg-download" "home" "/mnt" ];
    };
    services.flatpak.packages = [
      "flathub:app/com.heroicgameslauncher.hgl//stable"
      "flathub:app/dev.bambosh.UnofficialHomestuckCollection//stable"
      "flathub:app/com.github.tchx84.Flatseal//stable"
    ];
    services.flatpak.remotes = {
      "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      "flathub-beta" = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
    };

    services.tailscale.enable = true;

    # fonts
    fonts.packages = with pkgs; [
      oswald
      noto-fonts
      noto-fonts-cjk-sans
      #noto-fonts-monochrome-emoji
      noto-fonts-emoji
      meslo-lgs-nf
      rubik
    ];

    environment.variables.QT_QPA_PLATFORMTHEME = "qt5ct";

    environment.variables.HOSTNAME = config.networking.hostName;

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #		enable = true;
    #		enableSSHSupport = true;
    # };

    programs.hyprland.enable = true;
    programs.hyprland.package = inputs.hyprland.packages.${pkgs.system}.hyprland;

    # mime type setup
    environment.sessionVariables.DEFAULT_BROWSER = "${pkgs.google-chrome}/bin/google-chrome-stable";
    xdg.mime.enable = true;
    xdg.mime.defaultApplications = {
      "text/html" = "google-chrome.desktop";
      "x-scheme-handler/https" = "google-chrome.desktop";
      "x-scheme-handler/about" = "google-chrome.desktop";
      "x-scheme-handler/unknown" = "google-chrome.desktop";
    };

    # allow appimages to run
    programs.appimage.binfmt = true;

    # sound setup
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    hardware.enableAllFirmware = true;

    programs.steam = {
      enable = true;
      #TODO: figure this out
      #package = pkgs.steam.override { commandLineArgs = [ "-vgui" ]; };
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      gamescopeSession.enable = true;
    };

    services.libinput.enable = false;
    services.xserver.synaptics.enable = true;

    security.pam.services.hyprlock = { };

    services.xserver.enable = true;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "catppuccin-macchiato";
      package = pkgs.kdePackages.sddm;
    };

    hardware.bluetooth.enable = true;
    hardware.bluetooth.settings.General.Experimental = true;
    # if desktop hardware.bluetooth.powerOnBoot = true;
    services.blueman.enable = true;

    services.pipewire.wireplumber.extraConfig = {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [
          "hsp_hs"
          "hsp_ag"
          "hfp_hf"
          "hfp_ag"
        ];
      };
    };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.05"; # Did you read the comment?

  };
}
