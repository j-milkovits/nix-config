{ pkgs
, ...
}: {
  home.packages = with pkgs; [
    pamixer      # cli volume control, used by hyprland keybinds
    pavucontrol  # gui volume control
  ];
}
