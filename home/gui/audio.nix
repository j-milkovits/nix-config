{ pkgs
, ...
}: {
  home.packages = with pkgs; [
    pavucontrol  # gui volume control
  ];
}
