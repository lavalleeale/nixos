{
  pkgs,
  config,
  lib,
  uiSettings ? { },
  ...
}:

let
  batteryPath = uiSettings.batteryPath or null;
  batteryStatusPath = if batteryPath != null then "${builtins.dirOf batteryPath}/status" else null;
  hyprlockWallpaper = uiSettings.hyprlockWallpaper or config.pywal-nix.colourScheme.wallpaper;
  hyprlockProfileImage = uiSettings.hyprlockProfileImage or null;
  hyprlockLabels = [
    {
      monitor = "";
      text = ''cmd[update:1000] date +"%A, %B %d"'';
      color = "rgba(242, 243, 244, 0.75)";
      font_size = 22;
      font_family = "JetBrains Mono";
      position = "0, 350";
      halign = "center";
      valign = "center";
    }
    { text = "$FPRINTPROMPT"; }
    {
      monitor = "";
      text = ''cmd[update:1000] date +"%-I:%M"'';
      color = "rgba(242, 243, 244, 0.75)";
      font_size = 95;
      font_family = "JetBrains Mono Extrabold";
      position = "0, 200";
      halign = "center";
      valign = "center";
    }
    {
      monitor = "";
      text = "cmd[update:1000] id -nu";
      color = "rgb(ffffff)";
      font_size = 14;
      font_family = "JetBrains Mono";
      position = "0, -10";
      halign = "center";
      valign = "top";
    }
  ]
  ++ lib.optionals (batteryPath != null) [
    {
      monitor = "";
      text = "cmd[update:1000] cat ${batteryPath}";
      color = "rgb(ffffff)";
      font_size = 24;
      font_family = "JetBrains Mono";
      position = "-90, -10";
      halign = "right";
      valign = "top";
    }
  ];
  topbarBatteryCommand =
    if batteryPath != null then
      "cap=$(cat ${batteryPath}); status=$(cat ${batteryStatusPath} 2>/dev/null || true); case $status in Charging) icon='' ;; 'Not charging') icon='' ;; *) if [ $cap -lt 20 ]; then icon=''; elif [ $cap -lt 40 ]; then icon=''; elif [ $cap -lt 60 ]; then icon=''; elif [ $cap -lt 80 ]; then icon=''; else icon=''; fi ;; esac; printf '%s %s%%' $icon $cap"
    else
      "printf ''";
  topbarQml =
    builtins.replaceStrings
      [
        "@showBattery@"
        "@foreground@"
        "@background@"
        "@accent@"
        "@batteryCommand@"
      ]
      [
        (if batteryPath != null then "true" else "false")
        config.pywal-nix.colourScheme.special.foreground
        config.pywal-nix.colourScheme.special.background
        config.pywal-nix.colourScheme.colours.color5
        topbarBatteryCommand
      ]
      (builtins.readFile ./quickshell-topbar.qml);
in
lib.mkIf (uiSettings.graphical or false) {
  services = {
    dunst = {
      enable = true;
      settings = {
        global = {
          width = 445;
          height = 445;
          offset = "(10, 10)";
          corner_radius = 10;
          padding = 13;
          horizontal_padding = 15;
          idle_threshold = 120;
          font = "Fira Mono 16";
          alignment = "left";
          format = "<b>%s (%a)</b>\\n%b";
          markup = "full";
          max_icon_size = 64;
          browser = "xdg-open";
          history_length = 10;
          line_height = 16;
          dmenu = "gorg -m dmenu";
        };
        urgency_low = {
          background = config.pywal-nix.colourScheme.special.background;
          foreground = config.pywal-nix.colourScheme.colours.color6;
        };
        urgency_normal = {
          background = config.pywal-nix.colourScheme.special.background;
          foreground = config.pywal-nix.colourScheme.colours.color6;
        };
        urgency_critical = {
          background = config.pywal-nix.colourScheme.special.background;
          foreground = config.pywal-nix.colourScheme.colours.color6;
        };
      };
    };
    hyprpaper = {
      enable = true;
      settings = {
        ipc = false;
        wallpaper = [
          {
            monitor = "";
            path = "${config.pywal-nix.colourScheme.wallpaper}";
            fit_mode = "cover";
          }
        ];
      };
    };

    hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };
        listener = {
          timeout = 150;
          on-timeout = "brightnessctl -s set 0";
          on-resume = "brightnessctl -r";
        };
      };
    };
  };

  systemd.user.services.hyprpaper = {
    Install.WantedBy = lib.mkForce [ "hyprland-session.target" ];
    Unit = {
      After = lib.mkForce [ "hyprland-session.target" ];
      PartOf = lib.mkForce [ "hyprland-session.target" ];
    };
  };

  programs = {
    hyprlock = {
      enable = true;
      settings = (
        {
          background = {
            monitor = "";
            path = hyprlockWallpaper;
            color = "rgba(0, 0, 0, 0)";
            blur_passes = 2;
            contrast = 1;
            brightness = 0.5;
            vibrancy = 0.2;
            vibrancy_darkness = 0.2;
          };
          general = {
            hide_cursor = false;
            grace = 0;
            disable_loading_bar = true;
          };
          auth = {
            fingerprint = {
              enabled = true;
              ready_message = "Scan fingerprint to unlock";
              present_message = "Scanning...";
            };
          };
          input-field = {
            monitor = "";
            size = "250, 60";
            outline_thickness = 2;
            dots_size = 0.2;
            dots_spacing = 0.35;
            dots_center = true;
            outer_color = "rgba(255, 255, 255, 0.2)";
            inner_color = "rgba(0, 0, 0, 0.2)";
            font_color = "rgb(ffffff)";
            fade_on_empty = false;
            rounding = -1;
            check_color = "rgb(204, 136, 34)";
            placeholder_text = ''<i><span foreground="##cdd6f4">Input Password...</span></i>'';
            hide_input = false;
            position = "0, -200";
            halign = "center";
            valign = "center";
          };
          label = hyprlockLabels;
        }
        // lib.optionalAttrs (hyprlockProfileImage != null) {
          image = {
            monitor = "";
            path = hyprlockProfileImage;
            size = 100;
            border_size = 2;
            border_color = "rgb(ffffff)";
            position = "0, -100";
            halign = "center";
            valign = "center";
          };
        }
      );
    };

    quickshell = {
      enable = true;
      systemd.enable = true;
      activeConfig = "topbar";
      configs = {
        topbar = pkgs.writeTextDir "shell.qml" topbarQml;
      };
    };
  };
}
