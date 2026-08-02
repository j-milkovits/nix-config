{ config
, ...
}: {
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  services.xserver.videoDrivers = [ "nvidia" ]; # load nvidia driver for Xorg and Wayland

  hardware.nvidia = {
    modesetting.enable = true; # necessary
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    powerManagement.enable = false;
    powerManagement.finegrained = false;

    open = true; # nvidia recommends the open modules from Turing on
    nvidiaSettings = true; # enables `nvidia-settings`
  };
}
