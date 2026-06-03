{
  inputs,
  system,
  sharedConfig,
  overlay,
  pkgs-unstable,
}:

let
  inherit (inputs.nixpkgs) lib;

  homeBaseModule = import ../home.nix;
  homeDesktopModule = {
    imports = [
      ../home/desktop.nix
      ../home/hyprland.nix
      ../home/hyprland-ui.nix
    ];
  };
  homeManagerSharedModules = [ inputs.pywal-nix.homeManagerModules.${system}.default ];

  commonSpecialArgs = { inherit pkgs-unstable; };
  commonHomeSpecialArgs = commonSpecialArgs;

  nixpkgsModule = {
    nixpkgs = {
      config = sharedConfig;
      overlays = [ overlay ];
    };
  };

  registryModule = {
    nix.registry.nixpkgs.flake = inputs.nixpkgs;
  };

  uiSettingsLib = import ./ui-settings.nix;

  mkHomeModule =
    { graphical, ... }:
    {
      imports = [ homeBaseModule ] ++ lib.optionals graphical [ homeDesktopModule ];
    };

  mkHomeManagerModule =
    { graphical, uiSettings }:
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.alex = mkHomeModule { inherit graphical uiSettings; };
        backupFileExtension = "backup";
        sharedModules = homeManagerSharedModules;
        extraSpecialArgs = commonHomeSpecialArgs // {
          inherit uiSettings;
        };
      };
    };

  mkHost =
    {
      graphical ? false,
      isWsl ? false,
      uiSettings ? uiSettingsLib.mkUiSettings {
        inherit graphical;
        wsl = isWsl;
      },
      modules,
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = commonSpecialArgs // {
        inherit isWsl;
      };
      modules = [
        nixpkgsModule
        (mkHomeManagerModule { inherit graphical uiSettings; })
        inputs.home-manager.nixosModules.home-manager
      ]
      ++ lib.optionals graphical [
        {
          environment.pathsToLink = [
            "/share/applications"
            "/share/xdg-desktop-portal"
          ];
        }
      ]
      ++ modules
      ++ [ registryModule ];
    };
in
{
  inherit
    commonHomeSpecialArgs
    homeManagerSharedModules
    mkHomeModule
    mkHost
    ;
}
