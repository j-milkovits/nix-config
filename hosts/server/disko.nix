{ ...
}: {
  # data disk only - the m.2 root was partitioned by hand during the install
  disko.devices.disk.data = {
    type = "disk";
    # the ironwolf sits in a usb enclosure, so sd* names reorder between boots
    # this name follows the drive, not the enclosure it happens to be in
    device = "/dev/disk/by-id/ata-ST4000VN006-3CW104_WW6A996V";

    content = {
      type = "gpt";
      partitions.data = {
        size = "100%";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/mnt/data";
          # a usb bridge that fails to enumerate must not hold up the boot
          mountOptions = [ "nofail" ];
        };
      };
    };
  };
}
