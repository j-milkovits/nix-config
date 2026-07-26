{ config
, domain
, userEmail
, ...
}:
let
  # one wildcard cert for every service, named after the zone it covers
  certName = "home.${domain}";
in
{
  # porkbun api credentials, lego reads them at every renewal
  sops.secrets."porkbun-api-key" = { };
  sops.secrets."porkbun-secret-api-key" = { };

  security.acme = {
    acceptTerms = true;
    defaults.email = userEmail;

    # dns-01: the server proves it owns the domain by writing a txt record, nothing inbound
    # http-01 would need port 80 open to the internet
    certs.${certName} = {
      # a wildcard is dns-01 only, and it keeps service names out of the public transparency logs
      domain = "*.${certName}";
      dnsProvider = "porkbun";
      # lego falls back to <VAR>_FILE, and systemd hands the file over as a credential
      # so the secrets stay root-owned 0400, unreadable by the acme user itself
      credentialFiles = {
        "PORKBUN_API_KEY_FILE" = config.sops.secrets."porkbun-api-key".path;
        "PORKBUN_SECRET_API_KEY_FILE" = config.sops.secrets."porkbun-secret-api-key".path;
      };
    };
  };

  services.caddy = {
    enable = true;

    openFirewall = true;

    virtualHosts."actual.${certName}" = {
      # binds tls to the cert above, which also stops caddy from issuing anything itself
      # caddy owning the cert group and reloading on renewal comes with this
      useACMEHost = certName;
      # 127.0.0.1, not localhost: the container binds v4 only and localhost can resolve to ::1
      extraConfig = "reverse_proxy 127.0.0.1:5006";
    };
  };
}
