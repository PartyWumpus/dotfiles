# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	# move me to laptop specific config
	#services.auto-cpufreq.enable = true;
	#services.auto-cpufreq.settings = {
	#	battery = {
	#		governor = "powersave";
	#		turbo = "never";
	#	};
	#	charger = {
	#		governor = "performance";
	#		turbo = "auto";
	#	};
	#};

	# Bootloader.
	#boot.loader.grub.enable = true;
	#boot.loader.grub.device = "/dev/sda";
	#boot.loader.grub.useOSProber = true;

	#networking.hostName = "nixos"; # Define your hostname.
	#networking.wireless.enable = true;	# Enables wireless support via wpa_supplicant.

	# Configure network proxy if necessary
	# networking.proxy.default = "http://user:password@proxy:port/";
	# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
		users = {
			"wumpus" = import ./home.nix;
		};
	};

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
		alacritty
		neofetch
		pipes

		# themes
		libsForQt5.qtstyleplugin-kvantum
		libsForQt5.qt5ct
		catppuccin-kvantum

		# git packages
		git
		gh
		libsecret

		# apps
		google-chrome
		vesktop
		transmission-gtk
		pinta
		obs-studio
		yt-dlp
		kid3
		xfce.thunar
		ranger

		# languages
		python3

		# productivity
		libreoffice-qt
		hunspell
		hunspellDicts.en_GB-ize
	];


	# fonts
	fonts.packages = with pkgs; [
		noto-fonts
		noto-fonts-cjk
		noto-fonts-emoji
		meslo-lgs-nf
	];

	environment.variables.QT_QPA_PLATFORMTHEME = "qt5ct";
	qt = {
		enable = true;
		platformTheme = "qt5ct";
		style = "kvantum";
	};

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
	xdg.portal.enable = true;
	xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
	
	# mime type setup
	environment.sessionVariables.DEFAULT_BROWSER = "${pkgs.google-chrome}/bin/google-chrome-stable";
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
		#package = pkgs.steam.override { commandLineArgs = [ "-vgui" ]; }; #TODO, figure this out
		remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
		dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
	};

	services.xserver.libinput.enable = false;
	services.xserver.synaptics.enable = true;

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
