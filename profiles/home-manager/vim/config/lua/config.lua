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
require'bufferline'.setup()

-- Treesitter highlight (grammars installed via nix)
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

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
require'completion'
