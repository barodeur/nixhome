{ lib, pkgs, omarchy }:

# The wallpaper half of a theme.
#
# Omarchy ships backgrounds beside each theme's colors.toml, so the desktop
# picture switches with the palette rather than being a path someone typed once.
# This mirrors their ~/.local/state/omarchy/current/background symlink with the
# ${stateDir}/background.jpg one the rest of this profile already uses.

let
  themeDir = "${omarchy}/themes";

  # The panel this is rendered for. Backgrounds are cover-cropped to it at
  # build time: shipping 4K originals for a 2256x1504 screen would quadruple
  # the closure for pixels that get scaled away on load.
  width = 2256;
  height = 1504;

  # Omarchy numbers its background files in the order its authors intended, so
  # the lowest-sorting name is their default for that theme. The exceptions
  # below are where a different one suits the palette better.
  preferred = {
    # Four of tokyo-night's eight carry the Omarchy mark — 5-oma-cityscape
    # paints it across the sky — which is branding rather than aesthetics and
    # has no business on a NixOS desktop. Of the four that do not, this is the
    # calmest: measured over the lower 60% of the frame, where windows actually
    # sit, it is the least saturated of the set (53% against 63% for
    # 0-winding-road) and its foreground is the deep indigo nearest the theme's
    # own #1a1b26 ground. The pink sky it is named for stays up behind the bar.
    tokyo-night = "3-sunset-lake.webp";
  };

  available = theme:
    let d = "${themeDir}/${theme}/backgrounds";
    in if builtins.pathExists d then lib.naturalSort (lib.attrNames (builtins.readDir d)) else [ ];

  chosen = theme:
    let
      files = available theme;
      want = preferred.${theme} or null;
    in
    lib.throwIf (files == [ ]) "theme ${theme} ships no backgrounds"
      (if want != null && lib.elem want files then want else builtins.head files);
in
{
  inherit preferred available chosen;

  # One image per theme, converted to a single format and scaled to the panel.
  #
  # Copied rather than referenced: `${omarchy}` is 78 MB — 92 backgrounds plus
  # the whole distribution — and naming a file inside it from a config would
  # put all of that in every system closure. Built this way, omarchy is a
  # build-time input only and the runtime closure holds 22 JPEGs.
  #
  # The uniform .jpg is not cosmetic either: hyprpaper's config names one fixed
  # path, so every theme has to land on the same extension. It also sidesteps
  # the question of whether hyprpaper sniffs format by content or by name.
  images = themes: pkgs.runCommand "omarchy-backgrounds"
    { nativeBuildInputs = [ pkgs.imagemagick ]; }
    (lib.concatMapStringsSep "\n"
      (theme: ''
        mkdir -p "$out/${theme}"
        magick ${themeDir}/${theme}/backgrounds/${lib.escapeShellArg (chosen theme)} \
          -resize ${toString width}x${toString height}^ \
          -gravity center -extent ${toString width}x${toString height} \
          -quality 90 "$out/${theme}/background.jpg"
      '')
      themes);
}
