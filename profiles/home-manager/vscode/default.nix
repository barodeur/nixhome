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

      # VS Code tries to persist trusted schema domains on startup. Since
      # settings.json is a read-only Nix store symlink, that write fails and
      # VS Code reopens settings.json as an unsaved buffer every launch.
      # Declaring the value here keeps the on-disk file in sync.
      "json.schemaDownload.trustedDomains" = {
        "https://schemastore.azurewebsites.net/" = true;
        "https://raw.githubusercontent.com/microsoft/vscode/" = true;
        "https://raw.githubusercontent.com/devcontainers/spec/" = true;
        "https://www.schemastore.org/" = true;
        "https://json.schemastore.org/" = true;
        "https://json-schema.org/" = true;
        "https://developer.microsoft.com/json-schemas/" = true;
        "https://biomejs.dev" = true;
      };
    };
  };
}
