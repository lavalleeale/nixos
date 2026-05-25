{ config, lib, pkgs, uiSettings ? { graphical = true; }, ... }:

lib.mkIf (uiSettings.graphical or false) {
  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };

  pywal-nix.wallpaper = ../wallpapers/current;

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-qt;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = 0.5;
        blur = true;
      };
      font.bold = {
        family = "FiraCode Nerd Font Mono";
        style = "Bold";
      };
      font.bold_italic = {
        family = "FiraCode Nerd Font Mono";
        style = "Bold Italic";
      };
      font.italic = {
        family = "FiraCode Nerd Font Mono";
        style = "Italic";
      };
      font.normal = {
        family = "FiraCode Nerd Font Mono";
        style = "Regular";
      };
      keyboard.bindings = [{
        key = "N";
        mods = "Control|Shift";
        action = "CreateNewWindow";
      }];
      hints.enabled = [
        {
          regex =
            "https?:\\\\/\\\\/[\\\\w.]*(?:[-a-zA-Z0-9()@:%_\\\\+.~#?&\\\\/=]*)";
          command = {
            program = "zen-beta";
            args = [ "--new-tab" ];
          };
          mouse = { enabled = true; };
        }
        {
          regex = "[\\\\w\\\\.-][\\\\w/-]+\\\\.\\\\S+(:\\\\d+:\\\\d+)?";
          command = {
            program = "code";
            args = [ "--goto" ];
          };
          mouse = { enabled = true; };
        }
      ];
    };
  };
}
