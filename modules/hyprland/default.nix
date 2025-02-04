{
  inputs,
  options,
  config,
  lib,
  osConfig,
  pkgs,
  local,
  ...
}:

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

  record = pkgs.writeShellScript "record" ''
    LOCKFILE=~/.recording
    FILE=~/Videos/clips/wip.mp4
    
    if [ ! -f $LOCKFILE ]; then  # Not yet recording a clip so start recording
      touch $LOCKFILE
      if [ "$1" == "area" ]; then
        ${pkgs.wl-screenrec}/bin/wl-screenrec -g "$(${pkgs.slurp}/bin/slurp)" -f "$FILE"
      else # full screen
        # TODO: use -o and do 'current screen'
        ${pkgs.wl-screenrec}/bin/wl-screenrec --audio "$(${pkgs.pulseaudio}/bin/pactl get-default-sink)" -f "$FILE"
      fi
      notify-send "recording ended"
      rm "$LOCKFILE"
    else # Already recording a clip so stop and save it
      OUT="/home/wumpus/Videos/clips/$(date +%Y-%m-%d_%H-%M-%S).mp4"
      pkill wl-screenrec
      # TODO: replace me with ffmpeg compression
      mv "$FILE" "$OUT"
      wl-copy -t text/uri-list <<< "file://$OUT"
      rm "$LOCKFILE"
    fi
  '';

  /*
    monitor_change = pkgs.writeShellScript "monitor_change" ''

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
      '';
  */

