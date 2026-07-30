{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wl-clipboard
    cliphist
  ];

  # The hyprland backend arrives with wayland.windowManager.hyprland below, but
  # it only implements Screenshot, ScreenCast and GlobalShortcuts. gtk covers
  # the rest — OpenURI, FileChooser, Settings, Notification — and it has to be
  # declared *here*: nixpkgs patches xdg-desktop-portal to read backends from
  # the single directory named by NIX_XDG_DESKTOP_PORTAL_DIR, which
  # home-manager points at the user profile. A gtk portal installed at the
  # system level never gets looked at, and the interfaces it should provide
  # just do not exist on the bus (flatpaks then fail to open links in silence).
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Replaces the XCURSOR_*/HYPRCURSOR_* env vars that were set only for
  # Hyprland: this propagates the theme to GTK apps and flatpaks too (the
  # theme gets linked into ~/.icons, which flatpak exposes to sandboxes).
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
    hyprcursor.enable = true;
  };

  gtk = {
    enable = true;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  # The settings portal serves these to flatpaks; without them flatpak apps
  # render light and fall back to the Adwaita cursor.
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    cursor-theme = "Bibata-Modern-Classic";
    cursor-size = 24;
  };

  # Clipboard history: wl-paste watchers store every copy (text and images)
  # into cliphist's db; $mod SHIFT V opens the picker.
  services.cliphist = {
    enable = true;
    allowImages = true;
  };

  # grim exits with an error and no screenshot if the target directory is
  # missing, and nothing else creates it.
  systemd.user.tmpfiles.rules = [
    "d %h/Pictures/Screenshots - - - -"
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    # Explicit: the default moves to "lua"; this config is hyprlang-shaped.
    configType = "hyprlang";
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "ghostty";
      "$menu" = "wofi --show drun";

      monitor = ",preferred,auto,1.6";

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
      };

      env = [
        "XDG_DATA_DIRS,$HOME/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"
        # Since GTK 4.20, GTK on Wayland no longer composes dead keys itself
        # unless an input method is present; without this, dead keys are dropped
        # in ghostty and other GTK apps (https://github.com/ghostty-org/ghostty/discussions/8899).
        "GTK_IM_MODULE,simple"
      ];

      input = {
        kb_layout = "us";
        # Mac US layout: macOS-style dead keys on right Alt (e.g. Alt+e then a
        # letter for the acute accent), instead of altgr-intl's own scheme.
        kb_variant = "mac";
        kb_options = "caps:escape";
        follow_mouse = 1;
        sensitivity = 0;
        # macOS-style scrolling: the content follows the fingers/wheel. macOS
        # applies it to mice as well as trackpads, so both are set here.
        natural_scroll = true;

        touchpad = {
          natural_scroll = true;
        };
      };

      cursor = {
        hide_on_key_press = true;
      };

      # Never upscale XWayland apps (Steam, 1Password, Wine games): at the 1.6
      # fractional scale they'd render at 1x and get stretched blurry. With
      # this they render sharp but small; DPI-aware ones can scale themselves.
      xwayland = {
        force_zero_scaling = true;
      };

      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, D, exec, $menu"
        "$mod, Q, killactive"
        "$mod SHIFT, M, exec, printf '󰌾  Lock\\n󰒲  Sleep\\n󰋊  Hibernate\\n󰗼  Logout\\n󰜉  Restart\\n󰐥  Shutdown\\n' | wofi --dmenu --insensitive --prompt 'System' | bash -c 'read choice; case \"$choice\" in *Lock*) hyprlock;; *Sleep*) systemctl suspend;; *Hibernate*) systemctl hibernate;; *Logout*) hyprctl dispatch exit;; *Restart*) systemctl reboot;; *Shutdown*) systemctl poweroff;; esac'"
        "$mod, V, togglefloating"
        "$mod, F, fullscreen"

        # Move focus
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # Resize mode
        "$mod, R, submap, resize"

        # Move windows
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, l, movewindow, r"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, j, movewindow, d"
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"

        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        # Lock screen
        "$mod CTRL, L, exec, hyprlock"

        # Screenshots: saved to disk and copied to the clipboard
        "$mod, Print, exec, grim - | tee ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png | wl-copy"
        '', Print, exec, grim -g "$(slurp)" - | tee ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png | wl-copy''

        # Clipboard history
        "$mod SHIFT, V, exec, cliphist list | wofi --dmenu --prompt 'Clipboard' | cliphist decode | wl-copy"

        # Move to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
      ];

      # Volume and brightness, through swayosd so an overlay shows the change
      bindel = [
        ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
        ", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
        ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
        ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
        ", XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
        ", XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      windowrule = [
        "float true, center true, size 800 600, match:class ^(1password)$"
      ];
    };
    extraConfig = ''
      submap = resize
      binde = , h, resizeactive, -20 0
      binde = , l, resizeactive, 20 0
      binde = , k, resizeactive, 0 -20
      binde = , j, resizeactive, 0 20
      binde = , left, resizeactive, -20 0
      binde = , right, resizeactive, 20 0
      binde = , up, resizeactive, 0 -20
      binde = , down, resizeactive, 0 20
      bind = , escape, submap, reset
      submap = reset
    '';
  };

  # Nothing was providing a polkit authentication agent: that was gnome-shell's
  # job, and gnome-shell never runs on this host.
  services.hyprpolkitagent.enable = true;

  # OSD overlay for the volume/brightness keys bound above.
  services.swayosd.enable = true;

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 600;
          # Sleeps normally, then hibernates after HibernateDelaySec (system
          # config), so an idle night or weekend costs no battery.
          on-timeout = "systemctl suspend-then-hibernate";
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        grace = 0;
      };
      background = [{
        monitor = "";
        path = "screenshot";
        blur_passes = 3;
        blur_size = 8;
      }];
      input-field = [{
        monitor = "";
        size = "200, 50";
        outline_thickness = 3;
        outer_color = "rgba(33ccffee)";
        inner_color = "rgba(0, 0, 0, 0.5)";
        font_color = "rgb(200, 200, 200)";
        fade_on_empty = true;
        placeholder_text = "Password...";
      }];
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      preload = [ "/home/paul/Pictures/wallpaper.jpg" ];
      # hyprpaper 0.8 dropped the "monitor,path" one-liner; the old form parses
      # without error but never binds, leaving the default background.
      wallpaper = {
        monitor = "";
        path = "/home/paul/Pictures/wallpaper.jpg";
      };
    };
  };

  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      border-radius = 10;
      border-size = 2;
      border-color = "#33ccffee";
      background-color = "#1a1b26ee";
      text-color = "#c0caf5";
      "app-name=\"Claude Code\"" = {
        default-timeout = 0;
      };
    };
  };

  programs.wofi = {
    enable = true;
    settings = {
      width = 600;
      height = 340;
      insensitive = true;
      allow_images = true;
      image_size = 24;
      # Expanding the "> app with actions" groups has no default keybinding.
      key_expand = "Right";
    };
    # Same palette as waybar/mako: dark translucent background, cyan accents.
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 13px;
      }

      window {
        background-color: rgba(15, 15, 25, 0.92);
        border: 1px solid rgba(51, 204, 255, 0.25);
        border-radius: 12px;
        color: #c8d0e0;
      }

      #input {
        margin: 8px;
        padding: 6px 10px;
        border: 1px solid rgba(51, 204, 255, 0.25);
        border-radius: 8px;
        background-color: rgba(255, 255, 255, 0.04);
        color: #e0e6f0;
      }

      #input:focus {
        border-color: rgba(51, 204, 255, 0.5);
      }

      #inner-box {
        margin: 0 8px 8px;
      }

      #entry {
        padding: 6px 10px;
        border-radius: 8px;
      }

      #img {
        margin-right: 8px;
      }

      #entry:selected {
        background: linear-gradient(135deg, rgba(51, 204, 255, 0.25), rgba(0, 255, 153, 0.18));
        color: #ffffff;
      }

      #entry:selected #text {
        color: #ffffff;
      }
    '';
  };
}
