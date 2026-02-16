{ lib, config, pkgs, ... }:

/*
  Module: prompt-timestamp.nix

  What it does:
  - Adds a portable timestamp + username prefix to the interactive shell prompt.
  - Works for ANY user because it is applied system-wide.
  - Example prefix: 02/16-2026-19:43-ayuub

  How to use:
  1) Put this file in: modules/prompt-timestamp.nix
  2) Import it in your host config:
       ../../modules/prompt-timestamp.nix
  3) Enable it:
       flowback.promptTimestamp.enable = true;
*/

let
  cfg = config.flowback.promptTimestamp;

  # strftime format (bash: \D{...}, zsh: %D{...})
  fmt = cfg.format;

  # Prefix strings (leave the rest of the user's prompt intact)
  bashPrefix = ''\D{${fmt}}-\u '';
  zshPrefix  = ''%D{${fmt}}-%n '';
in
{
  options.flowback.promptTimestamp = {
    enable = lib.mkEnableOption "Timestamp + username prefix in shell prompt";

    format = lib.mkOption {
      type = lib.types.str;
      default = "%m/%d-%Y-%H:%M";
      description = "strftime timestamp format for the prompt prefix.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Applied for all interactive shells system-wide (all users).
    environment.interactiveShellInit = ''
      # Bash: prepend timestamp-user prefix to existing PS1
      if [ -n "''${BASH_VERSION-}" ]; then
        export PS1="${bashPrefix}$PS1"
      fi

      # Zsh: prepend timestamp-user prefix to existing PROMPT
      if [ -n "''${ZSH_VERSION-}" ]; then
        PROMPT="${zshPrefix}$PROMPT"
      fi
    '';
  };
}

