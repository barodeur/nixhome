{ lib, omarchy }:

# Palette data and colour maths for the theme profile.
#
# Omarchy ships every theme as a `themes/<name>/colors.toml` of 24 semantic
# keys — accent/selection/muted, a background ramp, a foreground ramp, and the
# eight ANSI hues with their bright variants. That file is pure data: no code,
# no Arch paths, nothing that assumes the rest of Omarchy. Pinning their repo
# as a flake input and reading it with `fromTOML` is the whole of the port.
# Everything below turns those 24 keys into the role names this config's
# stylesheets already speak (@accent, $activeBorder, and the rest), which is
# why nothing downstream of here had to change.
#
# Alpha is composited here rather than by the consumers. GTK CSS has alpha()
# and mix(); hyprlang, mako and ghostty have none, and each wants a different
# encoding of the same colour — rgba(r, g, b, 0.85), rgba(rrggbbaa), #rrggbbaa,
# #rrggbb. Doing the arithmetic once in Nix keeps the four formats agreeing.

let
  # ── Hex maths ──────────────────────────────────────────────────────────────
  #
  # Nix has no number parsing, so hex goes through a digit table. Everything is
  # integer arithmetic: alpha is carried as a percentage 0-100 rather than a
  # float because `toString 0.85` yields "0.850000", and that lands verbatim in
  # a stylesheet.

  digits = "0123456789abcdef";

  digitValue = lib.listToAttrs
    (lib.imap0 (i: c: lib.nameValuePair c i) (lib.stringToCharacters digits));

  parseHex = s: lib.foldl' (acc: c: acc * 16 + digitValue.${c}) 0
    (lib.stringToCharacters (lib.toLower s));

  # Themes are not consistent about case (flexoki-light is uppercase), so both
  # ends of the round trip normalise.
  toHex2 = n:
    let v = if n < 0 then 0 else if n > 255 then 255 else n;
    in builtins.substring (v / 16) 1 digits + builtins.substring (lib.mod v 16) 1 digits;

  parse = hex:
    let h = lib.toLower (lib.removePrefix "#" hex); in {
      r = parseHex (builtins.substring 0 2 h);
      g = parseHex (builtins.substring 2 2 h);
      b = parseHex (builtins.substring 4 2 h);
    };

  fmt = c: "#" + toHex2 c.r + toHex2 c.g + toHex2 c.b;

  # 100 -> "1", 85 -> "0.85", 4 -> "0.04".
  cssAlpha = p:
    if p >= 100 then "1"
    else if p <= 0 then "0"
    else if p < 10 then "0.0${toString p}"
    else "0.${toString p}";

  # Rounded rather than truncated: at 92% the difference is #eb vs #ea, which
  # is invisible, but truncation makes 100% land on #fe.
  hexAlpha = p: toHex2 ((p * 255 + 50) / 100);

  # Omarchy's `mix` helper: `pct` is how much of `b` ends up in the result.
  mix = a: b: pct:
    let
      x = parse a;
      y = parse b;
      m = u: v: (u * (100 - pct) + v * pct) / 100;
    in
    fmt { r = m x.r y.r; g = m x.g y.g; b = m x.b y.b; };

  # ── Output encodings ───────────────────────────────────────────────────────

  css = hex: a:
    let c = parse hex; in
    if a >= 100 then lib.toLower hex
    else "rgba(${toString c.r}, ${toString c.g}, ${toString c.b}, ${cssAlpha a})";

  # mako wants #rrggbbaa.
  rgba8 = hex: a: lib.toLower hex + hexAlpha a;

  # hyprlang wants the alpha inside the parens, no '#'.
  hypr = hex: a: "rgba(${lib.removePrefix "#" (lib.toLower hex)}${hexAlpha a})";

  # ── Theme loading ──────────────────────────────────────────────────────────

  themeDir = "${omarchy}/themes";

  names = lib.attrNames
    (lib.filterAttrs (_: t: t == "directory") (builtins.readDir themeDir));

  # Every theme defines the same 24 keys, except `orange` and `brown`, which
  # three of them omit. Derive rather than let a template hit a missing
  # attribute: an orange between red and yellow is what the key means anyway.
  load = name:
    let
      raw = builtins.fromTOML (builtins.readFile "${themeDir}/${name}/colors.toml");
    in
    raw // {
      orange = raw.orange or (mix raw.red raw.yellow 50);
      brown = raw.brown or (mix raw.red raw.yellow 30);
    };

  # ── Roles ──────────────────────────────────────────────────────────────────

  # The neutral ramp runs background -> lighter_background -> selection ->
  # muted -> dark_foreground -> foreground -> light_foreground ->
  # bright_foreground, measured as distance from the background. It reads
  # darkest-to-lightest in a dark theme and lightest-to-darkest in a light one,
  # so a role picked by position on that ramp works in both directions and
  # nothing here needs to branch on `mode`.
  roles = p: {
    # Panels keep the translucency the hand-written palettes had; the alphas
    # are what carry the depth, so they are the one thing not taken from the
    # theme.
    "bg" = css p.background 85;
    "bg-elevated" = css p.background 95;
    "bg-popup" = css p.background 92;

    # A tint of the foreground rather than of white: in a dark theme that
    # lightens, in a light theme it darkens, which is what a raised surface
    # needs in each.
    "surface" = css p.foreground 5;
    "surface-hover" = css p.accent 10;

    "border" = css p.accent 15;
    "border-strong" = css p.accent 28;
    "border-focus" = css p.accent 55;

    "text" = css p.foreground 100;
    "text-strong" = css p.bright_foreground 100;
    "text-muted" = css p.dark_foreground 100;
    "text-dim" = css p.muted 100;

    "accent" = css p.accent 100;
    "accent-hover" = css p.accent 10;

    # The selection gradient was cyan-to-green when the palettes were written by
    # hand. There is no second accent in a colors.toml to reach for, and picking
    # a companion hue per theme would be guesswork, so the gradient now fades
    # within the accent instead of across two hues. It keeps the shape the
    # stylesheets were built around without inventing colour the theme does not
    # have.
    "sel-from" = css p.accent 30;
    "sel-to" = css p.accent 12;
    "sel-border" = css p.accent 40;
    # Far end of the ramp: light text in a dark theme, dark text in a light one.
    "sel-text" = css p.bright_foreground 100;

    "urgent-bg" = css p.red 22;

    "blue" = css p.blue 100;
    "purple" = css p.magenta 100;
    "green" = css p.green 100;
    "yellow" = css p.yellow 100;
    "orange" = css p.orange 100;
    "red" = css p.red 100;
  };

  # Hyprland gradients are a syntax of their own, and three themes ship the
  # border they want spelled out. Honour those verbatim and synthesise the rest
  # by lightening the accent towards the far end of the ramp — a sheen along
  # the border rather than a second hue.
  hyprRoles = p: {
    activeBorder = p.hyprland_active_border or
      "${hypr p.accent 93} ${hypr (mix p.accent p.bright_foreground 30) 93} 45deg";
    inactiveBorder = p.hyprland_inactive_border or (hypr p.muted 60);
    lockOuter = hypr p.accent 93;
    # hypr rather than css for these two: hyprlang parses a colour as 0x…,
    # rgb(…) or rgba(…) and nothing else, so a bare #rrggbb is not a colour to
    # it — it falls through to integer parsing, fails, and hyprlock silently
    # keeps the default for that field.
    lockInner = hypr p.background 55;
    lockFont = hypr p.foreground 100;
  };

  makoRoles = p: {
    border-color = rgba8 p.accent 93;
    background-color = rgba8 p.background 95;
    text-color = rgba8 p.foreground 100;
  };

  # Ported from omarchy's default/themed/ghostty.conf.tpl. selection_background
  # and selection_foreground are not palette keys; theming.md derives them from
  # `selection` and `bright_foreground`.
  ghostty = p: ''
    background = ${p.background}
    foreground = ${p.foreground}
    cursor-color = ${p.bright_foreground}
    selection-background = ${p.selection}
    selection-foreground = ${p.bright_foreground}

    palette = 0=${p.background}
    palette = 1=${p.red}
    palette = 2=${p.green}
    palette = 3=${p.yellow}
    palette = 4=${p.blue}
    palette = 5=${p.magenta}
    palette = 6=${p.cyan}
    palette = 7=${p.foreground}
    palette = 8=${p.muted}
    palette = 9=${p.bright_red}
    palette = 10=${p.bright_green}
    palette = 11=${p.bright_yellow}
    palette = 12=${p.bright_blue}
    palette = 13=${p.bright_magenta}
    palette = 14=${p.bright_cyan}
    palette = 15=${p.bright_foreground}
  '';

  # Ported from omarchy's default/themed/btop.theme.tpl.
  btop = p: ''
    theme[main_bg]="${p.background}"
    theme[main_fg]="${p.foreground}"
    theme[title]="${p.foreground}"
    theme[hi_fg]="${p.accent}"
    theme[selected_bg]="${p.selection}"
    theme[selected_fg]="${p.accent}"
    theme[inactive_fg]="${p.muted}"
    theme[graph_text]="${p.light_foreground}"
    theme[meter_bg]="${p.selection}"
    theme[proc_misc]="${p.light_foreground}"

    theme[cpu_box]="${p.magenta}"
    theme[mem_box]="${p.green}"
    theme[net_box]="${p.red}"
    theme[proc_box]="${p.accent}"
    theme[div_line]="${p.muted}"

    theme[temp_start]="${p.green}"
    theme[temp_mid]="${p.yellow}"
    theme[temp_end]="${p.red}"

    theme[cpu_start]="${p.cyan}"
    theme[cpu_mid]="${p.blue}"
    theme[cpu_end]="${p.magenta}"

    theme[free_start]="${p.magenta}"
    theme[free_mid]="${p.blue}"
    theme[free_end]="${p.cyan}"

    theme[cached_start]="${p.blue}"
    theme[cached_mid]="${p.cyan}"
    theme[cached_end]="${p.magenta}"

    theme[available_start]="${p.yellow}"
    theme[available_mid]="${p.red}"
    theme[available_end]="${p.red}"

    theme[used_start]="${p.green}"
    theme[used_mid]="${p.cyan}"
    theme[used_end]="${p.blue}"

    theme[download_start]="${p.yellow}"
    theme[download_mid]="${p.red}"
    theme[download_end]="${p.red}"

    theme[upload_start]="${p.green}"
    theme[upload_mid]="${p.cyan}"
    theme[upload_end]="${p.blue}"

    theme[process_start]="${p.cyan}"
    theme[process_mid]="${p.blue}"
    theme[process_end]="${p.magenta}"

    theme[gradient_color_0]="${p.background}"
    theme[gradient_color_1]="${p.lighter_background}"
    theme[gradient_color_2]="${p.selection}"
    theme[gradient_color_3]="${p.muted}"
    theme[gradient_color_4]="${p.dark_foreground}"
    theme[gradient_color_5]="${p.foreground}"
    theme[gradient_color_6]="${p.light_foreground}"
    theme[gradient_color_7]="${p.bright_foreground}"
  '';

  # Neovim is the one consumer that does not want generated colour. Omarchy's
  # own themes/<name>/neovim.lua only names an upstream plugin and a colorscheme
  # — those are hand-tuned against treesitter and LSP highlight groups, and a
  # palette-derived approximation would be worse than any of them. So the port
  # here is the mapping, not the colours; see ./neovim.nix. Themes whose
  # colorscheme is not packaged in nixpkgs fall back to gruvbox in the right
  # background, and still get the terminal palette below.
  neovim = import ./neovim.nix;

  nvimLua = name: p:
    let
      match = neovim.${name} or null;
      scheme = if match == null then "gruvbox" else match.scheme;
      pre = lib.optionalString (match != null && match ? pre) (match.pre + "\n");
      ansi = [
        p.background
        p.red
        p.green
        p.yellow
        p.blue
        p.magenta
        p.cyan
        p.foreground
        p.muted
        p.bright_red
        p.bright_green
        p.bright_yellow
        p.bright_blue
        p.bright_magenta
        p.bright_cyan
        p.bright_foreground
      ];
    in
    ''
      -- Generated from omarchy's ${name} palette; see profiles/home-manager/theme.
      vim.o.background = "${p.mode}"
      ${lib.concatStringsSep "\n" (lib.imap0
        (i: c: ''vim.g.terminal_color_${toString i} = "${c}"'') ansi)}
      ${pre}pcall(vim.cmd.colorscheme, "${scheme}")
    '';

in
rec {
  inherit names mix parse fmt css;

  palettes = lib.genAttrs names load;

  # What each theme contributes, ready to be written out. Keyed by theme name;
  # the profile turns this into one store directory per theme.
  files = lib.mapAttrs
    (name: p: {
      mode = p.mode;
      "palette.css" = lib.concatStringsSep "\n"
        (lib.mapAttrsToList (k: v: "@define-color ${k} ${v};") (roles p)) + "\n";
      "hypr.conf" = lib.concatStringsSep "\n"
        (lib.mapAttrsToList (k: v: "\$${k} = ${v}") (hyprRoles p)) + "\n";
      "mako.conf" = lib.concatStringsSep "\n"
        (lib.mapAttrsToList (k: v: "${k}=${v}") (makoRoles p)) + "\n";
      "ghostty.conf" = ghostty p;
      "btop.theme" = btop p;
      "nvim.lua" = nvimLua name p;
    })
    palettes;
}
