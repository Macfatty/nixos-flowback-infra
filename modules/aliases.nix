{ config, lib, pkgs, vars, ... }:

/*
  Module: aliases.nix

  What it does:
  - Defines system-wide shell aliases for Flowback helpers, Compose ops, and rebuilds.

  How to use:
  - Import this module on a host.
  - Ensure the host passes `vars` via `_module.args.vars` (same pattern as base.nix).
*/

{
  environment.shellAliases = {
    # Docs / helpers
    fb-help = "sh ${vars.scriptsDir}/fb-help.sh";
    fb-sync = "sh ${vars.scriptsDir}/fb-sync.sh";

    # Compose ops
    fb-up   = "docker-compose -f ${vars.flowbackCompose} up -d --build";
    fb-logs = "docker-compose -f ${vars.flowbackCompose} logs -f";

    # Nix
    nix-switch = "sudo nixos-rebuild switch";
  };
}

