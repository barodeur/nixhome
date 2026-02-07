{ ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 38;
        margin-top = 6;
        margin-left = 8;
        margin-right = 8;
        spacing = 0;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "backlight" "network" "bluetooth" "cpu" "memory" "battery" "tray" ];

        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
          sort-by-number = true;
        };

        clock = {
          format = "  {:%H:%M}";
          format-alt = "  {:%A, %B %d}";
          tooltip-format = "<tt>{calendar}</tt>";
        };

        cpu = {
          format = "  {usage}%";
          interval = 2;
        };

        memory = {
          format = "  {percentage}%";
          tooltip-format = "{used:0.1f}G / {total:0.1f}G used";
          interval = 2;
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon}  {capacity}%";
          format-charging = "  {capacity}%";
          format-plugged = "  {capacity}%";
          format-icons = [ "" "" "" "" "" ];
        };

        backlight = {
          format = "{icon}  {percent}%";
          format-icons = [ "" "" "" "" "" "" "" "" "" ];
          scroll-step = 5;
          on-scroll-up = "brightnessctl set +5%";
          on-scroll-down = "brightnessctl set 5%-";
        };

        bluetooth = {
          format = "";
          format-off = "󰂲";
          format-disabled = "󰂲";
          format-connected = "󰂱";
          tooltip-format = "Devices connected: {num_connections}";
          on-click = "rfkill unblock bluetooth; ghostty -e bluetui";
        };

        network = {
          format-wifi = "  {signalStrength}%";
          format-ethernet = "  {ipaddr}/{cidr}";
          format-disconnected = "  Off";
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
          on-click = "ghostty -e nmtui";
        };

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "  Muted";
          format-icons = {
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
        };

        tray = {
          spacing = 10;
        };
      };
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 13px;
        min-height: 0;
        padding: 0;
        margin: 0;
      }

      window#waybar {
        background: rgba(15, 15, 25, 0.85);
        border-radius: 12px;
        border: 1px solid rgba(51, 204, 255, 0.12);
        color: #c8d0e0;
      }

      tooltip {
        background: rgba(15, 15, 25, 0.95);
        border: 1px solid rgba(51, 204, 255, 0.25);
        border-radius: 8px;
      }

      tooltip label {
        color: #c8d0e0;
      }

      /* ── Workspaces ── */
      #workspaces {
        margin: 3px 6px;
      }

      #workspaces button {
        padding: 2px 10px;
        margin: 3px 2px;
        border-radius: 8px;
        color: rgba(200, 208, 224, 0.35);
        background: transparent;
        border: 1px solid transparent;
        transition: all 0.25s ease;
        min-width: 20px;
      }

      #workspaces button:hover {
        background: rgba(51, 204, 255, 0.1);
        color: #33ccff;
      }

      #workspaces button.active {
        background: linear-gradient(135deg, rgba(51, 204, 255, 0.25), rgba(0, 255, 153, 0.18));
        color: #ffffff;
        border: 1px solid rgba(51, 204, 255, 0.35);
      }

      #workspaces button.urgent {
        background: rgba(255, 100, 120, 0.25);
        color: #ff6478;
      }

      /* ── Clock ── */
      #clock {
        font-weight: 600;
        font-size: 14px;
        color: #e0e6f0;
        padding: 4px 14px;
        margin: 3px 2px;
      }

      /* ── Common module styling ── */
      #cpu,
      #memory,
      #battery,
      #network,
      #bluetooth,
      #backlight,
      #pulseaudio,
      #tray {
        padding: 4px 12px;
        margin: 3px 2px;
        border-radius: 8px;
        background: rgba(255, 255, 255, 0.04);
        transition: all 0.25s ease;
      }

      #cpu:hover,
      #memory:hover,
      #battery:hover,
      #network:hover,
      #bluetooth:hover,
      #backlight:hover,
      #pulseaudio:hover {
        background: rgba(51, 204, 255, 0.08);
      }

      /* ── Module colors ── */
      #cpu { color: #7aafff; }
      #memory { color: #c4a1f0; }
      #pulseaudio { color: #8edba6; }
      #backlight { color: #e0c880; }

      #pulseaudio.muted {
        color: rgba(200, 208, 224, 0.3);
      }

      #network { color: #33ccff; }
      #network.disconnected { color: rgba(200, 208, 224, 0.3); }

      #bluetooth { color: #7aafff; }
      #bluetooth.disabled { color: rgba(200, 208, 224, 0.3); }
      #bluetooth.off { color: rgba(200, 208, 224, 0.3); }
      #bluetooth.connected { color: #33ccff; }

      #battery { color: #8edba6; }
      #battery.warning { color: #f0b070; }
      #battery.critical { color: #ff6478; }
      #battery.charging { color: #8edba6; }

      #tray {
        padding: 4px 8px;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
      }
    '';
  };
}
