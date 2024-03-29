
{ options, config, lib, pkgs, ...}:

let
	menu = "${pkgs.wofi}/bin/wofi";

	show_clipboard = pkgs.writeShellScript "show_clipboard" ''
		text=$(cliphist list | ${menu} --show dmenu -p "copy"); \
		if [[ $text != "" ]]; then
			cliphist decode <<< "$text" | wl-copy
		fi
	'';

	delete_clipboard = pkgs.writeShellScript "delete_clipboard" ''
		cliphist list | \
		${menu} --show dmenu -p "delete" | \
		cliphist delete
	'';

in {
	home.packages = with pkgs; [
		brightnessctl
		wofi
		waybar
		dunst
		libnotify
		swww
		sway-contrib.grimshot
		cliphist
		wl-clipboard
	];

	wayland.windowManager.hyprland = {
		enable = true;
		extraConfig = ''
				$mod = SUPER

				${(if builtins.getEnv "HOSTNAME" == "desktop"
					then "monitor=DP-1,2560x1440@144,0x0,1.6"
					else "monitor=eDP-2,2560x1600@165,0x0,1.666667"
					)}

				exec-once = swww init && swww img ${./wallpaper.png}
				exec-once = waybar
				exec-once = dunst
				exec-once = wl-paste --watch cliphist store

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

				misc {
					force_default_wallpaper = 0
				}

				bindm = $mod, mouse:272, movewindow
				bindm = ALT, mouse:272, resizewindow

				bind=$mod, P, exec, ${show_clipboard}

				bind=, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
				bind=, XF86AudioLowerVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-
				bind=, XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+

				bind=, XF86MonBrightnessUp,  exec, brightnessctl s +5%
				bind=, XF86MonBrightnessDown,  exec, brightnessctl s 5%-
				bind=, F12, exec, grimshot --notify savecopy area ${config.xdg.userDirs.pictures}/$(TZ=utc date +'screenshot_%Y-%m-%d-%H%M%S.%3N.png')
				bind=Shift, F12, exec, grimshot --notify savecopy active ${config.xdg.userDirs.pictures}/$(TZ=utc date +'screenshot_%Y-%m-%d-%H%M%S.%3N.png')
		'';
		settings = {
			"$mod" = "SUPER";
			"$terminal" = "alacritty"; # todo
			"$menu" = "${menu}";
			bind = 
				[
					"$mod, Q, exec, $terminal"
					"$mod, S, exec, $menu --show drun -show-icons"
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
      ${builtins.readFile ./waybar/waybar.css}
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
		(if builtins.getEnv "HOSTNAME" == "desktop" then "disk" else "battery")
		"custom/arrow3"
		"custom/clipboard"
		"custom/arrow2"
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

	# thank you random reddit thread https://www.reddit.com/r/swaywm/comments/z4lq76/comment/ixse0tm/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
	"custom/clipboard" = {
		format = "󱉫";
		interval = "once";
		return-type = "json";
		on-click = "sleep 0.1 && ${show_clipboard}";
		on-click-right = "sleep 0.1 && ${delete_clipboard}";
		#on-click-middle = "swaymsg -q exec '$clipboard-del-all'";
		exec = "printf '{\"tooltip\":\"%s\"}' $(cliphist list | wc -l)";
		exec-if = "[ -x \"$(command -v cliphist)\" ] && [ $(cliphist list | wc -l) -gt 0 ]";
		signal = 9;
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
		on-click-right = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
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
		on-click = "sleep 0.1 && ${./waybar/audio_changer.py}";
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

}
