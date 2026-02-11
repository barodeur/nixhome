{ ... }:

{
  programs = {
    git = {
      signing = {
        key = "ABE00992A263A790";
        signByDefault = true;
      };

      settings = {
        user = {
          email = "paul@chobert.fr";
          name = "Paul Chobert";
        };

        pull = {
          rebase = true;
        };
      };
    };
  };
}
