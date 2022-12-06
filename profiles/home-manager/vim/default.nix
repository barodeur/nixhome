{ pkgs, ... }:

{
  programs = {
    neovim = {
      enable = true;
      vimAlias = true;

      extraPackages = with pkgs; [
        tree-sitter
        bat
        fd
        ripgrep
      ];

      plugins = with pkgs.vimPlugins; [
        undotree
        vim-fugitive
        vim-rhubarb
        vim-surround
        vim-easy-align
        editorconfig-vim
        nvim-lspconfig
        nvim-web-devicons
        nvim-tree-lua
        gitsigns-nvim
        telescope-symbols-nvim
        null-ls-nvim
        dressing-nvim
        fidget-nvim
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp-cmdline
        cmp-calc
        cmp-vsnip
        nvim-cmp
        lsp-status-nvim
        vim-vsnip
        vim-vsnip-integ
        friendly-snippets
        lspkind-nvim
        lualine-nvim
        trouble-nvim
        symbols-outline-nvim
        nvim-dap
        telescope-dap-nvim
        rust-tools-nvim
        crates-nvim
        vim-polyglot
        vim-jsonnet
        goyo-vim
      ];
    };
  };
}
