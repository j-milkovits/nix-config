{ noctalia
, ...
}: {
  imports = [ noctalia.homeModules.default ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;

    # settings stay unset on purpose, noctalia owns config.toml while it is tuned
  };

  # noctalia has its own polkit agent, but it is off until the config is frozen
  services.hyprpolkitagent.enable = true;

  # noctalia's default wallpaper directory, so nothing has to be declared to find it
  home.file."Pictures/Wallpapers/wallpaper.png".source = ./wallpaper.png;
}
