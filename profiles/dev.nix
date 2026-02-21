{ config, lib, pkgs, ... }:

{
  /*
    Developer profile:
    - Productive daily-work defaults
    - Avoids hardening that can break tooling
  */

  imports = [
    ../modules/base.nix
    ../modules/aliases.nix
    ../modules/vim-yaml.nix
    ../modules/prompt-timestamp.nix
  ];

  # Enable developer conveniences
  flowback.vimYaml.enable = true;
  flowback.promptTimestamp.enable = true;

  # Hardening intentionally NOT enabled here by default
  # flowback.hardening.enable = false;
}

