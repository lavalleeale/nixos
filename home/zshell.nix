{
  lib,
  uiSettings ? { },
  ...
}:

let
  graphical = uiSettings.graphical or false;
  wsl = uiSettings.wsl or false;
in
{
  home.shellAliases = {
    bell = ''echo -e "\a"'';
    pbcopy = if wsl then "clip.exe" else "wl-copy";
    pbpaste = if wsl then "powershell.exe -NoProfile -Command Get-Clipboard" else "wl-paste";
    please = "sudo $(fc -ln -1)";
    open = if wsl then "explorer.exe" else "xdg-open";
    vg = "valgrind --leak-check=full --track-origins=yes --show-reachable=yes";
    ls = "eza";
    ll = "eza -l";
    nix-s = "nix-shell --run $SHELL -p";
    buildhome = "home-manager switch --flake ~/Documents/Programming/nixos#alex --cores 0 --option keep-going true -j auto";
  };

  programs = {
    home-manager.enable = true;
    direnv.enable = true;

    zsh = {
      enable = true;
      initContent = ''
        mklatex() {
            if [ -z "$1" ]; then
                echo "Usage: mklatex <filename>"
                return 1
            fi
            local filename="$1"
            latexmk -pdf -halt-on-error "$filename" && latexmk -c "$filename"
        }
      ''
      + lib.optionalString graphical ''
        split() {
            local escaped
            escaped=$(printf '%q ' "$@")
            hyprctl dispatch exec "alacritty --working-directory $(pwd) -e sh -c \"$escaped\""
        }
      ''
      + ''
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word
        export GPG_TTY=$(tty)
      ''
      + lib.optionalString graphical ''
        wal -Rq
      ''
      + ''
        autoload -U edit-command-line
        zle -N edit-command-line
        bindkey '^xe' edit-command-line
        bindkey '^x^e' edit-command-line
      '';
      sessionVariables = {
        EDITOR = "code --wait";
        VISUAL = "code --wait";
        DIRENV_LOG_FORMAT = "";
      };
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };

    zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
    };

    atuin.enable = true;

    starship = {
      enable = true;
      settings = {
        format = "[](red)$os$username[](bg:blue fg:red)$directory[](fg:blue bg:green)$git_branch$git_status[](fg:green bg:cyan)$nix_shell[](fg:cyan bg:yellow)$time[ ](fg:yellow)";
        username = {
          show_always = true;
          style_user = "bg:red";
          style_root = "bg:red";
          format = "[$user ]($style)";
          disabled = false;
        };
        os = {
          style = "bg:#9A348E";
          disabled = true;
        };
        directory = {
          style = "bg:blue";
          format = "[ $path ]($style)";
          truncation_length = 3;
          truncation_symbol = "…/";
          substitutions = {
            "Documents" = "󰈙 ";
            "Downloads" = " ";
            "Music" = " ";
            "Pictures" = " ";
          };
        };
        c = {
          symbol = " ";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        nix_shell = {
          style = "bg:cyan fg:white";
          format = "[via $symbol(($name))]($style)";
        };
        elixir = {
          symbol = " ";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        elm = {
          symbol = " ";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        git_branch = {
          symbol = "";
          style = "bg:green";
          format = "[ $symbol $branch ]($style)";
        };
        git_status = {
          style = "bg:green";
          format = "[ $all_status$ahead_behind ]($style)";
        };
        golang = {
          symbol = " ";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        gradle = {
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        haskell = {
          symbol = " ";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        java = {
          symbol = " ";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        julia = {
          symbol = " ";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        nodejs = {
          symbol = "";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        nim = {
          symbol = "󰆥 ";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        rust = {
          symbol = "";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        scala = {
          symbol = " ";
          style = "bg:cyan";
          format = "[ $symbol ($version) ]($style)";
        };
        time = {
          disabled = false;
          time_format = "%R";
          style = "bg:yellow";
          format = "[ $time ]($style)";
        };
      };
    };
  };
}
