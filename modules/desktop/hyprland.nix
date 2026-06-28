{ pkgs
, ...
}: {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  environment.systemPackages = with pkgs; [
    hyprpaper
    rofi
    wl-clipboard
  ];

  # hint electron apps to use wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
