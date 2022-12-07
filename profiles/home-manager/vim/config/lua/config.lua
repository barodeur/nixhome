require 'options'

vim.cmd('colorscheme gruvbox')
vim.keymap.set('n', '<Leader>b', ':NvimTreeToggle<CR>', { remap = true })
vim.keymap.set('n', '<Leader>ff', '<Cmd>Telescope find_files<CR>')
vim.keymap.set('n', '<Leader>fg', '<Cmd>Telescope live_grep<CR>')
vim.keymap.set('n', '<Leader>fb', '<Cmd>Telescope buffers<CR>')
vim.keymap.set('n', '<Leader>fh', '<Cmd>Telescope help_tags<CR>')

require'crates'.setup()
require'trouble'.setup()
require'gitsigns'.setup()
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  indent = {
    enable = false,
  },
}
require'nvim-tree'.setup {
  diagnostics = {
    enable = true,
  },
  update_focused_file = {
    enable = true,
  },
}

require'lualine-config'
require'lsp'
require'telescope-config'
