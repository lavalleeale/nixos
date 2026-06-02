{
  lib,
  pkgs,
  pkgs-unstable,
  uiSettings ? {
    graphical = true;
  },
  ...
}:

{
  home.packages =
    with pkgs;
    let
      graphical = uiSettings.graphical or false;
      wsl = uiSettings.wsl or false;
      browser = if uiSettings.hardwareVideoDecode or false then zen-browser-vaapi else zen-browser;
      mediaTools = [ imagemagick ];

      scienceTools = [
        mars-mips
        texlive-custom
      ];
      texlive-custom = texlive.combine {
        inherit (pkgs.texlive)
          scheme-medium
          titlesec
          fontawesome
          changepage
          enumitem
          ;
      };

      editors = [
        pkgs-unstable.neovim
        vim
      ]
      ++ lib.optionals graphical [
        android-studio
        jetbrains.clion
        jetbrains.phpstorm
        pkgs-unstable.vscode
      ];

      securityTools = [
        openssl
        yubikey-manager
        bitwarden-cli
      ]
      ++ lib.optionals graphical [
        sbctl
        tpm2-tools
      ];

      virtTools = [
        (vagrant.override { withLibvirt = false; })
        dnsmasq
        packer
        virt-manager
      ];

      desktopApps = [
        catppuccin-papirus-folders
        alacritty
        kdePackages.dolphin
        dunst
        google-chrome
        firefox
        browser
        kitty
        obsidian
        parsec-bin
        ledger-live-desktop
        postman
        prismlauncher
        tetrio-desktop
        tor-browser
        vesktop
        vlc
      ];

      waylandTools = [
        brightnessctl
        hyprpaper
        hyprshot
        hyprsunset
        pamixer
        rofi
        wayvnc
        wl-clipboard
      ];

      otherUtils = [
        borgbackup
        code-cursor
        dmenu
        eza
        flintlock
        libimobiledevice
        libisoburn
        monero-cli
        unzip
        valgrind
        xdg-utils
      ]
      ++ lib.optionals graphical [
        gorg
        wl-paste
        perf
        mangohud
        monero-gui
        power-profiles-daemon
        pywal
        samba
      ];

      devUtils = [
        act
        atuin
        cachix
        cypress
        usbmuxd
        gemini-cli
        gh
        jq
        niv
        nix-output-monitor
        nixfmt
        nixpkgs-fmt
        starship
        zoxide
      ];
    in
    devUtils
    ++ mediaTools
    ++ scienceTools
    ++ securityTools
    ++ lib.optionals graphical (desktopApps ++ waylandTools ++ virtTools)
    ++ otherUtils
    ++ editors;
}
