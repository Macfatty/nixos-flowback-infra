{ config, lib, pkgs, vars, ... }:

{
  # Bootloader (UEFI + systemd-boot)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # REQUIRED: pin stateVersion (matcha din nuvarande maskin)
  system.stateVersion = "25.11";
  
  # Locale / timezone (could be moved into vars later)
  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "sv-latin1";

  # Git (useful to have on infra hosts)
  programs.git.enable = true;

  # SSH hardening
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Avahi (optional, but use it for .local)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # Fail2ban (basic protection)
  services.fail2ban.enable = true;

  # Rootless Docker
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # Allow rootless services to bind to ports >= 80
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

  # Base tools (keep it small; extend later via dedicated modules)
  environment.systemPackages = with pkgs; [
    vim 
    wget 
    curl 
    git 
    btop
    nftables 
    pciutils 
    lm_sensors
    docker docker-compose
  ];

  # Your helper aliases (can be moved into a dedicated module later)
  environment.shellAliases = {
    fb-help = "sh /persist/scripts/fb-help.sh";
    fb-sync = "sh /persist/scripts/fb-sync.sh";
    fb-up   = "docker-compose -f /persist/compose/flowback/docker-compose.yml up -d --build";
    fb-logs = "docker-compose -f /persist/compose/flowback/docker-compose.yml logs -f";
    nix-switch = "sudo nixos-rebuild switch";
  };

  # Allow unfree packages (if needed later)
  nixpkgs.config.allowUnfree = true;
}

