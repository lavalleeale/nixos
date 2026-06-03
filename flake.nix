{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    impermanence.url = "github:nix-community/impermanence";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pywal-nix = {
      url = "github:lavalleeale-forks/pywal.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser-flake = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gorg-flake = {
      url = "github:lavalleeale/gorg";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wl-paste-flake = {
      url = "github:lavalleeale/wl-paste-cpp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/hyprland/v0.53.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    authentik-nix = {
      url = "github:nix-community/authentik-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      system = "x86_64-linux";
      sharedConfig = {
        allowUnfree = true;
      };
      overlay = import ./lib/overlay.nix { inherit inputs system; };
      pkgs = import nixpkgs {
        inherit system;
        config = sharedConfig;
        overlays = [ overlay ];
      };
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config = sharedConfig;
      };
      hostLib = import ./lib/hosts.nix {
        inherit
          inputs
          system
          sharedConfig
          overlay
          pkgs-unstable
          ;
      };
      uiSettings = import ./lib/ui-settings.nix;
    in
    {
      formatter.${system} = pkgs.nixfmt-tree;

      homeConfigurations = {
        alex = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = hostLib.commonHomeSpecialArgs // {
            uiSettings = uiSettings.laptop;
          };
          modules = hostLib.homeManagerSharedModules ++ [
            (hostLib.mkHomeModule {
              graphical = true;
              uiSettings = uiSettings.laptop;
            })
          ];
        };
      };

      nixosConfigurations = {
        laptop = hostLib.mkHost {
          graphical = true;
          uiSettings = uiSettings.laptop;
          modules = [
            inputs.lanzaboote.nixosModules.lanzaboote
            inputs.impermanence.nixosModules.impermanence
            inputs.nixos-hardware.nixosModules.framework-13-7040-amd
            inputs.sops-nix.nixosModules.sops
            ./configuration.nix
            ./laptop.nix
            ./laptop-hardware-configuration.nix
          ];
        };

        desktop = hostLib.mkHost {
          graphical = true;
          uiSettings = uiSettings.desktop;
          modules = [
            ./configuration.nix
            ./desktop.nix
            ./desktop-hardware-configuration.nix
          ];
        };

        wsl = hostLib.mkHost {
          isWsl = true;
          uiSettings = uiSettings.wsl;
          modules = [
            inputs.nixos-wsl.nixosModules.default
            ./configuration.nix
            ./wsl.nix
          ];
        };

        server = hostLib.mkHost {
          modules = [
            inputs.sops-nix.nixosModules.sops
            inputs.authentik-nix.nixosModules.default
            ./configuration.nix
            ./server.nix
          ];
        };
      };
    };
}
