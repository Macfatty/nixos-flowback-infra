{ config, lib, pkgs, vars, ... }:

let
  # Required: name of the main admin user (set in vars/local.nix)
  userName = vars.mainUserName;

  # SSH keys:
  # Prefer mainUserAuthorizedKeys (new), fall back to authorizedKeys (legacy / shared with initrd unlock).
  userKeys =
    if vars ? mainUserAuthorizedKeys
    then (vars.mainUserAuthorizedKeys or [])
    else (vars.authorizedKeys or []);

  # Optional: extra groups for the user (wheel = sudo)
  userExtraGroups = vars.mainUserExtraGroups or [ "wheel" ];

  # Optional: local password hash file (must NOT be stored in Git)
  passwordHashFile = vars.mainUserPasswordHashFile or null;
in
{
  # Basic sanity checks (fail fast during build)
  assertions = [
    {
      assertion = userName != null && userName != "";
      message = "vars.mainUserName must be set (see vars/example.nix).";
    }
    {
      assertion = builtins.isList userKeys;
      message = "authorizedKeys/mainUserAuthorizedKeys must be a list of SSH public keys.";
    }
  ];

  # Dedicated primary group (NixOS requires an explicit safe default)
  users.groups.${userName} = {};

  # Main admin user (SSH-key login by default)
  users.users.${userName} = {
    isNormalUser = true;
    group = userName;
    extraGroups = userExtraGroups;
    openssh.authorizedKeys.keys = userKeys;
  }
  # Enable password auth only if a local hash file is provided
  // lib.optionalAttrs (passwordHashFile != null) {
    hashedPasswordFile = passwordHashFile;
  };
}

