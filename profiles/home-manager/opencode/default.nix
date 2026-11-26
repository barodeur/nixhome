{ pkgs, ... }:

let
  port = 8080;
  contextSize = 131072;

  bonsai-serve = pkgs.writeShellScriptBin "bonsai-serve" ''
    exec ${pkgs.llama-cpp}/bin/llama-server \
      --hf-repo prism-ml/Ternary-Bonsai-2.5-27B-GGUF \
      --hf-file Ternary-Bonsai-2.5-27B-Q2_0.gguf \
      --alias bonsai-2.5-27b \
      --host 127.0.0.1 --port ${toString port} \
      -ngl 99 -fa on -c ${toString contextSize} -np 1 \
      --jinja --reasoning-format deepseek --reasoning-budget 16384 \
      --temp 1.0 --top-p 0.95 --top-k 20 --min-p 0 \
      "$@"
  '';
in
{
  home.packages = [ pkgs.llama-cpp bonsai-serve ];

  programs.opencode = {
    enable = true;
    settings = {
      model = "llama-cpp/bonsai-2.5-27b";
      provider.llama-cpp = {
        npm = "@ai-sdk/openai-compatible";
        name = "llama.cpp (local)";
        options = {
          baseURL = "http://127.0.0.1:${toString port}/v1";
          timeout = false;
        };
        models."bonsai-2.5-27b" = {
          name = "Ternary Bonsai 2.5 27B";
          tool_call = true;
          reasoning = true;
          limit = {
            context = contextSize;
            output = 32768;
          };
        };
      };
    };
  };
}
