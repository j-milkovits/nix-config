{ pkgs
, domain
, ...
}:
let
  host = "dash.home.${domain}";

  # homepage ships no icons, a bare name resolves to jsdelivr in the browser
  # so they are fetched at build time, pinned to one commit, and caddy serves them (modules/server/proxy.nix)
  iconsRev = "ab52e3bfaa737cba86793c76ccfcb312f8841278";
  icon = file: hash: {
    name = baseNameOf file;
    path = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/homarr-labs/dashboard-icons/${iconsRev}/${file}";
      inherit hash;
    };
  };
  icons = pkgs.linkFarm "dashboard-icons" [
    (icon "svg/actual-budget.svg" "sha256-bsZiGo0LafYi/xDX+VeiKflZ2U1LyMXjWGrr5xySJAc=")
    (icon "svg/mealie.svg" "sha256-HBUeq4UEeg1x8ShgZhRBkSavXBDlrAkRLNwQM7Yagz8=")
    (icon "svg/papra.svg" "sha256-YRm+T9QTOcVxYen+T02xykVwRDJaIWaywWoQBQ3LYfE=")
    (icon "svg/twitch.svg" "sha256-qOs2UUfWBuxJjqbmVeHhOX7lwL28CWRk1Jbm8vMaHGk=")
    (icon "png/restic.png" "sha256-KbtcVMIIxeF7h80mtJjj7mZ62Ui/wDFw/o2A+liBo2w=")
    (icon "svg/backblaze.svg" "sha256-/9jOhQi2qPqmvluo5HDBvYeNmyf+e4sKDvP0etn/v0E=")
  ];

  # one link per service, the monitor checks the container directly instead of looping out through dns and caddy
  # actual, mealie and papra show down around 03:00, the local backup stops them for the run
  service = { name, port, icon, description }: {
    inherit description;
    href = "https://${name}.home.${domain}";
    icon = "/icons/${icon}";
    siteMonitor = "http://127.0.0.1:${toString port}";
  };

  # fetched by homepage's backend, not the browser - the status files sit behind caddy (modules/server/proxy.nix)
  # a job that never started writes nothing, so the age of "finished" is the real signal, not "result"
  backupStatus = { job, icon, description }: {
    inherit description;
    icon = "/icons/${icon}";
    widget = {
      type = "customapi";
      url = "https://${host}/status/${job}.json";
      mappings = [
        {
          field = "result";
          label = "result";
          # systemd's $SERVICE_RESULT, anything but success is a failed run
          remap = [
            { value = "success"; to = "ok"; }
            { any = true; to = "failed"; }
          ];
        }
        {
          field = "finished";
          label = "finished";
          format = "relativeDate";
        }
      ];
    };
  };
in
{
  services.homepage-dashboard = {
    enable = true;
    listenPort = 8082;
    # homepage rejects any other Host header, caddy passes this one through
    allowedHosts = host;

    settings = {
      title = "home";
      theme = "dark";
      color = "slate";
      headerStyle = "clean";
      statusStyle = "dot";
      hideVersion = true;
      # the version is pinned by the flake, a github check can only nag
      disableUpdateCheck = true;
      # a list, not an attrset: nix sorts attribute names, and the order here is the order on the page
      # row groups take the full width, so backups sit below services instead of beside them
      layout = [
        { "Services" = { style = "row"; columns = 4; }; }
        { "Backups" = { style = "row"; columns = 2; }; }
      ];
    };

    services = [
      {
        "Services" = [
          { "Actual" = service { name = "actual"; port = 5006; icon = "actual-budget.svg"; description = "budget"; }; }
          { "Mealie" = service { name = "mealie"; port = 9000; icon = "mealie.svg"; description = "recipes"; }; }
          { "Papra" = service { name = "papra"; port = 1221; icon = "papra.svg"; description = "documents"; }; }
          { "Drops" = service { name = "drops"; port = 8080; icon = "twitch.svg"; description = "twitch drops"; }; }
        ];
      }
      {
        # written by the hook in modules/server/backup.nix
        "Backups" = [
          { "Local" = backupStatus { job = "local"; icon = "restic.png"; description = "my book, nightly 03:00"; }; }
          { "Offsite" = backupStatus { job = "offsite"; icon = "backblaze.svg"; description = "backblaze b2, after local"; }; }
        ];
      }
    ];

    # both usb mounts are nofail, with a bridge absent its bar shows the root fs through the bare mountpoint
    widgets = [
      {
        resources = {
          label = "server";
          expanded = true;
          cpu = true;
          memory = true;
          uptime = true;
          disk = [ "/" "/mnt/data" "/mnt/backup" ];
        };
      }
    ];
  };

  # a fixed path for caddy to serve, the store path changes with every icon
  environment.etc."homepage-dashboard/icons".source = icons;

  # localhost only like the containers, caddy terminates tls in front of it
  # next's standalone server binds 0.0.0.0 unless told otherwise, and the module sets no address
  systemd.services.homepage-dashboard.environment.HOSTNAME = "127.0.0.1";
}
