{ lib, ... }:
{
  services.openssh.enable = true;
  users.mutableUsers = lib.mkForce true;
}
