{ pkgs
, ...
}: {
  home.packages = with pkgs; [
    todoist-electron # unfree, official desktop client
  ];
}
