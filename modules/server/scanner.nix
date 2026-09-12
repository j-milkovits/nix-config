{ ...
}:
let
  # the same path containers.nix binds into papra, root-owned as sshd insists for a chroot
  ingestion = "/mnt/data/media/papra/ingestion";
  # papra ignores files at the ingestion root, the organisation folder is where it looks
  inbox = "${ingestion}/org_pboi2v3jhv1nfl20rfqd5lgz";
in
{
  users.groups.scanner = { };
  users.users.scanner = {
    isSystemUser = true;
    group = "scanner";
    # generated on the brother ads-1800w, only the public half enters the repo
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDa1+BR4MUZNY71L5n1HifsWEiSRjN0e44heXX2pVcMJjwWg4z1/rTkt6KBaqHgw7sXHueXK1lpWAm491X397GbJK3lyPyVVOm8kX3gRAVK3HGTxKkryznWDOhl3tGz9IUuJ+/+T6Ab9G+LxOLXylctOuFEosc12w263sKa8Ps2l2+vidA5zcXrN3/H7ivE/SxaYBa5HpjYjhzWFrfpw0d/CoLyM9tMZnmTO1uRXbbXqE10YU3zSq4r41mSWNr+eqYrArdEws3Pgt/xq3xEjCBBh06xAGTJn1/Ld2TIo1XVK6AtTg+EvEr/ibqcuuhCpNQzIP0A0TB/+sJUPRgSFubH root@BRW5CF370DD1446"
    ];
  };

  # sftp only, chrooted, no shell, no forwarding - the scanner sees the organisation folder and nothing else
  services.openssh.extraConfig = ''
    Match User scanner
      ChrootDirectory ${ingestion}
      ForceCommand internal-sftp -u 0002
      AllowTcpForwarding no
      X11Forwarding no
      PermitTTY no
  '';

  # a oneshot rather than tmpfiles: tmpfiles has no mount guard and would build the tree on the root fs
  # with the bridge absent - papra's own ExecStartPre creates the parent
  systemd.services.scan-inbox = {
    wantedBy = [ "multi-user.target" ];
    after = [ "podman-papra.service" ];
    unitConfig.RequiresMountsFor = [ ingestion ];
    serviceConfig.Type = "oneshot";
    # papra runs as root in its container, so it reads and deletes the scanner's files regardless of owner
    script = "install -d -m 0775 -o scanner -g scanner ${inbox}";
  };
}
