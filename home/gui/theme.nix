{ config
, lib
, pkgs
, ...
}:
let
  inherit (config.catppuccin) flavor accent;

  gtkTheme = "catppuccin-${flavor}-${accent}-standard";
  gtkPackage = pkgs.catppuccin-gtk.override {
    accents = [ accent ];
    variant = flavor;
  };
in
{
  catppuccin.gtk.icon.enable = true;

  gtk = {
    enable = true;
    colorScheme = "dark";

    theme = {
      name = gtkTheme;
      package = gtkPackage;
    };

    gtk4.theme = {
      name = gtkTheme;
      package = gtkPackage;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  # one cursor and one size for hyprland, gtk apps and xwayland
  # from nixpkgs, which has it on the binary cache - the catppuccin module's own build runs locally on every update
  home.pointerCursor = {
    name = "catppuccin-${flavor}-${accent}-cursors";
    package = pkgs.catppuccin-cursors."${flavor}${lib.toSentenceCase accent}";
    size = 24;
    gtk.enable = true;
    hyprcursor.enable = true;
    x11.enable = true;
  };
}
