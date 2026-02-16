{ ... }:

{
  programs.mise = {
    enable = true;
    globalConfig = {
      tools = {
        python = "3.14";
        uv = "latest";
        ruby = "4.0";
        node = "24.13";
        bun = "1.3";
        go = "1.25";
      };
      settings = {
        all_compile = false;
        ruby = { compile = false; };
      };
    };
  };
}
