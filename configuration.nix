# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
	nix.settings.experimental-features = [ "nix-command" "flakes" ];
	nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };
	#nix.package = pkgs.nixVersions.unstable # switch to this once 2.21.3 releases
	nix.package = pkgs.nixVersions.git;

	nix.registry.self.flake = inputs.self;

	nix.settings.auto-optimise-store = true;


	virtualisation.containers.enable = true;
	#virtualisation.docker = {
	#	enable = true;
	#	rootless = {
	#		enable = true;
	#		setSocketVariable = true;
	#	};
	#};
	virtualisation.podman = {
		enable = true;

		# Create a `docker` alias for podman, to use it as a drop-in replacement
		dockerCompat = true;

		# Required for containers under podman-compose to be able to talk to each other.
		defaultNetwork.settings.dns_enabled = true;
	};

	boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
	boot.kernelModules = [
	"v4l2loopback"
	];

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

	programs.zsh.enable = true;
	programs.command-not-found.enable = false;
	programs.nix-index.enable = true;
	programs.nix-index-database.comma.enable = true;

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.wumpus = {
		isNormalUser = true;
		description = "wumpus";
		extraGroups = [ "networkmanager" "wheel" ];
		shell = pkgs.zsh;
		packages = with pkgs; [];
	};

	home-manager = {
		extraSpecialArgs = {inherit inputs;};
		useGlobalPkgs = true;
		useUserPackages = true;
		backupFileExtension = "tmp.${inputs.self.timestamp}";
		users = {
			"wumpus" = import ./home.nix;
		};
	};

	environment.interactiveShellInit = /*bash*/ ''
		unlink-copy() {
			cp "$1" "$1.tmp"
			unlink "$1"
			mv "$1.tmp" "$1"
			chmod -R 777 "$1"
		}

		dev() {
			nix develop self#"$1" -c zsh
		}
	'';
	#alias rebuild = "sudo nixos-rebuild build --flake ~/nixos#${builtins.getEnv "HOSTNAME"} --impure";

	# Allow unfree packages
	#nixpkgs.config.allowUnfree = true;
	#nixpkgs.overlays = [ inputs.neovim.overlay ];
	environment.sessionVariables.NIXOS_OZONE_WL = "1";

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment.systemPackages = with pkgs; [
		sof-firmware
		# packages
		zsh
		micro
		wget
		tldr
		unzip
		watchexec
		htop

		neofetch
		pipes

		fzf
		manix

		steam-run
		distrobox

		# themes
		libsForQt5.qtstyleplugin-kvantum
		libsForQt5.qt5ct
		where-is-my-sddm-theme

		# git packages
		git
		gh
		libsecret

		# apps
		alacritty
		google-chrome
		vesktop
		transmission_3-gtk
		pinta
		yt-dlp
		kid3
		ranger
		kdenlive
		prismlauncher
		spotify
		r2modman
		protonvpn-cli_2

		# languages
		(python312.withPackages(ps: [
			ps.pynvim
		]))

		# productivity
		libreoffice-qt
		hunspell
		hunspellDicts.en_GB-ize
	];

	# thunar
	programs.thunar.enable = true;
	programs.xfconf.enable = true;
	services.tumbler.enable = true;

	# power info
	services.upower.enable = true;
	
	services.flatpak.enable-debug = true;
	services.flatpak.enable = true;
	services.flatpak.preInstallCommand = ''${pkgs.libnotify}/bin/notify-send "Updating Flatpaks"'';
	services.flatpak.preDedupeCommand = ''${pkgs.libnotify}/bin/notify-send "Deduping Flatpaks"'';
	services.flatpak.UNCHECKEDpostEverythingCommand = ''${pkgs.libnotify}/bin/notify-send "Flatpaks Updated"'';
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


	# fonts
	fonts.packages = with pkgs; [
		noto-fonts
		noto-fonts-cjk
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

	# hyprland setup
	programs.hyprland.enable = true;
	programs.hyprland.package = inputs.hyprland.packages.${pkgs.system}.hyprland;
	xdg.portal.enable = true;
	xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
	
	# mime type setup
	environment.sessionVariables.DEFAULT_BROWSER = "${pkgs.google-chrome}/bin/google-chrome-stable";
	xdg.mime.enable = true;
	xdg.mime.defaultApplications = {
		"text/html" = "google-chrome.desktop";
		"x-scheme-handler/https" = "google-chrome.desktop";
		"x-scheme-handler/about" = "google-chrome.desktop";
		"x-scheme-handler/unknown" = "google-chrome.desktop";
	};

	# sound setup
	sound.enable = true;
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

	security.pam.services.hyprlock = {};

	services.xserver.enable = true;
	services.displayManager.sddm = {
		enable = true;
		wayland.enable = true;
		theme = "where_is_my_sddm_theme";
		package = pkgs.libsForQt5.sddm;
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
      "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
  };
};

	#hardware.pulseaudio = {
	#	enable = true;
	#	package = pkgs.pulseaudioFull;
	#	extraConfig = "
	#		load-module module-switch-on-connect
	#	";
	#};

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

}
