{ lib, pkgs, ... }:

{
  wsl = {
    enable = true;
    defaultUser = "alex";
    startMenuLaunchers = true;
    wslConf = {
      automount.root = "/mnt";
      interop.enabled = true;
      network.generateHosts = true;
      network.generateResolvConf = true;
    };
  };

  networking.hostName = "nixos-wsl";

  services.openssh.enable = lib.mkForce false;
  services.tailscale.enable = lib.mkForce false;

  users.users.alex.initialPassword = "password";

  environment.systemPackages = with pkgs; [ curl wslu ];
}
