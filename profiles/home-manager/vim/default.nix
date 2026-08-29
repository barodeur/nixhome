{ pkgs, lib, config, ... }:

let
  nvimHome = "${config.xdg.configHome}/nvim";

  # The colorschemes the theme profile can switch to. Taken from the same
  # mapping it generates nvim.lua against (profiles/home-manager/theme), so a
  # theme can never name a colorscheme that is not installed. Harmless on the
  # darwin hosts, which have no theme profile and stay on gruvbox.
  colorschemes = map (name: pkgs.vimPlugins.${name})
    (lib.unique (lib.mapAttrsToList (_: v: v.plugin) (import ../theme/neovim.nix)));
in
{
  programs = {
    neovim = {
      enable = true;

      viAlias = true;
      vimAlias = true;

      # Explicit to silence the warning about the default flipping in 26.05.
      withRuby = true;
      withPython3 = true;

      extraPackages = with pkgs; [
        actionlint
        bat
        fd
        # fenix.rust-analyzer
        eslint_d
        prettier
        typescript
        typescript-language-server
        yaml-language-server
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
        lspkind-nvim
        lualine-nvim
        nvim-cmp
        nvim-dap
        nvim-lspconfig
        nvim-tree-lua
        nvim-web-devicons
        outline-nvim
        telescope-dap-nvim
        telescope-symbols-nvim
        trouble-nvim
        undotree
        vim-easy-align
        vim-fugitive
        vim-jsonnet
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
      ] ++ colorschemes;
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
