{ pkgs
, ...
}: {
  # storage inspection and data movement
  # (host side disk health lives in the system modules, not here)
  home.packages = with pkgs; [
    dust # du replacement, tree view of what is eating space
    duf # df replacement, mounted filesystems at a glance
    rsync # sync between local disks and over ssh
  ];
}
