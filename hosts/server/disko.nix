# format and mount, wipes the ironwolf (run from the repo root):
#   nix run github:nix-community/disko -- --mode destroy,format,mount hosts/server/disko.nix
# mount only, for a reinstall onto the existing layout:
#   nix run github:nix-community/disko -- --mode mount hosts/server/disko.nix
# both leave the my book alone, disko only acts on what sits under disko.devices
{ ...
}: {
  # the two usb disks in one file, so "what is plugged into this box" has one answer
  # a disk sits under disko.devices only if this config formatted it and may format it again
  # every mount is addressed by an identity on the disk (uuid, partlabel, label), never a bus path

  # data disk only - the m.2 root was partitioned by hand during the install
  disko.devices.disk.data = {
    type = "disk";
    # by-id is the format target, at this point there is no filesystem to name yet
    # the ironwolf sits in a usb enclosure, so sd* names reorder between boots
    device = "/dev/disk/by-id/ata-ST4000VN006-3CW104_WW6A996V";

    content = {
      type = "gpt";
      partitions.data = {
        size = "100%";
        content = {
          type = "filesystem";
          format = "ext4";
          # mounted by the partlabel disko writes, not by the id above
          mountpoint = "/mnt/data";
          # a usb bridge that fails to enumerate must not hold up the boot
          mountOptions = [ "nofail" ];
        };
      };
    };
  };

  # the my book, formatted by hand on the desktop around the archive it already held
  # a plain entry, because under disko.devices this config would claim the right to wipe it
  # by label rather than partlabel, because a hand-run mkfs writes the one and disko the other
  fileSystems."/mnt/backup" = {
    device = "/dev/disk/by-label/backup";
    fsType = "ext4";
    # a usb bridge that fails to enumerate must not hold up the boot
    options = [ "nofail" ];
  };
}
