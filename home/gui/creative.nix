{ pkgs
, ...
}: {
  home.packages = with pkgs; [
    orca-slicer   # 3d printer slicer
    freecad       # CAD
  ];
}
