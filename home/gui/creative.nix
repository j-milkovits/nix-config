{ pkgs
, ...
}: {
  home.packages = with pkgs; [
    bambu-studio  # 3d printer slicer
    freecad       # CAD
  ];
}
