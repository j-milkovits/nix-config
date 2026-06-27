{ config
, pkgs
, ...
}: {
  imports = [
    ../../home/core.nix

    ../../home/base
    ../../home/gui
  ];

  # user specific program configuration
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "j-milkovits";
        email = "j.milkovits.t@posteo.net";
      };
    };
  };
}
