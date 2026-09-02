# format and mount, wipes the disk (run from the repo root):
#   nix run github:nix-community/disko -- --mode destroy,format,mount hosts/laptop/disko.nix
# mount only, for a reinstall onto the existing layout:
#   nix run github:nix-community/disko -- --mode mount hosts/laptop/disko.nix
{ ...
}: {
  disko.devices.disk.main = {
    type = "disk";
    # by-id, so a controller reorder cannot point the layout at the wrong disk
    # read it off the installer: ls -l /dev/disk/by-id/
    device = "/dev/disk/by-id/nvme-SAMSUNG_MZVLB256HBHQ-000L7_S4ELNF2N443085";

    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ]; # an esp is world readable otherwise
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
