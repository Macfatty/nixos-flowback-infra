{ config, lib, pkgs, vars, ... }:

{
  environment.shellAliases = {
    # Docs / helpers
    fb-help = "sh ${vars.scriptsDir}/fb-help.sh";
    fb-sync = "sh ${vars.scriptsDir}/fb-sync.sh";

    # Use our new global NixOS script!
    fb-up   = "fb-mgr up";
    fb-down = "fb-mgr down";
    fb-logs = "docker logs -f flowback-gateway";

    # Nix
    nix-switch = "sudo nixos-rebuild switch";
  };
}
