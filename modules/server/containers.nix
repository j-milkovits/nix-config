{ config
, pkgs
, domain
, ...
}:
let
  # sqlite state is stored on non-usb storages
  # only write-once bulk belongs on /mnt/data
  stateDir = name: "/var/lib/${name}";

  # containers inherit no /etc/localtime, so the host timezone has to be handed in
  # logs and anything scheduled (meal plans, budget rollovers) run on utc otherwise
  commonEnv = { TZ = config.time.timeZone; };

  # podman refuses to start on a missing bind source instead of creating it like docker does
  # ExecStartPre is a list in oci-containers, and unit options merge by concatenation, so this appends
  ensureState = names: builtins.listToAttrs (map
    (name: {
      name = "podman-${name}";
      value.serviceConfig.ExecStartPre = [ "${pkgs.coreutils}/bin/mkdir -p ${stateDir name}" ];
    })
    names);
in
{
  # containers become systemd units, so they roll back with the generation
  virtualisation = {
    podman = {
      enable = true;
      # podman compatible with docker commands
      dockerCompat = true;
      # images pile up on every tag bump
      autoPrune.enable = true;
    };

    oci-containers = {
      backend = "podman";

      # personal finance
      containers.actual = {
        image = "ghcr.io/actualbudget/actual:sha-3b2f89e@sha256:2d95396914c62212230d3cc7dd9f7bd9eba2da46696e5e4d4a6dfac4bdbaa5a1";
        # localhost only, caddy terminates tls in front of it (modules/server/proxy.nix)
        ports = [ "127.0.0.1:5006:5006" ];
        volumes = [ "${stateDir "actual"}:/data" ];
        environment = commonEnv;
      };

      # recipes
      containers.mealie = {
        image = "ghcr.io/mealie-recipes/mealie:v3.21.0@sha256:4e1e8d98b883009cb849851857e277109c21db1c2d857ae61e14de894f2169ff";
        ports = [ "127.0.0.1:9000:9000" ];
        volumes = [ "${stateDir "mealie"}:/app/data" ];
        environment = commonEnv // {
          # mealie builds absolute links (shares, oidc redirects) from this, the proxied name is the only correct one
          BASE_URL = "https://mealie.home.${domain}";
          ALLOW_SIGNUP = "false";
        };
      };

      # twitch drop farming, a fork of the upstream gui app that ships a web ui instead
      containers.twitch-drops-miner = {
        image = "docker.io/rangermix/twitch-drops-miner:1.2.6@sha256:4575f3c87bcd7bffb68d410638b0db4d2f6abd4982fb9cec6b429c3ee4cef3fb";
        ports = [ "127.0.0.1:8080:8080" ];
        volumes = [ "${stateDir "twitch-drops-miner"}:/app/data" ];
        environment = commonEnv;
      };
    };
  };

  # /var/lib uses the root fs
  systemd.services = ensureState [ "actual" "mealie" "twitch-drops-miner" ];
}
