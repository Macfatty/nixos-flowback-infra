{ config, lib, pkgs, ... }:

{
  /*
    Server profile:
    - Predictable baseline for admin-managed hosts
    - Includes hardening/audit/sysctl/SSH tightening (via hardening module)
  */

  imports = [
    ../modules/base.nix
    ../modules/aliases.nix
    ../modules/users.nix
    ../modules/hardening.nix
    ../modules/prompt-timestamp.nix
  ];

  # Enable baseline hardening
  flowback.hardening.enable = true;
  
  # Enable timestomp in promt
  flowback.promptTimestamp.enable = true;

  # Remote unlock intentionally NOT included here (host-specific + secrets on disk)
}
