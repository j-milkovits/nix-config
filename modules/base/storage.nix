{ pkgs
, ...
}: {
  # drive management, installed system wide because all of these need root
  environment.systemPackages = with pkgs; [
    ddrescue # image a dying drive, install it before you need it
    fio # benchmark, tells you whether the disk or the bus is the bottleneck
    hdparm # spindown and standby timers
    lsof # find what is holding a mount when unmount fails
    nvme-cli # the m.2 boot drive does not answer smartctl the same way
    parted # partitioning, what the nixos manual uses
    smartmontools # smartctl, on demand self tests and attributes
  ];
}
