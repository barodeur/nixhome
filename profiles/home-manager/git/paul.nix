{ ... }:

{
  programs = {
    git = {
      userEmail = "paul@chobert.fr";
      userName = "Paul Chobert";

      signing = {
        key = "ABE00992A263A790";
        signByDefault = true;
      };
    };
  };
}
