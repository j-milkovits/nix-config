{ pkgs
, lib
, username
, ...
}: {
  # define a user account
  # set password with `passwd`
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # will be installed in all systems on root level
  environment.systemPackages = with pkgs; [
    curl
    git
    vim
    wget

    # TODO: move this
    vscodium
    firefox
    font-awesome
    obsidian
    spotify
    pavucontrol
    pamixer
    nixpkgs-fmt
    libreoffice
    bambu-studio
    freecad
    zapzap
  ];

  # setup zsh for all users
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  fonts = {
    packages = with pkgs; [
      # icon fonts
      material-design-icons

      # normal fonts
      noto-fonts
      noto-fonts-color-emoji

      # nerdfonts
      nerd-fonts.symbols-only
      nerd-fonts.fira-code
    ];

    enableDefaultPackages = false; # use fonts specified by user rather than default ones

    # user defined fonts
    # Noto Color Emoji everywhere: override DejaVu's B&W emojis
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" "Noto Color Emoji" ];
      sansSerif = [ "Noto Sans" "Noto Color Emoji" ];
      monospace = [ "FiraCode Nerd Font Mono" "Noto Color Emoji" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # allow specification of additional substituters
  # nix.settings.trusted-users = [username];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    # substituters = ["https://cache.nixos.org"];
  };

  nixpkgs.config.allowUnfree = lib.mkDefault true;

  # garbage collection
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  time.timeZone = "Europe/Berlin"; # set your time zone

  i18n.defaultLocale = "en_US.UTF-8"; # select internationalisation properties

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  services.printing.enable = true; # enable CUPS to print documents

  # enable sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.enable = false; # disable the firewall altogether
}