in
{
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
    dash
  ];

  xdg.configFile."hypr/shaders".source = "${./shaders}";

  xdg.portal = {
    enable = true;
    configPackages = [ config.wayland.windowManager.hyprland.package ];
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

      background = [
        {
          monitor = "";
          path = "${../../assets/nix.jpg}";
          color = "rgb(36, 39, 58)";
        }
      ];

      label = [
        {
          monitor = "";
          text = ''$TIME'';
          #text = '' cmd[update:900] echo "hello $USER<br/>$(date +%H:%M:%S)" '';
          text_align = "center";
          color = "rgb(202, 211, 245)";
          font_size = "35";
          position = "0, -80";
          halign = "center";
          valign = "top";
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "200, 50";
          position = "0, 5";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = (
            if osConfig.local.isDesktop then
              ''<span foreground="##cad3f5">Password...</span>''
            else
              ''<span foreground="##cad3f5">Press index finger on the fingerprint sensor</span>''
          );
          shadow_passes = 2;
        }
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
        before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
        after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
      };

      # lock screen
      listener = [
        {
          timeout = 300; # 5 min
          on-timeout = "loginctl lock-session";
          #on-resume = notify-send "Welcome back!"
        }
        # turn off screen
        {
          timeout = 600; # 10 min
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        (
          if !osConfig.local.isDesktop then
            # suspend (and then eventually hibernate)
            {
              timeout = 900; # 15min
              on-timeout = "systemctl suspend-then-hibernate";
            }
          else
            { }
        )
      ];
    };
  };

  programs.tofi = {
    enable = true;
    catppuccin.enable = false;
    settings = {
      fuzzy-match = "true";
      ascii-input = "true";
      hint-font = "false";

      prompt-text = ''"" '';
      placeholder-text = "> ";

      font = "${pkgs.rubik}/share/fonts/truetype/Rubik-Regular.ttf";
      font-size = 30;

      width = 500;
      height = 620;

      border-width = 3;
      outline-width = 0;
      corner-radius = 15;

      # text
      text-color = "#cad3f5";

      # subtext 1
      placeholder-color = "#b8c0e0";

      # surface0
      background-color = "#363a4f";

      # mauve
      border-color = "#c6a0f6";
      selection-color = "#c6a0f6";

      # pink
      selection-match-color = "#f5bde6";

    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.default;
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "${menu}";

      monitor = (
        if osConfig.local.isDesktop then
          [ ''DP-1,2560x1440@144,0x0,1'' ]
        else
          [
            "eDP-1,2560x1600@165,0x0,1.6,vrr,1"
            "eDP-2,2560x1600@165,0x0,1.6,vrr,1"
            ",highres,auto,1"
          ]
      );

      input = {
        kb_layout = "gb";
        kb_options = "caps:swapescape";
      };

      general = {
        gaps_in = -1;
        gaps_out = 0;
        "col.inactive_border" = "rgb(363a4f)"; # Surface 0
        "col.active_border" = "rgb(c6a0f6)"; # Mauve
        border_size = 2;
      };

      decoration = {
        dim_around = 0.2; # dimming around modals
        rounding = 0;
        blur = {
          enabled = false;
        };
        shadow = {
          enabled = false;
        };
      };

      animations = {
        enabled = "yes";
        first_launch_animation = "false";
      };

      gestures = {
        workspace_swipe = "true";
        workspace_swipe_cancel_ratio = 0.3;
      };

      dwindle = {
        preserve_split = 1;
        smart_split = 1;
      };

      misc = {
        force_default_wallpaper = 0;
        mouse_move_enables_dpms = 1;
        key_press_enables_dpms = 1;
      };

      xwayland = {
        force_zero_scaling = 1;
      };
      windowrulev2 = [
        # disable blur for all windows by default
        "noblur, initialtitle:.*"

        "float, initialclass: xdg-desktop-portal-gtk"
        "dimaround, initialclass: xdg-desktop-portal-gtk"
        #"opacity 0.95, initialTitle: Alacritty"
        #"opacity 0.95, initialTitle: foot"

        # modalify tag:modal windows
        "float, tag:modal"
        "pin, tag:modal"
        "center, tag:modal"
        "bordercolor rgb(c6a0f6) rgba(c6a0f688), pinned:1"
      ];
      layerrule = [
        "blur, ^bar.*"
        "ignorezero, ^bar.*"

        # disable animations for tofi
        "noanim, launcher"
        "noanim, ^ags-.*"
      ];
      exec-once = [
        "swww-daemon"
        "sleep 10 && swww img ${../../assets/wallpaper.png}"
        #"waybar"
        "ags"
        #"$\{monitor_change} # handles ags restarting"
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "wl-paste --watch cliphist store"
        "${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1"
        "hypridle"
        "hyprctl setcursor Qogir 24"
      ];
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];
      bindl = [
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"

        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"

        ", XF86MonBrightnessUp,  exec, brightnessctl s +5%"
        ", XF86MonBrightnessDown,  exec, brightnessctl s 5%-"
      ];

      bind =
        [
          "$mod, Q, exec, $terminal"
          "$mod, M, exit"
          "$mod, C, killactive"

          "$mod, S, exec, ${pkgs.tofi}/bin/tofi-drun --drun-launch=true"

          '', F12, exec, grimshot --notify savecopy area "${config.xdg.userDirs.pictures}/screenshots/$(TZ=utc date +'%d-%m-%Y %H:%M:%S %2N.png')"''
          ''Shift, F12, exec, grimshot --notify savecopy active "${config.xdg.userDirs.pictures}/screenshots/$(TZ=utc date +'%d-%m-%Y %H:%M:%S %2N.png')"''
          "$mod, R, exec, ${record} 'area'"
          "Shift + $mod, R, exec, ${record} 'screen'"
          "SHIFT + SUPER + CTRL + ALT, L, exec, xdg-open 'https://linkedin.com/'"

          "$mod, P, exec, ${show_clipboard}"
          "$mod, F, fullscreen"

          "$mod, Left, movefocus, l"
          "$mod, Right, movefocus, r"
          "$mod, Up, movefocus, u"
          "$mod, Down, movefocus, d"

        ]
        ++ (
          # binds $mod + 1..10 to workspace 1..10
          builtins.concatLists (
            builtins.genList (
              x:
              let
                ws =
                  let
                    c = (x + 1) / 10;
                  in
                  builtins.toString (x + 1 - (c * 10));
              in
              [
                "$mod, ${ws}, workspace, ${toString (x + 1)}"
                "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
              ]
            ) 10
          )
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
        action = "systemctl suspend-then-hibernate";
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
    style = # css
      ''
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
  };

  programs.ags = {
    enable = true;
    configDir = ./ags;
    # extraPackages isn't working for some reason
    #extraPackages = with pkgs; [
    #  bun
    #];
  };

  programs.waybar = {
    enable = true;
    style = ''${builtins.readFile ./waybar/waybar.css}'';
    # thank you https://git.sr.ht/~begs/dotfiles/tree/master/item/.config/waybar/config
    settings = [
      {
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
          (if osConfig.local.isDesktop then "disk" else "battery")
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
        #  format = " {}";
        #  min-length = 5;
        #  on-click = "swaymsg 'input * xkb_switch_layout next'";
        #  tooltip = false;
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
            default = [
              ""
              ""
            ];
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
      }
    ];
  };
}
