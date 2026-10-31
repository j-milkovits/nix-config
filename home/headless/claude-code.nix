{ lib
, pkgs
, claude-code-nix
, mcp-nixos
, ...
}:
let
  # the tool-agnostic source of truth (agents/README.md), claude code consumes it through the options below
  agents = ../../agents;
  # a folder is linked once it exists, git tracks no empty directories
  dirIf = name: lib.mkIf (builtins.pathExists (agents + "/${name}")) (agents + "/${name}");
in
{
  programs.claude-code = {
    enable = true;
    package = claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = {
      theme = "dark";
      includeCoAuthoredBy = false;
    };

    # ~/.claude/CLAUDE.md
    context = agents + "/global-rules.md";
    # one folder per skill, linked file by file so claude's own synced skills next to them stay
    skills = dirIf "skills";
    agentsDir = dirIf "agents";
    commandsDir = dirIf "commands";
    hooksDir = dirIf "hooks";

    # nixos/home-manager option lookups, so option names and types are checked instead of remembered
    mcpServers.nixos = {
      type = "stdio";
      command = "${mcp-nixos.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/mcp-nixos";
    };
  };
}
