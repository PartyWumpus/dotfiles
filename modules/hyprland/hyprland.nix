
{ inputs, options, config, lib, pkgs, ...}:

let
	menu = "${pkgs.wofi}/bin/wofi";

	show_clipboard = pkgs.writeShellScript "show_clipboard" ''
		text=$(cliphist list | ${menu} --show dmenu -l top_right -p "copy"); \
		if [[ $text != "" ]]; then
			cliphist decode <<< "$text" | wl-copy
		fi
	'';

	delete_clipboard = pkgs.writeShellScript "delete_clipboard" ''
		cliphist list | \
		${menu} --show dmenu -p "delete" | \
		cliphist delete
	'';

	wifi_menu = pkgs.writeShellScript "wifi_menu" ''
		hyprctl dispatch exec "[tag modal] alacritty -e bash -c 'unset COLORTERM; TERM=xterm-old nmtui'"
	'';

	bluetooth_menu = pkgs.writeShellScript "bluetooth_menu" ''
		hyprctl dispatch exec "[tag modal] ${pkgs.blueman}/bin/blueman-manager"
	'';

	/*monitor_change = pkgs.writeShellScript "monitor_change" ''
		
		monitor_changed() {
			pkill ags;
			sleep 0.2;
			ags &
		}

		handle() {
  		case $1 in
    		monitoradded*) monitor_changed ;;
				monitorremoved*) monitor_changed ;;
  		esac
		}

		${pkgs.socat}/bin/socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR"/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock | while read -r line; do handle "$line"; done
	'';*/

