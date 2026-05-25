{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Alex Lavallee";
        email = "73203142+lavalleeale@users.noreply.github.com";
      };
      "credential \"https://github.com\"".helper =
        "!/run/current-system/sw/bin/gh auth git-credential";
      "credential \"https://gist.github.com\"".helper =
        "!/run/current-system/sw/bin/gh auth git-credential";
    };
    signing = {
      key = "34F2E4A1C992F98B51C01D22968D37F0C632E219";
      signByDefault = true;
    };
    ignores = [
      ".direnv"
      ".envrc"
      "shell.nix"
      "default.nix"
      "Session.vim"
      "venv"
      "aliases.zsh"
      ".copilot-pull-request-description-instructions.md"
    ];
  };
}
