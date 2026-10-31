{ username
, ...
}: {
  virtualisation.docker = {
    enable = true;
    # the daemon starts on the first docker command, not at boot
    enableOnBoot = false;
  };
  # the docker group is root in all but name, the same trust as wheel
  users.users.${username}.extraGroups = [ "docker" ];
}
