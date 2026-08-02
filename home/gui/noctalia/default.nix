{ config
, noctalia
, ...
}:
let
  wallpaperDir = "${config.home.homeDirectory}/Pictures/Wallpapers";

  # the bar's colour ramp, catppuccin mocha accents spaced across the palette
  # order and read left to right, cool at the centre warming towards the edge
  group = id: foreground: members: {
    inherit id members;
    fill = "surface_variant";
    padding = 10.0;
    radius = 10.0;
    opacity = 1.0;
    enabled = true;
  } // (if foreground == null then { } else { inherit foreground; });

  # one sysmon instance per stat, which is how waybar's separate cpu, memory and network modules are rebuilt
  stat = s: { type = "sysmon"; stat = s; };
in
{
  imports = [ noctalia.homeModules.default ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;

    settings = {
      audio.enable_overdrive = true;

      theme = {
        source = "builtin";
        builtin = "Catppuccin";
        mode = "dark";
        community_palette = "Oxocarbon";
        wallpaper_scheme = "m3-content";
      };

      shell = {
        avatar_path = "${./avatar.jpg}";

        polkit_agent = true;

        launcher = {
          categories = false;
          compact = true;
          fetch_exchange_rates = false;
        };

        session.show_shortcuts = false;
      };

      wallpaper.default.path = "${wallpaperDir}/wallpaper.png";

      location.address = "Darmstadt, Germany";
      nightlight.enabled = true;
      notification.history_retention_hours = 8;

      lockscreen = {
        blurred_desktop = true;
        blur_intensity = 0.75;
        fingerprint = false;
      };

      idle = {
        behavior_order = [ "lock" "screen-off" ];
        behavior.lock = { action = "lock"; enabled = true; timeout = 900.0; };
        behavior."screen-off" = { action = "screen_off"; enabled = true; timeout = 1200.0; };
      };

      control_center = {
        calendar.show_week_numbers = true;
        shortcuts = map (t: { type = t; }) [
          "wifi"
          "bluetooth"
          "audio"
          "mic_mute"
          "power_profile"
          "caffeine"
        ];
      };

      bar.default = {
        capsule = true;
        capsule_radius = 10;
        capsule_thickness = 0.8;
        thickness = 40;
        radius = 10;
        padding = 10;
        margin_edge = 10;
        margin_ends = 10;
        widget_spacing = 10;

        start = [ "group:gs1" ];
        center = [ "group:gc1" "group:gc2" "group:gc3" ];
        end = [ "group:g5" "group:g1" "group:g2" "group:g3" "group:g4" "tray" ];

        # workspaces carries its own per-state colours, so it gets no foreground
        capsule_group = [
          (group "gs1" null [ "workspaces" ])
          (group "gc1" "#b4befe" [ "active_window" ]) # lavender
          (group "gc2" "#74c7ec" [ "clock" ]) # sapphire
          (group "gc3" "#94e2d5" [ "media" ]) # teal
          (group "g5" "#a6e3a1" [ "keyboard_layout" "lock_keys" ]) # green
          # accordion: only the first member shows, hovering the capsule reveals the rest
          (group "g1" "#fab387" [ "net_down" "net_up" "network" ] // { accordion = true; }) # peach
          (group "g2" "#f38ba8" [ "cpu" "ram" "sysmon" ] // { accordion = true; }) # red
          (group "g3" "#f5c2e7" [ "volume" "mic" ]) # pink
          (group "g4" "#f5e0dc" [ "brightness" "battery" ]) # rosewater
        ];
      };

      widget = {
        cpu = stat "cpu_usage";
        ram = stat "ram_pct";
        net_up = stat "net_tx" // { network_speed_compact = true; };
        net_down = stat "net_rx" // { network_speed_compact = true; };
        sysmon = { stat = "gpu_usage"; glyph = "matrix"; };

        mic = { type = "volume"; device = "input"; };
        clock.anchor = true;
        tray.drawer = true;
        keyboard_layout.display = "full";

        lock_keys = {
          type = "lock_keys";
          show_caps_lock = true;
          show_scroll_lock = true;
          hide_when_off = true;
        };

        active_window = { min_length = 0; title_scroll = "on_hover"; };
        media = {
          min_length = 0;
          max_length = 260;
          hide_when_no_media = true;
          title_scroll = "on_hover";
        };

        # label_source reads hyprland's workspace name
        workspaces = {
          style = "minimal";
          label_source = "name";
          show_labels = true;
          max_label_chars = 2;
          focused_output_only = true;
          hide_when_empty = false;
          change_color_on_hover = false;
          focused_color = "#cba6f7";
          occupied_color = "#89b4fa";
          empty_color = "#6c7086";
          urgent_color = "#f38ba8";
          actions = { scroll_up = "none"; scroll_down = "none"; };
        };
      };
    };
  };

  home.file."Pictures/Wallpapers/wallpaper.png".source = ./wallpaper.png;
}
