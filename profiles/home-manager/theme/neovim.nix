# Omarchy theme -> neovim colorscheme, for the themes whose colorscheme is
# packaged in nixpkgs.
#
# `plugin` names an attribute of pkgs.vimPlugins (profiles/home-manager/vim
# installs the whole list); `scheme` is what :colorscheme takes. The pairs come
# from omarchy's themes/<name>/neovim.lua, except miasma, which omarchy leaves
# to its terminal palette but nixpkgs happens to package.
#
# The other twelve themes have no packaged colorscheme (matteblack, ashen,
# lumon, retro-82, hackerman and friends are not in nixpkgs). They fall back to
# gruvbox with the theme's own background, which is honest and always loads.
{
  catppuccin = { plugin = "catppuccin-nvim"; scheme = "catppuccin-mocha"; };
  catppuccin-latte = { plugin = "catppuccin-nvim"; scheme = "catppuccin-latte"; };
  everforest = {
    plugin = "everforest";
    scheme = "everforest";
    # omarchy asks for the soft variant; sainnhe's colorscheme reads this
    # global at load time, so it has to be set before :colorscheme.
    pre = ''vim.g.everforest_background = "soft"'';
  };
  gruvbox = { plugin = "gruvbox-nvim"; scheme = "gruvbox"; };
  kanagawa = { plugin = "kanagawa-nvim"; scheme = "kanagawa"; };
  miasma = { plugin = "miasma-nvim"; scheme = "miasma"; };
  nord = { plugin = "nightfox-nvim"; scheme = "nordfox"; };
  osaka-jade = { plugin = "bamboo-nvim"; scheme = "bamboo"; };
  rose-pine = { plugin = "rose-pine"; scheme = "rose-pine-dawn"; };
  tokyo-night = { plugin = "tokyonight-nvim"; scheme = "tokyonight-night"; };
}
