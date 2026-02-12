{ config, lib, pkgs, ... }:

let
  vars = import ../../vars/local.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/aliases.nix
    ../../modules/remote-unlock.nix
  ];

  _module.args = { inherit vars; };

  users.users.ayuub = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    openssh.authorizedKeys.keys = vars.authorizedKeys;
  };

  security.sudo.wheelNeedsPassword = true;

  networking.hostName = vars.hostName;

  networking.useDHCP = false;

  # FIX: define the interface as one block (avoids duplicate dynamic attr)
  networking.interfaces.${vars.iface} = {
    useDHCP = false;
    ipv4.addresses = [{
      address = vars.ip;
      prefixLength = vars.prefixLength;
    }];
  };

  networking.defaultGateway = vars.gateway;
  networking.nameservers = vars.nameservers;

  networking.extraHosts = ''
    127.0.0.1 ${vars.forgejoHost}
    ${vars.forgejoIp} ${vars.forgejoHost}
  '';

  networking.firewall = {
    enable = true;
    allowedTCPPorts = vars.allowedTCPPorts;
  };
}

