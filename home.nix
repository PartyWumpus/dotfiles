{ config, pkgs, ... }:

{
	imports = [ ./hyprland/hyprland.nix ];
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

	# The home.packages option allows you to install Nix packages into your
	# environment.
	home.packages = with pkgs; [
		# # Adds the 'hello' command to your environment. It prints a friendly
		# # "Hello, world!" when run.
		# pkgs.hello

		# # It is sometimes useful to fine-tune packages, for example, by applying
		# # overrides. You can do that directly here, just don't forget the
		# # parentheses. Maybe you want to install Nerd Fonts with a limited number of
		# # fonts?
		# (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

		# # You can also create simple shell scripts directly inside your
		# # configuration. For example, this adds a command 'my-hello' to your
		# # environment:
		# (pkgs.writeShellScriptBin "my-hello" ''
		#		echo "Hello, ${config.home.username}!"
		# '')
  	#(pkgs.catppuccin-kvantum.override {
    #	accent = "Lavender";
    #	variant = "Macchiato";
    #})
  ];
  #xdg.configFile = {
	#	"Kvantum/Catppuccin-Macchiato-Lavender/Catppuccin-Macchiato-Lavender/Catppuccin-Macchiato-Lavender.kvconfig".source = "${pkgs.catppuccin-kvantum}/share/Kvantum/Catppuccin-Macchiato-Lavender/Cattpuccin-Macchiato-Lavender.kvconfig";
  #	"Kvantum/Catppuccin-Macchiato-Lavender/Catppuccin-Macchiato-Lavender/Catppuccin-Macchiato-Lavender.svg".source = "${pkgs.catppuccin-kvantum}/share/Kvantum/Catppuccin-Macchiato-Lavender/Cattpuccin-Macchiato-Lavender.svg";
  #};

	gtk = {
		enable = true;
		theme = {
			name = "Catppuccin-Macchiato-Compact-Blue-Dark";
			package = pkgs.catppuccin-gtk.override {
				#accents = [ "pink" ];
				size = "compact";
				tweaks = [ "rimless" ];
				variant = "macchiato";
			};
		};
	};

	xdg.configFile = {
		"gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
		"gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
		"gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
	};

      #home.pointerCursor = {
      #  gtk.enable = true;
      #  package = pkgs.bibata-cursors;
      #  name = "Bibata-Modern-Classic";
      #  size = 24;
      #};

	# Home Manager is pretty good at managing dotfiles. The primary way to manage
	# plain files is through 'home.file'.
	home.file = {
		# # Building this configuration will create a copy of 'dotfiles/screenrc' in
		# # the Nix store. Activating the configuration will then make '~/.screenrc' a
		# # symlink to the Nix store copy.
		# ".screenrc".source = dotfiles/screenrc;
		".config/nvim".source = ./nvim;

		# # You can also set the file content immediately.
		# ".gradle/gradle.properties".text = ''
		#		org.gradle.console=verbose
		#		org.gradle.daemon.idletimeout=3600000
		# '';
	};

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
	};

	programs.zsh = {
		enable = true;
		enableCompletion = true;
		enableAutosuggestions = true;
		syntaxHighlighting.enable = true;

		shellAliases = {
			update = "sudo nixos-rebuild switch --flake ~/nixos#default --impure";
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
			src = ./zsh;
			file = "p10k.zsh";
		}
		];
	};

	programs.alacritty = {
		enable = true;
		settings.import = [ "${pkgs.alacritty-theme.outPath}/catppuccin_macchiato.toml" ];
	};

	# Let Home Manager install and manage itself.
	programs.home-manager.enable = true;
}
