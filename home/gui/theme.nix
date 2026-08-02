{ config
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
}
