{ config
, ...
}: {
  hardware.graphics.enable = true; # enable OpenGL

  services.xserver.videoDrivers = [ "nvidia" ]; # load nvidia driver for Xorg and Wayland

  hardware.nvidia = {
    modesetting.enable = true; # necessary
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    powerManagement.enable = false;
    powerManagement.finegrained = false;

    open = true; # set this if GPU newer than Turing
    nvidiaSettings = true; # enables `nvidia-settings`
  };
}
