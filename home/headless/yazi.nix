{ pkgs
, ...
}: {
  # terminal file manager, vim keys, image previews over the kitty graphics protocol
  # fd, ripgrep, fzf and zoxide are picked up from the profile for search and jumps
  programs.yazi = {
    enable = true;
    # `y` opens yazi and leaves the shell in the directory it quit in
    enableZshIntegration = true;
    # the module's default for a home.stateVersion before 26.05 is the old `yy`
    shellWrapperName = "y";
    # previews past text and images: video frames, pdf pages, svg
    extraPackages = with pkgs; [ ffmpeg poppler-utils resvg imagemagick ];
  };
}
