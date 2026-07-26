{ pkgs
, config
, claude-code-nix
, mcp-nixos
, ...
}: {
  programs.claude-code = {
    enable = true;
    package = claude-code-nix.packages.${pkgs.system}.default;
    settings = {
      theme = "dark";
      includeCoAuthoredBy = false;
    };

    # nixos/home-manager option lookups, so option names and types are checked instead of remembered
    mcpServers.nixos = {
      type = "stdio";
      command = "${mcp-nixos.packages.${pkgs.system}.default}/bin/mcp-nixos";
    };
  };
}
