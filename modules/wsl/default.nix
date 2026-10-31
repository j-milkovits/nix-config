{ pkgs

, username
, ...
}: {
  wsl = {
    enable = true;
    defaultUser = username;
    # no windows directories on the path
    wslConf.interop.appendWindowsPath = false;
  };

  # docker inside nixos
  virtualisation.docker.enable = true;
  users.users.${username}.extraGroups = [ "docker" ];

  # wslg gives a wayland display, so the usual clipboard tools reach the windows clipboard both ways
  environment.systemPackages = [ pkgs.wl-clipboard ];
}