in {
	home.packages = with pkgs; [
		brightnessctl
		wofi
		waybar
		libnotify
		swww
		sway-contrib.grimshot
		cliphist
		wl-clipboard
		hypridle
		cava
		playerctl
	];

	xdg.portal = {
      enable = true;
      configPackages = [
				config.wayland.windowManager.hyprland.package
      ];
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland
      ];
      #config.common.default = "hyprland";
    };

	programs.hyprlock = {
		enable = true;
		settings = {
			general = {
				disable_loading_bar = true;
				grace = 10;
				hide_cursor = true;
				no_fade_in = false;
			};

			background = [{
      	monitor = "";
				path = "${./wallpaper.jpg}";
				color = "rgb(36, 39, 58)";
			}];

			label = [{
				monitor = "";
				text = ''$TIME'';
				#text = '' cmd[update:900] echo "hello $USER<br/>$(date +%H:%M:%S)" '';
				text_align = "center";
				color = "rgb(202, 211, 245)";
				font_size = "35";
				position = "0, -80";
				halign = "center";
				valign = "top";
			}];

			input-field = [{
				monitor = "";
				size = "200, 50";
				position = "0, 5";dots_center = true;
				fade_on_empty = false;
				font_color = "rgb(202, 211, 245)";
				inner_color = "rgb(91, 96, 120)";
				outer_color = "rgb(24, 25, 38)";
				outline_thickness = 5;
				placeholder_text = (if builtins.getEnv "HOSTNAME" == "laptop"
					then ''<span foreground="##cad3f5">Press index finger on the fingerprint sensor</span>''
					else ''<span foreground="##cad3f5">Password...</span>''
				);
				shadow_passes = 2;
    }];
		};
	};

	xdg.configFile = {
		"hypr/hypridle.conf".source = ./hypridle.conf;
		"tofi/config".text = /* toml */''
fuzzy-match = true
ascii-input = true
hint-font = false

prompt-text = ""
placeholder-text = "> "

font="/nix/store/1rxl6ipwybag00jqq151a2v18fbb2cyc-rubik-2.200/share/fonts/truetype/Rubik-Regular.ttf"
font-size=30

width = 500
height = 620

border-width = 3
outline-width = 0
corner-radius = 15

# text
text-color = #cad3f5

# subtext 1
placeholder-color = #b8c0e0

# surface0
background-color = #363a4f


# mauve
border-color = #c6a0f6
selection-color = #c6a0f6

# pink
selection-match-color = #f5bde6
		'';
	};

	wayland.windowManager.hyprland = {
		enable = true;
		package = inputs.hyprland.packages.${pkgs.system}.default.overrideAttrs (finalAttrs: previousAttrs: {
			nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ pkgs.git ];
      patches = [ ./initialTime.patch ]; 
   });
		extraConfig = ''
				$mod = SUPER

				${(if builtins.getEnv "HOSTNAME" == "desktop"
					then ''monitor=DP-1,2560x1440@144,0x0,1''
					else ''
					monitor=eDP-1,2560x1600@165,0x0,1.6,vrr,1
					monitor=eDP-2,2560x1600@165,0x0,1.6,vrr,1
					monitor=,highres,auto,1''
					)}

				exec-once = swww-daemon
				exec-once = sleep 10 && swww img ${./wallpaper.jpg}
				#exec-once = waybar
				exec-once = ags
				#exec-once = $\{monitor_change} # handles ags restarting
				exec-once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
				exec-once = wl-paste --watch cliphist store
				exec-once = ${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1
				exec-once = hypridle
				exec-once = hyprctl setcursor Qogir 24

				windowrulev2 = float, initialclass: xdg-desktop-portal-gtk
				windowrulev2 = dimaround, initialclass: xdg-desktop-portal-gtk
				windowrulev2 = opacity 0.95, initialTitle: Alacritty

				# remove blur from all windows, but not from layers
				windowrule = noblur, .*
				layerrule = blur, ^bar.*
				layerrule = ignorezero, ^bar.*

				# modalify tag:modal windows
				windowrulev2 = float, tag:modal
				windowrulev2 = pin, tag:modal
				windowrulev2 = center, tag:modal
				windowrulev2 = bordercolor rgb(c6a0f6) rgba(c6a0f688), pinned:1

				# disable animations for tofi
				layerrule = noanim, launcher

				input {
					kb_layout = gb
				}

				general {
					gaps_in = 1
					gaps_out = 0,5,5,5
					col.inactive_border = rgba(00000000) # CRUST
					col.active_border = rgb(c6a0f6) # Mauve
					border_size = 2
				}

				decoration {
					inactive_opacity = 0.98
					active_opacity = 1.00
					fullscreen_opacity = 1.00
					dim_around = 0.07 # dimming around modals
					rounding = 15
					drop_shadow = 0
					#screen_shader = /home/wumpus/Downloads/dots-hyprland/.config/hypr/shaders/chromatic_abberation.frag
					# blur is only for top bar
					blur {
						size = 4
						passes = 3
					}
				}

				animations {
					enabled = yes
    			first_launch_animation = false
				}

				gestures {
					workspace_swipe = true
					workspace_swipe_cancel_ratio = 0.3
				}
				
				dwindle {
					preserve_split = 1
				}

				misc {
					force_default_wallpaper = 0
				}

				xwayland {

					force_zero_scaling = 1
				}

				bindm = $mod, mouse:272, movewindow
				bindm = ALT, mouse:272, resizewindow

				bind=$mod, P, exec, ${show_clipboard}

				bindl=, XF86AudioPlay, exec, playerctl play-pause # the stupid key is called play , but it toggles 
				bindl=, XF86AudioNext, exec, playerctl next 
				bindl=, XF86AudioPrev, exec, playerctl previous

				bind=, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
				bind=, XF86AudioLowerVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-
				bind=, XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+

				bind=, XF86MonBrightnessUp,  exec, brightnessctl s +5%
				bind=, XF86MonBrightnessDown,  exec, brightnessctl s 5%-
				bind=, F12, exec, grimshot --notify savecopy area "${config.xdg.userDirs.pictures}/screenshots/$(TZ=utc date +'%d-%m-%Y %H:%M:%S %2N.png')"
				bind=Shift, F12, exec, grimshot --notify savecopy active "${config.xdg.userDirs.pictures}/screenshots/$(TZ=utc date +'%d-%m-%Y %H:%M:%S %2N.png')"
		'';
		settings = {
			"$mod" = "SUPER";
			"$terminal" = "alacritty"; # todo
			"$menu" = "${menu}";
			bind = 
				[
					"$mod, Q, exec, $terminal"
					#"$mod, S, exec, $menu --insensitive --show drun -show-icons"
					#"$mod, S, exec, ags -t applauncher"
					"$mod, S, exec, ${pkgs.tofi}/bin/tofi-drun --drun-launch=true"
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

	programs.wlogout = {
		enable = true;
		layout = [
{
label = "lock";
action = "loginctl lock-session";
text = "Lock";
keybind = "l";
}
{
label = "hibernate";
action = "systemctl hibernate";
text = "Hibernate";
keybind = "h";
}
{
label = "logout";
action = "loginctl terminate-user $USER";
text = "Logout";
keybind = "e";
}
{
label = "shutdown";
action = "systemctl poweroff";
text = "Shutdown";
keybind = "s";
}
{
label = "suspend";
action = "systemctl suspend";
text = "Suspend";
keybind = "u";
}
{
label = "reboot";
action = "systemctl reboot";
text = "Reboot";
keybind = "r";
}
];
style = /* css */ ''
* {
	background-image: none;
	box-shadow: none;
}

window {
	background-color: rgba(12, 12, 12, 0.9);
}

button {
	text-decoration-color: #FFFFFF;
  color: #FFFFFF;
	background-color: #363a4f;
	background-repeat: no-repeat;
	background-position: center;
	background-size: 25%;

	margin:5px;
	border-radius: 15px;
}

button:focus, button:active, button:hover {
	background-color: #c6a0f6;
	outline-style: none;
}

#lock {
    background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/lock.png"), url("/usr/local/share/wlogout/icons/lock.png"));
}

#logout {
    background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/logout.png"), url("/usr/local/share/wlogout/icons/logout.png"));
}

#suspend {
    background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/suspend.png"), url("/usr/local/share/wlogout/icons/suspend.png"));
}

#hibernate {
    background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/hibernate.png"), url("/usr/local/share/wlogout/icons/hibernate.png"));
}

#shutdown {
    background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png"), url("/usr/local/share/wlogout/icons/shutdown.png"));
}

#reboot {
    background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/reboot.png"), url("/usr/local/share/wlogout/icons/reboot.png"));
}
'';
	};

	# symlink the ags types into the config directory.
	# TODO: find a better way of symlinking the ags types
	home.file."${inputs.self.location}/modules/hyprland/ags/types".source = "${inputs.ags.packages.x86_64-linux.agsWithTypes.out}/share/com.github.Aylur.ags/types";

	home.file.".local/share/ags/nix.json".text = builtins.toJSON {
		bun = "${pkgs.bun}/bin/bun"; # workaround for extraPackages being broken
		show_clipboard = "${show_clipboard}";
		audio_changer = "${./waybar/audio_changer.py}";
		wifi_menu = "${wifi_menu}";
		bluetooth_menu = "${bluetooth_menu}";
		shader = "${./chromatic_aberration.frag}";
  };

	programs.ags = {
		enable = true;
		configDir = ./ags;
		# extraPackages isn't working for some reason
		#extraPackages = with pkgs; [
		#	bun
		#];
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
