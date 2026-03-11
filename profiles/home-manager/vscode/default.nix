{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;

    mutableExtensionsDir = true;

    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      mkhl.direnv
      enkia.tokyo-night
      editorconfig.editorconfig
      vscodevim.vim
      shopify.ruby-lsp
    ] ++ [
      (pkgs.vscode-utils.extensionFromVscodeMarketplace {
        name = "relay";
        publisher = "meta";
        version = "2.5.1";
        sha256 = "0z7sqzz78ga6majzpf5xhyw6c6881lb4d5cb7gilkyzf86ghnicn";
      })
    ];

    profiles.default.userSettings = {
      "editor.fontFamily" = "'JetBrains Mono', 'monospace'";
      "editor.fontSize" = 14;
      "editor.fontLigatures" = false;
      "editor.minimap.enabled" = false;
      "editor.formatOnSave" = true;
      "editor.renderWhitespace" = "trailing";
      "editor.tabSize" = 2;
      "editor.wordWrap" = "off";

      "workbench.colorTheme" = "Tokyo Night Storm";
      "workbench.startupEditor" = "none";

      "terminal.integrated.fontFamily" = "'JetBrains Mono'";

      "files.trimTrailingWhitespace" = true;
      "files.insertFinalNewline" = true;
      "files.trimFinalNewlines" = true;

      "vim.useSystemClipboard" = true;
      "editor.lineNumbers" = "relative";
    };
  };
}
