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
      browser = if uiSettings.hardwareVideoDecode or false then zen-browser-vaapi else zen-browser;

      texlive-custom = texlive.combine {
        inherit (pkgs.texlive)
          scheme-medium
          titlesec
          fontawesome
          changepage
          enumitem
          ;
      };

      commonDevTools = [
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

      mediaTools = [ imagemagick ];

      scienceTools = [
        mars-mips
        texlive-custom
      ];

      commonSecurityTools = [
        openssl
        yubikey-manager
        bitwarden-cli
      ];

      commonEditors = [
        pkgs-unstable.neovim
        vim
      ];

      commonUtilities = [
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
      ];

      graphicalDesktopApps = [
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

      graphicalEditors = [
        android-studio
        jetbrains.clion
        jetbrains.phpstorm
        pkgs-unstable.vscode
      ];

      graphicalSecurityTools = [
        sbctl
        tpm2-tools
      ];

      graphicalUtilities = [
        gorg
        wl-paste
        perf
        mangohud
        monero-gui
        power-profiles-daemon
        pywal
        samba
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

      virtualizationTools = [
        (vagrant.override { withLibvirt = false; })
        dnsmasq
        packer
        virt-manager
      ];

      graphicalWorkstationPackages = graphicalDesktopApps ++ waylandTools ++ virtualizationTools;
    in
    commonDevTools
    ++ mediaTools
    ++ scienceTools
    ++ commonSecurityTools
    ++ lib.optionals graphical graphicalSecurityTools
    ++ lib.optionals graphical graphicalWorkstationPackages
    ++ commonUtilities
    ++ lib.optionals graphical graphicalUtilities
    ++ commonEditors
    ++ lib.optionals graphical graphicalEditors;
}
