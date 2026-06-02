{ ... }:
{
  imports = [
    ./home/packages.nix
    ./home/zshell.nix
    ./home/git.nix
  ];

  home = {
    username = "alex";
    homeDirectory = "/home/alex";
    stateVersion = "25.05";
  };

}
