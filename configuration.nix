# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
	imports =
		[ # Include the results of the hardware scan.
			/etc/nixos/hardware-configuration.nix
			inputs.home-manager.nixosModules.default
		];

	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	# Bootloader.
	boot.loader.grub.enable = true;
	boot.loader.grub.device = "/dev/sda";
	boot.loader.grub.useOSProber = true;

	networking.hostName = "nixos"; # Define your hostname.
	# networking.wireless.enable = true;	# Enables wireless support via wpa_supplicant.

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
		users = {
			"wumpus" = import ./home.nix;
		};
	};

	# Allow unfree packages
	nixpkgs.config.allowUnfree = true;

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment.systemPackages = with pkgs; [
		# packages
		zsh
		neovim
		micro
		wget
		tldr
		konsole
		neofetch

		# git packages
		git
		gh
		libsecret

		# apps
		google-chrome
		vesktop

		# hyprland packages
		wofi
		waybar
		dunst
		libnotify
		swww

		# nvim packages
		tree-sitter
		ripgrep
		fd

		# lsp packages
		lua-language-server
		nodePackages.typescript-language-server
		rust-analyzer
		nodePackages.pyright
		nil
	];


	# fonts
	fonts.packages = with pkgs; [
		noto-fonts
		noto-fonts-cjk
		noto-fonts-emoji
		meslo-lgs-nf
	];

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
