{ pkgs, config, ... }:

let nvimHome = "${config.xdg.configHome}/nvim";
in
{
  programs = {
    neovim = {
      enable = true;

      viAlias = true;
      vimAlias = true;

      extraPackages = with pkgs; [
        actionlint
        bat
        fd
        # fenix.rust-analyzer
        nodePackages.eslint_d
        nodePackages.prettier
        nodePackages.typescript
        nodePackages.typescript-language-server
        nodePackages.yaml-language-server
        ripgrep
        # rnix-lsp
        shellcheck
        statix
        tree-sitter
      ];

      extraConfig = ''
        lua require 'config'
      '';

      plugins = with pkgs.vimPlugins; [
        bufferline-nvim
        cmp-buffer
        cmp-calc
        cmp-cmdline
        cmp-nvim-lsp
        cmp-path
        cmp-vsnip
        crates-nvim
        dressing-nvim
        editorconfig-vim
        fidget-nvim
        friendly-snippets
        gitsigns-nvim
        goyo-vim
        gruvbox-nvim
        lsp-status-nvim
        lspkind-nvim
        lualine-nvim
        null-ls-nvim
        nvim-cmp
        nvim-dap
        nvim-lspconfig
        nvim-tree-lua
        nvim-web-devicons
        # rust-tools-nvim
        symbols-outline-nvim
        telescope-dap-nvim
        telescope-symbols-nvim
        trouble-nvim
        undotree
        vim-easy-align
        vim-fugitive
        vim-jsonnet
        vim-polyglot
        vim-rhubarb
        vim-surround
        vim-vsnip
        vim-vsnip-integ
        (nvim-treesitter.withPlugins (grammars: [
          grammars.tree-sitter-bash
          grammars.tree-sitter-c
          grammars.tree-sitter-comment
          grammars.tree-sitter-cpp
          grammars.tree-sitter-css
          grammars.tree-sitter-dart
          grammars.tree-sitter-dot
          grammars.tree-sitter-go
          grammars.tree-sitter-html
          grammars.tree-sitter-java
          grammars.tree-sitter-javascript
          grammars.tree-sitter-jsdoc
          grammars.tree-sitter-json
          grammars.tree-sitter-latex
          grammars.tree-sitter-lua
          grammars.tree-sitter-make
          grammars.tree-sitter-markdown
          grammars.tree-sitter-ocaml
          grammars.tree-sitter-php
          grammars.tree-sitter-python
          grammars.tree-sitter-regex
          grammars.tree-sitter-rst
          grammars.tree-sitter-ruby
          grammars.tree-sitter-rust
          grammars.tree-sitter-svelte
          grammars.tree-sitter-toml
          grammars.tree-sitter-tsx
          grammars.tree-sitter-typescript
          grammars.tree-sitter-yaml
        ]))
      ];
    };
  };

  home.file = builtins.listToAttrs (map
    (file: {
      name = "${nvimHome}/${file}";
      value = {
        source = ./config + "/${file}";
        recursive = true;
      };
    })
    (builtins.attrNames (builtins.readDir ./config)));
}
