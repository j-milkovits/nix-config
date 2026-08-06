{ config
, domain
, username
, ...
}:
let
  # jinja, rendered per document and re-rendered whenever its metadata changes
  # an unset field drops its own separator, so nothing leaves a gap behind
  filenameFormat =
    "{{ created_year }}"
    + "/{% if correspondent %}{{ correspondent | replace(' ', '-') }}{% else %}unknown{% endif %}"
    + "/{{ created_year }}-{{ created_month }}-{{ created_day }}"
    + "{% if document_type %}_{{ document_type | replace(' ', '-') }}{% endif %}"
    + "{% if title %}_{{ title | replace(' ', '-') }}{% endif %}";
in
{
  # systemd hands this to the scheduler as a credential, so it stays root-owned 0400
  sops.secrets."paperless-admin-password" = { };

  services.paperless = {
    enable = true;

    # the only source of PAPERLESS_URL, which csrf and every absolute link are built from
    # the bundled nginx stays off, caddy fronts this like every other service
    domain = "paperless.home.${domain}";
    passwordFile = config.sops.secrets."paperless-admin-password".path;

    # dataDir keeps its /var/lib/paperless default: sqlite does not belong behind the usb bridge
    # documents do, they are write-once blobs
    mediaDir = "/mnt/data/media/paperless/media";
    consumptionDir = "/mnt/data/media/paperless/consume";

    settings = {
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_ADMIN_USER = username;

      # without this documents land as 0000001.pdf, unusable if paperless itself is ever down
      PAPERLESS_FILENAME_FORMAT = filenameFormat;
    };
  };

  # without this it can start with /mnt/data absent and write into the bare mountpoint
  systemd.services.paperless-task-queue.unitConfig.RequiresMountsFor = [
    config.services.paperless.mediaDir
    config.services.paperless.consumptionDir
  ];
}
