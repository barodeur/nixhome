require 'options'

-- Colours come from the theme profile on hosts that have one: it writes a
-- generated nvim.lua (background, the 16 terminal colours, and the colorscheme
-- its palette maps to) into the same state directory waybar and hyprland read.
-- See profiles/home-manager/theme. Everywhere else gruvbox stays the default.
local state = vim.env.XDG_STATE_HOME or (vim.env.HOME .. '/.local/state')
local theme = state .. '/theme/nvim.lua'
local uv = vim.uv or vim.loop
if uv.fs_stat(theme) then
  dofile(theme)
else
  vim.cmd('colorscheme gruvbox')
end
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
