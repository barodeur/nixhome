{ ... }:

{
  programs = {
    git = {
      enable = true;

      aliases = {
        st = "status";
        amend = "commit --amend";
        co = "checkout";
        l = "log --graph --date=short";
        c = "commit -m";
      };

      extraConfig = {
        core = {
          editor = "nvim";
        };

        color = {
          ui = true;
        };


        init = {
          defaultBranch = "main";
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
      ];
    };
  };
}
