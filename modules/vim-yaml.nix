{ lib, config, pkgs, ... }:

/*
  Module: vim-yaml.nix

  What this module does (when enabled):
  1) Installs Vim system-wide (so any user has vim available).
  2) Writes a global Vim configuration to /etc/vimrc:
     - Uses spaces instead of tabs
     - Sets indentation width to 2 (common for YAML)
     - Shows whitespace so YAML indentation mistakes are visible
     - Enables filetype plugins/indent
     - Ensures /etc/vim is in Vim's runtimepath
  3) Writes a YAML-specific ftplugin to /etc/vim/ftplugin/yaml.vim:
     - Forces YAML files to use 2-space indentation and no tabs
     - Keeps YAML formatting consistent across hosts

  Why this is "portable":
  - No username-specific paths (unlike Home Manager)
  - You can import this module on any host and just set:
      flowback.vimYaml.enable = true;
*/

let
  # Shortcut to this module's configuration subtree.
  # Enabled from a host config with:
  #   flowback.vimYaml.enable = true;
  cfg = config.flowback.vimYaml;
in
{
  # Expose an enable/disable switch under the "flowback" namespace.
  options.flowback.vimYaml.enable =
    lib.mkEnableOption "Install Vim + enforce 2-space YAML indentation";

  config = lib.mkIf cfg.enable {

    # Ensure Vim is installed for all users.
    # We use environment.systemPackages because programs.vim.extraConfig
    # is not available on your NixOS option set.
    environment.systemPackages = [ pkgs.vim ];

    # Global Vim configuration applied to all users via /etc/vimrc.
    # This sets sane defaults for editing config files, especially YAML.
    environment.etc."vimrc".text = ''
      " Use spaces instead of tabs
      set expandtab

      " Indentation width (YAML convention)
      set shiftwidth=2
      set softtabstop=2
      set tabstop=2

      " Keep indentation and make auto-indenting predictable
      set autoindent
      set smartindent

      " Show whitespace to catch YAML mistakes early
      set list
      set listchars=tab:»·,trail:·,extends:>,precedes:<

      " Do not wrap long lines (often helps readability in YAML)
      set nowrap

      " Enable filetype detection + plugins + indent rules
      filetype plugin indent on

      " Make sure the /etc/vim runtime directory is searched,
      " so the YAML ftplugin below is discovered.
      set rtp^=/etc/vim
    '';

    # YAML-specific settings.
    # Vim loads this automatically for *.yml/*.yaml when filetype plugins are enabled.
    environment.etc."vim/ftplugin/yaml.vim".text = ''
      " YAML: always 2 spaces, never tabs
      setlocal expandtab
      setlocal shiftwidth=2
      setlocal softtabstop=2
      setlocal tabstop=2

      " Keep YAML indentation behavior consistent
      setlocal autoindent
      setlocal smartindent

      " Avoid wrapping YAML lines
      setlocal nowrap
    '';
  };
}

