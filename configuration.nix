# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  isWsl ? false,
  ...
}:

let
  hostOnly = !isWsl;
in
{
  boot.kernel.sysctl = {
    "fs.file-max" = "1048576"; # Example value
  };
  time.timeZone = "America/Los_Angeles";

  services = {
    openssh = {
      enable = true;
      ports = [ 22 ];
      settings.PermitRootLogin = "no";
    };
    avahi = lib.mkIf hostOnly {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
    };
    fwupd.enable = hostOnly;
    tailscale.enable = true;
    nixseparatedebuginfod2.enable = true;
    devmon.enable = hostOnly;
  };
  programs.zsh.enable = true;
  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.zsh;
    users = {
      alex = {
        createHome = true;
        isNormalUser = true;
        extraGroups = [
          "wheel"
        ]
        ++ lib.optionals hostOnly [
          "libvirtd"
          "docker"
          "tss"
          "input"
          "dialout"
          "audio"
        ]; # Enable ‘sudo’ for the user.
      };
    };
  };

  nix = {
    settings = {
      max-jobs = "auto";
      cores = 0;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://lavalleeale.cachix.org"
        "https://cache.nixos.org/"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "lavalleeale.cachix.org-1:durM7fu7UhmWkgUoc/3lUQF30Z+rEVNmFb0lRrhIO7Y="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };

  networking.networkmanager.enable = hostOnly;

  environment.systemPackages =
    with pkgs;
    let
      python3-custom = python3.withPackages (
        ps: with ps; [
          aiohttp
          pylast
          argparse
          beautifulsoup4
          black
          datadog
          jupyter
          lxml
          matplotlib
          nltk
          notebook
          numpy
          pandas
          ps
          pylint
          requests
          tqdm
          websockets
        ]
      );

      # Development tools
      devTools = [
        cmake
        gnupg
        gcc
        git
        git-lfs
        gnumake
        go
        lua-language-server
        nodejs_22
        php
        chezmoi
        pkg-config
        postgresql_14
        python3-custom
        rustfmt
        ruby
        sqlite
        yarn
        jdk
        file
      ]
      ++ lib.optionals hostOnly [
        fw-ectool
        waypaper
        usbutils
        jetbrains.idea
        slurp
      ];

      sysUtils = [
        bc
        btop
        playerctl
        dig
        fd
        htop
        inotify-tools
        iproute2
        killall
        lm_sensors
        lsof
        ncdu
        ripgrep
        wget
        socat
        trash-cli
      ]
      ++ lib.optionals hostOnly [
        clipman
        solaar
        xremap
      ];
    in
    devTools ++ sysUtils;
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      font-awesome
      powerline-fonts
      powerline-symbols
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
    ];
    fontconfig = {
      defaultFonts = {
        serif = [
          "Liberation Serif"
          "Vazirmatn"
        ];
        sansSerif = [
          "Ubuntu"
          "Vazirmatn"
        ];
        monospace = [ "Ubuntu Mono" ];
      };
    };
  };
  system.stateVersion = "25.05"; # Did you read the comment?
}
