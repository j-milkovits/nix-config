{ pkgs
, ...
}: {
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
}
