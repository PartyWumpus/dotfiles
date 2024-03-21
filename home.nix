{ config, pkgs, ... }:

{
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

	# todo: move me to a hyprland.nix file

	wayland.windowManager.hyprland = {
		enable = true;
		extraConfig = ''
				$mod = SUPER

				exec-once = swww init && swww img ~/wallpaper.png
				exec-once = waybar
				exec-once = dunst

				input {
					kb_layout = gb
				}

				general {
					gaps_in = 5
					gaps_out = 5
				}

				decoration {
					rounding = 10
				}

				bindm = $mod, mouse:272, movewindow
				bindm = ALT, mouse:272, resizewindow

				bind=, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
				bind=, XF86AudioLowerVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-
				bind=, XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+

				bind=, XF86XK_MonBrightnessUp,  exec, brightnessctl s +5%
				bind=, XF86XK_MonBrightnessDown,  exec, brightnessctl s 5%-
				bind=, F12, exec, grimshot --notify save area ${config.xdg.userDirs.pictures}/$(TZ=utc date +'screenshot_%Y-%m-%d-%H%M%S.%3N.png')
        bind=Shift, F12, exec, grimshot --notify save active ${config.xdg.userDirs.pictures}/$(TZ=utc date +'screenshot_%Y-%m-%d-%H%M%S.%3N.png')
		'';
		settings = {
			"$mod" = "SUPER";
			"$terminal" = "alacritty";
			"$menu" = "wofi --show drun -show-icons";
			bind = 
				[
					"$mod, Q, exec, $terminal"
					"$mod, S, exec, $menu"
					"$mod, C, killactive"
					"$mod, M, exit"
				]
				++ (
					# binds $mod + 1..10 to workspace 1..10
					builtins.concatLists (builtins.genList (
						x: let
							ws = let
								c = (x + 1) / 10;
							in
								builtins.toString (x + 1 - (c*10));
						in [
							"$mod, ${ws}, workspace, ${toString (x+1)}"
							"$mod SHIFT, ${ws}, movetoworkspace, ${toString (x+1)}"
						]
					)
					10)
				);
		};
	};

	programs.waybar = {
		enable = true;
		style = ''
      ${builtins.readFile ./hyprland/waybar/waybar.css}
		'';
		# thank you https://git.sr.ht/~begs/dotfiles/tree/master/item/.config/waybar/config
		settings = [{
	layer = "top";
	position = "top";

	modules-left = [
		"hyprland/mode"
		"hyprland/workspaces"
		"custom/arrow10"
		"hyprland/window"
	];

	modules-right = [
		"custom/arrow9"
		"pulseaudio"
		"custom/arrow8"
		"network"
		"custom/arrow7"
		"memory"
		"custom/arrow6"
		"cpu"
		"custom/arrow5"
		"temperature"
		"custom/arrow4"
		"battery"
		"custom/arrow3"
		"disk"
		"custom/arrow2"
		"tray"
		"clock#date"
		"custom/arrow1"
		"clock#time"
	];

	# modules

	battery = {
		interval = 10;
		states = {
			warning = 30;
			critical = 15;
		};
		format-time = "{H}:{M:02}";
		format = "{icon} {capacity}% ({time})";
		format-charging = " {capacity}% ({time})";
		format-charging-full = " {capacity}%";
		format-full = "{icon} {capacity}%";
		format-alt = "{icon} {power}W";
		format-icons = [
			""
			""
			""
			""
			""
		];
		tooltip = false;
	};

	"clock#time" = {
	 	interval = 10;
	 	format = "{:%H:%M}";
	 	tooltip = false;
	 };

	"clock#date" = {
	 	interval = 20;
	 	format = "{:%e %b %Y}";
	 	tooltip = false;
	 	# tooltip-format = "{:%e %B %Y}"
	};

	cpu = {
		interval = 5;
		tooltip = false;
		format = " {usage}%";
		format-alt = " {load}";
		states = {
			warning = 70;
			critical = 90;
		};
	};

	#"hyprland/language" = {
	#	format = " {}";
	#	min-length = 5;
	#	on-click = "swaymsg 'input * xkb_switch_layout next'";
	#	tooltip = false;
	#};

	disk = {
		format = " {percentage_used}%";
		format-alt = " {used}/{total}";
	};

	memory = {
		interval = 5;
		format = " {used:0.1f}G/{total:0.1f}G";
		states = {
			warning = 70;
			critical = 90;
		};
		tooltip = false;
	};

	network = {
		interval = 5;
		format-wifi = " {essid} ({signalStrength}%)";
		format-ethernet = " {ifname}";
		format-disconnected = "No connection";
		format-alt = " {ipaddr}/{cidr}";
		tooltip = false;
	};

	"hyprland/mode" = {
		format = "{}";
		tooltip = false;
	};

	"hyprland/window" = {
		format = "{}";
		max-length = 30;
		tooltip = false;
	};

	"hyprland/workspaces" = {
		disable-scroll-wraparound = true;
		smooth-scrolling-threshold = 4;
		enable-bar-scroll = true;
		format = "{name}";
	};

	pulseaudio = {
		format = "{icon} {volume}%";
		format-bluetooth = "{icon} {volume}%";
		format-muted = "";
		format-icons = {
			headphone = "";
			hands-free = "";
			#headset = "";
			headset = "";
			phone = "";
			portable = "";
			car = "";
			default = ["" ""];
		};
		scroll-step = 1;
		#on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
		# sleep is needed because of waybar & hyprland bug https://github.com/Alexays/Waybar/issues/1850
		on-click = "sleep 0.1 && ${./hyprland/waybar/audio_changer.py}";
		tooltip = false;
	};

	temperature = {
		critical-threshold = 90;
		interval = 5;
		format = "{icon} {temperatureC}°";
		format-icons = [
			""
			""
			""
			""
			""
		];
		tooltip = false;
	};

	tray = {
		icon-size = 18;
		# spacing = 10
	};

	"custom/arrow1" = {
		format = "";
		tooltip = false;
	};

	"custom/arrow2" = {
		format = "";
		tooltip = false;
	};

	"custom/arrow3" = {
		format = "";
		tooltip = false;
	};

	"custom/arrow4" = {
		format = "";
		tooltip = false;
	};

	"custom/arrow5" = {
		format = "";
		tooltip = false;
	};

	"custom/arrow6" = {
		format = "";
		tooltip = false;
	};

	"custom/arrow7" = {
		format = "";
		tooltip = false;
	};

	"custom/arrow8" = {
		format = "";
		tooltip = false;
	};

	"custom/arrow9" = {
		format = "";
		tooltip = false;
	};

	"custom/arrow10" = {
		format = "";
		tooltip = false;
	};
	}];
	};

	programs.alacritty = {
		enable = true;
		settings.import = [ "${pkgs.alacritty-theme.outPath}/catppuccin_macchiato.toml" ];
	};

	# Let Home Manager install and manage itself.
	programs.home-manager.enable = true;
}
