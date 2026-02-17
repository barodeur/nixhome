{ ... }:

{
  programs = {
    git = {
      enable = true;

      settings = {
        alias = {
          st = "status";
          amend = "commit --amend";
          co = "checkout";
          l = "log --graph --date=short";
          c = "commit -m";
        };

        color = {
          ui = true;
        };

        init = {
          defaultBranch = "main";
        };

        format = {
          pretty = "format:%C(blue)%ad%Creset %C(yellow)%h%C(green)%d%Creset %C(blue)%s %C(magenta) [%an]%Creset";
        };

        push = {
          autoSetupRemote = true;
        };
      };

      ignores = [
        ".DS_Store"
        "*.swp"
        ".venv"
        ".tern-port"
        ".pyre"
        ".mypy_cache"
        ".envrc"
        ".direnv/"
        ".wt"
        ".claude/settings.local.json"
      ];
    };
  };
}
