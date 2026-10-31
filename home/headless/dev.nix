{ pkgs
, ...
}: {
  # global like on any distro, the repos stay nix-free - nix-ld (modules/base) runs what these download
  home.packages = with pkgs; [
    uv
    python3
    nodejs
    pnpm
  ];

  # loads a project's .envrc on entering its directory, unloads it on leaving
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };
}
