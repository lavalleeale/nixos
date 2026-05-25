{ lib, config, pkgs, hyprland-plugins, uiSettings ? { }, ... }:

let
  stripFirst = s: builtins.substring 1 (builtins.stringLength s - 1) s;
  hyprlandMonitors = uiSettings.hyprlandMonitors or [ ",preferred,auto,auto" ];
in lib.mkIf (uiSettings.graphical or false) {
  wayland.windowManager.hyprland = {
    enable = true;
    plugins = let plugins = hyprland-plugins.packages.${pkgs.system};
    in [ plugins.hyprexpo ];
    settings = {
      plugin = { hyprexpo = { columns = 2; }; };
      general = {
        gaps_in = 5;
        gaps_out = 15;
        border_size = 3;
        "col.active_border" = "$color1 $color1 $color2 45deg";
        "col.inactive_border" = "$color3 $color3 $color4 45deg";
        resize_on_border = true;
        allow_tearing = false;
        layout = "dwindle";
      };
      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 0.8;
        blur = {
          enabled = true;
          size = 2;
          passes = 1;
          special = true;
          vibrancy = 0.1696;
        };
      };
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 10, myBezier, slide"
          "specialWorkspace, 1, 6, myBezier, slidefadevert -80"
        ];
      };
      misc = {
        force_default_wallpaper = 1;
        disable_hyprland_logo = true;
      };
      gesture = "4, horizontal, workspace";
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
          disable_while_typing = false;
        };
      };
      device = [
        {
          name = "frmw0004:00-32ac:0006-consumer-control-1";
          natural_scroll = true;
        }
        {
          name = "thinkpad-essential-wireless-mouse";
          sensitivity = -1.0;
        }
        {
          name = "logitech-usb-receiver";
          sensitivity = -0.75;
        }
      ];
      xwayland.force_zero_scaling = true;
      monitor = hyprlandMonitors;
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "ELECTRON_OZONE_PLATFORM_HINT,wayland"
        "QT_QPA_PLATFORMTHEME,qt6ct"
        "GOPATH,$HOME/go"
        "GOBIN,$HOME/go/bin"
        "YARNBIN,$HOME/.yarn/bin"
        "PYENV_ROOT,$HOME/.pyenv"
        "PATH,$HOME/.pyenv/bin:$PATH:$HOME/go/bin:$HOME/.yarn/bin:$HOME/.local/bin:$HOME/.rvm/bin"
        "XDG_CONFIG_HOME,$HOME/.config"
        "XDG_DATA_HOME,$HOME/.local/share"
        "HYPRSHOT_DIR,$HOME/Screenshots"
      ];
      exec-once = [
        "/usr/lib/polkit-kde-authentication-agent-1"
        "hyprsunset"
        "dunst"
        "quickshell --config topbar"
        "xremap $HOME/.config/xremap/config.yml"
        "sleep 1 && wl-copy-slurp"
        "[workspace $zenWorkspace silent] zen-beta"
        "[workspace $terminalWorkspace silent] alacritty"
        "[workspace $codeWorkspace silent] code"
        "[workspace $obsidianWorkspace silent] obsidian"
      ];
      "$mainMod" = "SUPER";
      "$zenWorkspace" = "1";
      "$terminalWorkspace" = "2";
      "$codeWorkspace" = "3";
      "$obsidianWorkspace" = "4";
      bind = [
        "$mainMod, RETURN, exec, alacritty"
        "$mainMod, C, killactive,"
        "$mainMod, L, exec, hyprlock"
        "$mainMod, J, togglefloating,"
        "$mainMod, space, exec, pidof gorg || gorg -a"
        ''$mainMod, grave, exec, sh -c "dunstify "Start and size" "$(slurp)"''
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        "$mainMod, Tab, workspace, $zenWorkspace"
        "$mainMod, q, workspace, $terminalWorkspace"
        "$mainMod, w, workspace, $codeWorkspace"
        "$mainMod, e, workspace, $obsidianWorkspace"
        "$mainMod, r, workspace, 5"
        "$mainMod SHIFT, Tab, movetoworkspace, $zenWorkspace"
        "$mainMod SHIFT, q, movetoworkspace, $terminalWorkspace"
        "$mainMod SHIFT, w, movetoworkspace, $codeWorkspace"
        "$mainMod SHIFT, e, movetoworkspace, $obsidianWorkspace"
        "$mainMod SHIFT, r, movetoworkspace, 5"
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
        ", PRINT, exec, hyprshot -m window -m active --clipboard-only"
        "$shiftMod, PRINT, exec, hyprshot -m region --clipboard-only"
        "$mainMod, H, exec, dunstctl close"
        "$mainMod SHIFT, H, exec, dunstctl history-pop"
        "$mainMod, V, exec, wl-copy-picker gorg -m equation,dmenu"
        "$mainMod, G, togglegroup"
        "$mainMod, N, changegroupactive, f"
        "$mainMod SHIFT, N, changegroupactive, b"
        "$mainMod, B, exec, $HOME/.local/bin/btcon"
        "$mainMod, F, fullscreen"
      ];
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
      bindel = [
        ",XF86AudioRaiseVolume, exec, pamixer -i 5"
        ",XF86AudioLowerVolume, exec, pamixer -d 5"
        ",XF86AudioMute, exec, pamixer -t"
        ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
        ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
        "SHIFT,XF86MonBrightnessUp, exec, hyprctl hyprsunset identity"
        "SHIFT,XF86MonBrightnessDown, exec, hyprctl hyprsunset temperature 1000"
      ];
      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];
      windowrulev2 = [
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
        "workspace $zenWorkspace, class:zen-beta"
        "workspace $codeWorkspace, class:code"
        "group, class:code"
        "float, title:Picture-in-Picture"
        "pin, title:Picture-in-Picture"
        "size 30% 30%, title:Picture-in-Picture"
      ];
    } // lib.genAttrs ((builtins.genList (i: "$color" + toString i) 16)
      ++ [ "$background" "$foreground" "$cursor" ]) (name:
        let key = stripFirst name;
        in "rgb(" + stripFirst
        (if lib.hasAttr key config.pywal-nix.colourScheme.colours then
          config.pywal-nix.colourScheme.colours.${key}
        else
          config.pywal-nix.colourScheme.special.${key}) + ")");
  };
}
