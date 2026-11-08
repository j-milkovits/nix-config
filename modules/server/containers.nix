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
  # uid and gid of the papra host user, 900 sits below everything the allocator hands out on the server
  papraId = 900;

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
  # the identity papra's process and files carry on the host, the other images drop root on their own
  users.groups.papra.gid = papraId;
  users.users.papra = {
    isSystemUser = true;
    uid = papraId;
    group = "papra";
  };

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
        image = "ghcr.io/actualbudget/actual:26.11.0@sha256:06cf186569cf58d93e12659ff1a517b65b5b0ebee7050a3991d4bd8a1d398da6";
        # localhost only, caddy terminates tls in front of it (modules/server/proxy.nix)
        ports = [ "127.0.0.1:5006:5006" ];
        volumes = [ "${stateDir "actual"}:/data" ];
        environment = commonEnv;
      };

      # recipes
      containers.mealie = {
        image = "ghcr.io/mealie-recipes/mealie:v3.30.0@sha256:90f83da6f3ab0a421efc827118a556168573930105f13fa3321768f42163d784";
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
        image = "ghcr.io/papra-hq/papra:26.7.1-rootless@sha256:d1f596a35332ad04d8a69d88a5e19bc82acd47f2bc2fe687dd2145b1ef5a8b19";
        # the host user below, so the process is not root on the host and its files are owned by a name
        user = "${toString papraId}:${toString papraId}";
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
          # bytes, 50 MiB
          DOCUMENT_STORAGE_MAX_UPLOAD_SIZE = toString (50 * 1024 * 1024);
        };
      };
    };
  };

  # /var/lib uses the root fs
  systemd.services = lib.mkMerge [
    (ensureState [ "actual" "mealie" "papra" ])
    {
      # /mnt/data is nofail, so without this papra can start with the bridge absent
      # and write documents into the bare mountpoint
      podman-papra = {
        unitConfig.RequiresMountsFor = [ papraDocuments papraIngestion ];
        serviceConfig.ExecStartPre = [
          # papra creates neither, and documents/ is the target of the nested bind - owned by papra, it writes there
          "${pkgs.coreutils}/bin/install -d -o papra -g papra ${stateDir "papra"} ${stateDir "papra"}/db ${stateDir "papra"}/documents ${papraDocuments}"
          # the ingestion root stays root-owned, sshd insists on that for the scanner's chroot (scanner.nix)
          "${pkgs.coreutils}/bin/mkdir -p ${papraIngestion}"
        ];
      };
    }
  ];
}
