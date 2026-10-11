{ config
, pkgs
, domain
, username
, ...
}:
let
  host = "ntfy.home.${domain}";
  port = 2586;
  topic = "server";

  # `ntfy-send <title> <message>`, for smartd.nix, failures.nix and a shell on the box
  # posts over the loopback, so an alert does not depend on caddy or dns being up
  ntfySend = pkgs.writeShellApplication {
    name = "ntfy-send";
    # smartd runs its hook with an empty path, so cat has to come along too
    runtimeInputs = [ pkgs.coreutils pkgs.curl ];
    text = ''
      curl --silent --show-error --output /dev/null \
        --header "Authorization: Bearer $(cat ${config.sops.secrets."ntfy-token".path})" \
        --header "Title: $1" --header "Priority: high" \
        --data "$2" \
        http://127.0.0.1:${toString port}/${topic}
    '';
  };
in
{
  # the phone's password hash and the scripts' token, declared through the env file so neither enters the store
  sops.secrets."ntfy-user-hash" = { };
  sops.secrets."ntfy-token" = { };
  sops.templates."ntfy.env" = {
    content = ''
      NTFY_AUTH_USERS=${username}:${config.sops.placeholder."ntfy-user-hash"}:user
      NTFY_AUTH_TOKENS=${username}:${config.sops.placeholder."ntfy-token"}:alerts
    '';
    restartUnits = [ "ntfy-sh.service" ];
  };

  services.ntfy-sh = {
    enable = true;
    environmentFile = config.sops.templates."ntfy.env".path;
    settings = {
      base-url = "https://${host}";
      # localhost only, caddy terminates tls in front (modules/server/proxy.nix)
      listen-http = "127.0.0.1:${toString port}";
      behind-proxy = true;
      # nobody reads or posts without the user above, the phone with the password, the scripts with the token
      auth-default-access = "deny-all";
      auth-access = [ "${username}:${topic}:rw" ];
      # the app fetches what it missed on reconnect, a day away with the tunnel off must fit
      cache-duration = "72h";
    };
  };

  environment.systemPackages = [ ntfySend ];
}
