{ config, lib, pkgs, ... }:

let
  vars = import ../vars/local.nix;
in
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

