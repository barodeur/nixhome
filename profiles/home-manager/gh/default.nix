{ ... }:

{
  programs.gh = {
    enable = true;
    settings = {
      # Clone and push over SSH, authenticated by the YubiKey through
      # gpg-agent, rather than HTTPS with gh's token.
      git_protocol = "ssh";
    };
  };
}
