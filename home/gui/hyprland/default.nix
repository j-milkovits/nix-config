{ pkgs
, config
, ...
}: {
  # wallpaper, binary file
  # xdg.configFile."hypr/hyprland.conf".source = ./hyprland.conf;
  xdg.configFile."hypr/hyprpaper.conf".source = ./hyprpaper.conf;
  xdg.configFile."hypr/wallpaper.png".source = ./wallpaper.png;

  # uwsm
  xdg.configFile."uwsm/env".source = ./env;
  # for HYPR and AQ variables
  # xdg.configFile."uwsm/env-hyprland".source = ./env-hyprland;

  wayland.windowManager.hyprland = {
    enable = true;  

    # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    package = null;
    portalPackage = null;
    systemd.enable = false; # for usage of uwsm

    configType = "hyprlang"; # writes to hyprland.conf instead of hyprland.lua
  };

  wayland.windowManager.hyprland.settings = {
    # variables
    "$terminal" = "kitty"; 
    "$fileManager" = "dolphin";

    # monitors
    monitor = ",preferred,auto,auto";

    # windowrulev2 = [
    #   "suppressevent maximize, class:.*" # You'll probably like this.
    #   "bordersize 4, fullscreen:1"
    # ];

    # start up
    exec-once = [
      "hyprpaper"
    ];

    # modifier
    "$mod" = "SUPER";

    bind = [
      # launch applications
      "$mod, Return, exec, $terminal"
      "$mod, Q, killactive,"
      "$mod, M, exec, uwsm stop" # uwsm specific - like exit
      "$mod, E, exec, $fileManager"
      "$mod_Shift, F, togglefloating," 
      "$mod, R, exec, rofi -show drun"
      "$mod_Shift, C, exec, hyprpicker | wl-copy"

      # move focus
      "$mod, Left, movefocus, l"
      "$mod, Right, movefocus, r"
      "$mod, Up, movefocus, u"
      "$mod, Down, movefocus, d"

      # move active window
      "$mod_Shift, Left, movewindow, l"
      "$mod_Shift, Right, movewindow, r"
      "$mod_Shift, Up, movewindow, u"
      "$mod_Shift, Down, movewindow, d"

      # switch workplaces
      # workspace = "10, monitor:DP-3, default:true"
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"
      "$mod, 0, workspace, 10"

      # move active window to workspace
      "$mod SHIFT, 1, movetoworkspace, 1"
      "$mod SHIFT, 2, movetoworkspace, 2"
      "$mod SHIFT, 3, movetoworkspace, 3"
      "$mod SHIFT, 4, movetoworkspace, 4"
      "$mod SHIFT, 5, movetoworkspace, 5"
      "$mod SHIFT, 6, movetoworkspace, 6"
      "$mod SHIFT, 7, movetoworkspace, 7"
      "$mod SHIFT, 8, movetoworkspace, 8"
      "$mod SHIFT, 9, movetoworkspace, 9"
      "$mod SHIFT, 0, movetoworkspace, 10"

      # scratchpad
      # "$mod, S, togglespecialworkspace, scratchpad"
      # "$mod, SHIFT, S, movetoworkspace, special:scratchpad"
    ];

    # mouse binds
    bindm = [
      # move and resize
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    # general
    general = {
      border_size = 2;
      gaps_in = 5;
      gaps_out = 10;
      "col.active_border" = "rgb(b4befe)";
      "col.inactive_border" = "rgba(1e1e2eaa)";

      # master switch for tearing in games
      layout = "dwindle"; 

      allow_tearing = false;
    };

    # decoration
    decoration = {
      rounding = 5;
      inactive_opacity = 1;

      blur = {
        enabled = true;
        size = 3;
        passes = 1;
      };
    };

    # animations
    animations = {
      enabled = true;

      bezier = [
        "linear, 0, 0, 1, 1"
        "easeIn, 0.42, 0, 1, 1"
        "easeOut, 0, 0, 0.58, 1"
        "easeInOut, 0.42, 0, 0.58, 1"
      ];

      animation = [
        "windows, 1, 1, easeInOut"
        "border, 1, 1, easeInOut"
        "borderangle, 0"
        "fade, 1, 3, linear"
        "workspaces, 1, 2, easeOut, fade"
      ];
    };

    # input
    input = {
      kb_layout = "us";
      # kb_variant =;
      # kb_model =;
      # kb_options =;
      # kb_rules =;

      follow_mouse = 2;

      touchpad = {
        natural_scroll = false;
      };

      sensitivity = 0;
    };

    misc = {
      force_default_wallpaper = true;

      # hyprland
      disable_hyprland_logo = true;
      disable_splash_rendering = true;

      font_family = "FiraCode Nerd Font";
    };

    binds = {
      workspace_back_and_forth = true;
      workspace_center_on = 1;
    };

    ecosystem = {
      no_donation_nag = true;
    };

    dwindle = {
      preserve_split = true;
      force_split = 2;
    };

  };
}
