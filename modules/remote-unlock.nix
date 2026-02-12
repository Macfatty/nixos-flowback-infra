{ config, lib, pkgs, vars, ... }:

{
  # Remote LUKS unlock via SSH in initrd (early boot)
  # Requires host keys on disk (DO NOT store private keys in git).
  boot.kernelParams = [
    # Format: ip=<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf>
    "ip=${vars.ip}::${vars.gateway}:${vars.netmask}:${vars.hostName}:${vars.iface}:none"
  ];

  boot.initrd = {
    # NIC drivers needed in initrd (adjust per host hardware)
    availableKernelModules = vars.initrdKernelModules;

    network = {
      enable = true;

      ssh = {
        enable = true;
        port = vars.initrdSshPort;

        # Paths to initrd SSH host keys (keep them OUT of the repo)
        hostKeys = vars.initrdHostKeys;

        # Public keys allowed to unlock remotely
        authorizedKeys = vars.authorizedKeys;
      };
    };
  };
}

