{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;

    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      mkhl.direnv
      enkia.tokyo-night
      editorconfig.editorconfig
    ];

    profiles.default.userSettings = {
      "editor.fontFamily" = "'JetBrains Mono', 'monospace'";
      "editor.fontSize" = 14;
      "editor.fontLigatures" = true;
      "editor.minimap.enabled" = false;
      "editor.formatOnSave" = true;
      "editor.renderWhitespace" = "trailing";
      "editor.tabSize" = 2;
      "editor.wordWrap" = "off";

      "workbench.colorTheme" = "Tokyo Night";
      "workbench.startupEditor" = "none";

      "terminal.integrated.fontFamily" = "'JetBrains Mono'";

      "files.trimTrailingWhitespace" = true;
      "files.insertFinalNewline" = true;
      "files.trimFinalNewlines" = true;
    };
  };
}
