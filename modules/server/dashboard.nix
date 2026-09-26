{ config
, domain
, ...
}:
let
  host = "dash.home.${domain}";

  # one link per service, the monitor checks the container directly instead of looping out through dns and caddy
  # actual, mealie and papra show down around 03:00, the local backup stops them for the run
  service = name: port: {
    href = "https://${name}.home.${domain}";
    siteMonitor = "http://127.0.0.1:${toString port}";
  };

  # fetched by homepage's backend, not the browser - the status files sit behind caddy (modules/server/proxy.nix)
  # a job that never started writes nothing, so the age of "finished" is the real signal, not "result"
  backupStatus = job: {
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

    services = [
      {
        "Services" = [
          { "Actual" = service "actual" 5006; }
          { "Mealie" = service "mealie" 9000; }
          { "Papra" = service "papra" 1221; }
          { "Drops" = service "drops" 8080; }
        ];
      }
      {
        # written by the hook in modules/server/backup.nix
        "Backups" = [
          { "Local" = backupStatus "local"; }
          { "Offsite" = backupStatus "offsite"; }
        ];
      }
    ];

    # both usb mounts are nofail, with a bridge absent its bar shows the root fs through the bare mountpoint
    widgets = [
      {
        resources = {
          cpu = true;
          memory = true;
          uptime = true;
          disk = [ "/" "/mnt/data" "/mnt/backup" ];
        };
      }
    ];
  };

  # localhost only like the containers, caddy terminates tls in front of it
  # next's standalone server binds 0.0.0.0 unless told otherwise, and the module sets no address
  systemd.services.homepage-dashboard.environment.HOSTNAME = "127.0.0.1";
}
