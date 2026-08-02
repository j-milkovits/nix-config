{ lib
, pkgs
, ...
}:
let
  inherit (lib.generators) mkLuaInline;

  mod = "SUPER";
  terminal = "kitty";
  fileManager = "dolphin";

  # hl.bind(keys, dispatcher) and hl.bind(keys, dispatcher, flags)
  bind = keys: dispatcher: { _args = [ keys (mkLuaInline dispatcher) ]; };
  bindWith = keys: dispatcher: flags: { _args = [ keys (mkLuaInline dispatcher) flags ]; };

  # every noctalia bind is an ipc call into the running shell
  msg = command: "hl.dsp.exec_cmd(\"noctalia msg ${command}\")";

  # media keys keep working over the lock screen, the ramping ones repeat when held
  locked = { locked = true; };
  ramping = { locked = true; repeating = true; };

  # focus moves the view, window.move moves the window, both take a direction
  directions = [
    { key = "left"; dir = "left"; }
    { key = "right"; dir = "right"; }
    { key = "up"; dir = "up"; }
    { key = "down"; dir = "down"; }
  ];
  focusBinds = map (d: bind "${mod} + ${d.key}" "hl.dsp.focus({ direction = \"${d.dir}\" })") directions;
  moveBinds = map (d: bind "${mod} + SHIFT + ${d.key}" "hl.dsp.window.move({ direction = \"${d.dir}\" })") directions;

  workspaceIcons = [ "" "" "" "" "" "󰄭" "󰭹" "" "" "󰍹" ];
  workspaceRules = lib.imap1 (i: icon: { workspace = toString i; default_name = icon; }) workspaceIcons;

  # workspace 10 sits on key 0
  workspaceBinds = lib.concatMap
    (i:
      let key = toString (lib.mod i 10); in [
        (bind "${mod} + ${key}" "hl.dsp.focus({ workspace = ${toString i} })")
        (bind "${mod} + SHIFT + ${key}" "hl.dsp.window.move({ workspace = ${toString i} })")
      ])
    (lib.range 1 10);
in
{
  home.packages = [ pkgs.hyprpicker ];

  wayland.systemd.target = "hyprland-session.target";

  wayland.windowManager.hyprland = {
    enable = true;

    # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    package = null;
    portalPackage = null;

    # owns hyprland-session.target, and imports the env into systemd and dbus
    systemd.enable = true;

    configType = "lua"; # hyprlang is deprecated since 0.55
  };

  # every attribute below becomes an `hl.<name>(...)` call, lists become one call each
  wayland.windowManager.hyprland.settings = {
    # monitors, one call per output
    monitor = {
      output = "";
      mode = "preferred";
      position = "auto";
      scale = "auto";
    };

    # session environment, one call per variable
    env = [
      { _args = [ "XCURSOR_SIZE" "24" ]; }
      { _args = [ "HYPRCURSOR_SIZE" "24" ]; }
    ];

    # the settings sections, everything hl.config understands
    config = {
      general = {
        border_size = 2;
        gaps_in = 5;
        gaps_out = 10;

        col = {
          active_border = mkLuaInline "colors.accent";
          inactive_border = mkLuaInline "'rgba(' .. colors.baseAlpha .. 'aa)'";
        };

        # master switch for tearing in games
        layout = "dwindle";

        allow_tearing = false;
      };

      decoration = {
        rounding = 10;
        inactive_opacity = 1;

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
      };

      # master switch only, the curves and leaves are separate calls below
      animations.enabled = true;

      input = {
        kb_layout = "us";

        follow_mouse = 2;

        touchpad = {
          natural_scroll = false;
        };

        sensitivity = 0;
      };

      misc = {
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

    # bezier curves
    curve = [
      { _args = [ "linear" { type = "bezier"; points = [ [ 0 0 ] [ 1 1 ] ]; } ]; }
      { _args = [ "easeIn" { type = "bezier"; points = [ [ 0.42 0 ] [ 1 1 ] ]; } ]; }
      { _args = [ "easeOut" { type = "bezier"; points = [ [ 0 0 ] [ 0.58 1 ] ]; } ]; }
      { _args = [ "easeInOut" { type = "bezier"; points = [ [ 0.42 0 ] [ 0.58 1 ] ]; } ]; }
    ];

    # one call per animated leaf
    animation = [
      { leaf = "windows"; enabled = true; speed = 1; bezier = "easeInOut"; }
      { leaf = "border"; enabled = true; speed = 1; bezier = "easeInOut"; }
      { leaf = "borderangle"; enabled = false; }
      { leaf = "fade"; enabled = true; speed = 3; bezier = "linear"; }
      { leaf = "workspaces"; enabled = true; speed = 2; bezier = "easeOut"; style = "fade"; }
    ];

    workspace_rule = workspaceRules;

    # the settings panel is a normal toplevel, so dwindle would tile it
    window_rule = {
      name = "noctalia-settings";
      match = { class = "dev.noctalia.Noctalia"; };
      float = true;
      size = [ 1080 920 ];
    };

    # noctalia animates its own surfaces, hyprland's layer animations fight it
    layer_rule = {
      name = "noctalia";
      match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$";
      };
      no_anim = true;
      ignore_alpha = 0.5;
      blur = true;
      blur_popups = true;
    };

    bind = [
      # launch applications
      (bind "${mod} + Return" "hl.dsp.exec_cmd(\"${terminal}\")")
      (bind "${mod} + Q" "hl.dsp.window.close()")
      (bind "${mod} + E" "hl.dsp.exec_cmd(\"${fileManager}\")")
      (bind "${mod} + SHIFT + F" "hl.dsp.window.float({ action = \"toggle\" })")
      (bind "${mod} + SHIFT + C" "hl.dsp.exec_cmd(\"hyprpicker | wl-copy\")")
    ]
    ++ [
      # noctalia panels
      (bind "${mod} + R" (msg "panel-toggle launcher"))
      (bind "${mod} + H" (msg "panel-toggle control-center"))
      (bind "${mod} + C" (msg "panel-toggle clipboard"))
      (bind "${mod} + M" (msg "panel-toggle session"))
      (bind "${mod} + comma" (msg "settings-toggle"))
    ]
    ++ [
      # media keys, routed through noctalia so its OSD fires with them
      (bindWith "XF86AudioRaiseVolume" (msg "volume-up") ramping)
      (bindWith "XF86AudioLowerVolume" (msg "volume-down") ramping)
      (bindWith "XF86MonBrightnessUp" (msg "brightness-up") ramping)
      (bindWith "XF86MonBrightnessDown" (msg "brightness-down") ramping)
      (bindWith "XF86AudioMute" (msg "volume-mute") locked)
      (bindWith "XF86AudioMicMute" (msg "mic-mute") locked)
      (bindWith "XF86AudioNext" (msg "media next") locked)
      (bindWith "XF86AudioPrev" (msg "media previous") locked)
      (bindWith "XF86AudioPlay" (msg "media toggle") locked)
      (bindWith "XF86AudioPause" (msg "media toggle") locked)
    ]
    ++ focusBinds # move focus
    ++ moveBinds # move active window
    ++ workspaceBinds # switch workspaces, and move the active window to one
    ++ [
      # move and resize with the mouse
      (bindWith "${mod} + mouse:272" "hl.dsp.window.drag()" { mouse = true; })
      (bindWith "${mod} + mouse:273" "hl.dsp.window.resize()" { mouse = true; })
    ];
  };
}
