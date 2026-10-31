{ lib
, ...
}: {
  imports = [
    ../../home/profiles/gui.nix
  ];

  wayland.windowManager.hyprland.settings.config.decoration = {
    blur.enabled = lib.mkForce false;
    shadow.enabled = false;
  };
}
