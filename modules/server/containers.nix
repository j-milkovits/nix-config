{ config
, lib
, pkgs
, domain
, ...
}:
let
  # sqlite state is stored on non-usb storages
  # only write-once bulk belongs on /mnt/data
  stateDir = name: "/var/lib/${name}";

  # papra keeps its documents as files next to the database, so both halves of the split apply
  papraDocuments = "/mnt/data/media/papra/documents";
  papraIngestion = "/mnt/data/media/papra/ingestion";

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
  # signs the session cookies, rotating it logs every account out
  sops.secrets."papra-auth-secret" = { };

  # oci-containers passes environment values through the unit file, which lands in the nix store
  # a rendered env file keeps the secret on the /run/secrets tmpfs instead
  sops.templates."papra.env" = {
    content = "AUTH_SECRET=${config.sops.placeholder."papra-auth-secret"}";
    restartUnits = [ "podman-papra.service" ];
  };

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

      # documents
      containers.papra = {
        # the -root variant, its -rootless twin runs as a system uid the bind mounts are not owned by
        image = "ghcr.io/papra-hq/papra:26.6.2-root@sha256:4fffbfd03824b95cf34b98f38cd7e15fa49b82fa0c7c3496031df2cef94e9e1b";
        ports = [ "127.0.0.1:1221:1221" ];
        # app-data holds the database and the config dir, documents nest inside it
        # podman orders binds by target depth, so the inner one lands on top of the outer
        volumes = [
          "${stateDir "papra"}:/app/app-data"
          "${papraDocuments}:/app/app-data/documents"
          "${papraIngestion}:/app/ingestion"
        ];
        environmentFiles = [ config.sops.templates."papra.env".path ];
        environment = commonEnv // {
          # sets the client and server urls at once, and the proxied name becomes a trusted origin
          APP_BASE_URL = "https://papra.home.${domain}";
          DOCUMENTS_OCR_LANGUAGES = "deu,eng";
          # the one account exists and is the admin, nobody else gets to sign up
          AUTH_IS_REGISTRATION_ENABLED = "false";
          # consumes whatever is dropped in ingestion/<org id>/, the level above it is ignored
          INGESTION_FOLDER_IS_ENABLED = "true";
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
  systemd.services = lib.mkMerge [
    (ensureState [ "actual" "mealie" "papra" "twitch-drops-miner" ])
    {
      # /mnt/data is nofail, so without this papra can start with the bridge absent
      # and write documents into the bare mountpoint
      podman-papra = {
        unitConfig.RequiresMountsFor = [ papraDocuments papraIngestion ];
        # papra creates neither, and documents/ is the target of the nested bind
        serviceConfig.ExecStartPre = [
          "${pkgs.coreutils}/bin/mkdir -p ${stateDir "papra"}/db ${stateDir "papra"}/documents ${papraDocuments} ${papraIngestion}"
        ];
      };
    }
  ];
}
