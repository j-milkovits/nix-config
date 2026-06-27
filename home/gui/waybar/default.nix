{ pkgs
, config
, ...
}: {
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        layer = "top";   
        position = "top";
        mod = "dock";
        exclusive = true;
        fixed-center = true;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = ["clock" "keyboard-state"];
        modules-right = ["network" "cpu" "memory" "battery" "bluetooth" "pulseaudio" "pulseaudio#microphone" "tray"];
        "hyprland/window" = {
          format = "{}";
        };

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = ""; 
            "2" = ""; 
            "3" = ""; 
            "4" = "";
            "5" = ""; 
            "6" = "󰄭"; 
            "7" = "󰭹";
            "8" = "";
            "9" = ""; 
            "10" = "󰍹";
          };
          all-outputs = false;
          sort-by-number = true;
        };

        clock = {
          format = "  {:%H:%M }";
          format-alt ="  {:%y/%m/%d }";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };

        keyboard-state = {
          capslock = true;
          numlock = true;
          scrolllock = true;
          format = "{name} {icon}";
          format-icons = {
            locked = " ";
            unlocked = " ";
          };
        };

        network = {
          interval = 5;
          # interface = "wlp2*"; // (Optional) To force the use of this interface
          format-wifi = "   {bandwidthUpBytes:3.1f}  {bandwidthDownBytes:3.1f}";
          format-ethernet = "   {bandwidthUpBytes:3}  {bandwidthDownBytes:3}";
          tooltip-format-wifi = "  {essid} ({signalStrength}%)";
          tooltip-format-ethernet = "  {ifname}";
          tooltip-format-disconnected = "Disconnected";
          format-disconnected = "  Disconnected";
          on-click-middle = "kitty nmtui";
        };

        cpu  = {
          interval = 1;
          format = "  {usage:2}%";
          on-click-middle = "kitty btop";
        };

        memory = {
          interval = 1;
          format = "  {percentage:2}%";
          tooltip = true;
          tooltip-format = "{used:0.1f}GiB out of {total:0.1f}GiB";
          on-click-middle = "kitty btop";
        };

        # TODO = configure this on laptop
        battery = {
          states = {
            good = 95;
            warning = 30;
            critical = 20;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-alt = "{time} {icon}";
          format-icons = ["" "" "" "" "" "" "" "" "" "" ""];
        };

        # TODO = configure this on laptop
        bluetooth = {
          format = " {status}";
          format-disabled = ""; # an empty format will hide the module
          format-no-controller = "";
          format-connected = " {num_connections}";
          tooltip-format = "{device_alias}";
          tooltip-format-connected = " {device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          tooltip = true;
          format-muted = " Muted";
          scroll-step = 5;
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [" " " " " "]; # whitespace here is on purpose
          };
          on-click = "pamixer -t";
          on-click-middle = "exec pavucontrol";
          on-scroll-up = "pamixer -i 5 --allow-boost";
          on-scroll-down = "pamixer -d 5 --allow-boost";
        };

        "pulseaudio#microphone" = {
          format = "{format_source}";
          format-source = " {volume}%";
          format-source-muted = " Muted";
          on-click = "pamixer --default-source -t";
          on-click-middle = "exec pavucontrol";
          on-scroll-up = "pamixer --default-source -i 5";
          on-scroll-down = "pamixer --default-source -d 5";
          scroll-step = 5;
        };

        tray = {
          icon-size = 18;
          spacing = 11;
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0px;
        font-family: "FiraCode Nerd Font";
        font-weight: 500;
        font-size: 18px;
        min-height: 20px;
        opacity: 1.0;
      }

      window#waybar {
        background: none;
      }

      tooltip {
        background: #1e1e2e;
        border-radius: 7px;
        border-width: 2px;
        border-style: solid;
        border-color: #b4befe;
        opacity: 1.0;
      }

      #workspaces button {
        color: #313244;
        padding: 5px 7px;
        margin: 0px 0px;
      }

      #workspaces button.active {
        color: #b4befe;
      }

      #workspaces button.urgent {
        background: #191926;
        color: #f38ba8;
      }

      #window,
      #clock,
      #battery,
      #pulseaudio,
      #custom-pacman,
      #network,
      #bluetooth,
      #temperature,
      #workspaces,
      #tray,
      #cpu,
      #memory,
      #keyboard-state,
      #modbackground {
        background: #191926;
        opacity: 1.0;
        padding: 0px 10px;
        margin-top: 10px;
        /* margin-bottom: 0px; */
        /* border: 1px solid #b5b0a7; */
      }

      #workspaces {
        border-radius: 7px;
        margin-left: 10px;
        margin-right: 0px;
        padding-right: 7px;
        padding-left: 5px;
        opacity: 1.0;
      }

      #clock {
        color: #f5e0dc;
        border-radius: 7px;
        padding-right: 0px;
        opacity: 1.0;
      }

      #network {
        color: #89b4fa;
        border-radius: 7px 0px 0px 7px;
      }

      #cpu {
        color: #94e2d5;
      }

      #memory {
        color: #f9e2af;
      }

      #battery {
        color: #f2cdcd;
      }

      #bluetooth {
        color: #cba6f7;
      }

      #pulseaudio {
        color: #fab387;
      }

      #pulseaudio.microphone {
        color: #eba0ac;
      }

      #tray {
        border-radius: 0px 7px 7px 0px;
        margin-right: 10px;
      }
    '';
  };
}
