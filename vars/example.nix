{
  # ---------------------------------------------------------------------------
  # Paths
  # ---------------------------------------------------------------------------
  scriptsDir = "/persist/scripts";
  flowbackCompose = "/persist/compose/flowback/docker-compose.yml";

  # ---------------------------------------------------------------------------
  # Host identity
  # ---------------------------------------------------------------------------
  hostName = "laptop2";
  iface = "enp0s31f6";

  # ---------------------------------------------------------------------------
  # Network
  # ---------------------------------------------------------------------------
  ip = "192.168.0.75";
  prefixLength = 24;
  gateway = "192.168.0.1";
  nameservers = [ "1.1.1.1" "8.8.8.8" ];

  forgejoHost = "git.local";
  forgejoIp = "192.168.0.75";

  allowedTCPPorts = [ 22 2222 3001 8000 3000 8080 80 ];


  # ---------------------------------------------------------------------------
  # Main user (portable)
  # ---------------------------------------------------------------------------

  # Required: the primary admin user for the host.
  mainUserName = "CHANGE_ME";
 
   # SSH public keys allowed for:
  # - normal SSH login (port 22)
  # - initrd remote unlock SSH (port 2222), if enabled
  authorizedKeys = [
    "ssh-ed25519 REPLACE_ME your@key"
  ];

  # Optional: groups for the main user.
  mainUserExtraGroups = [ "wheel" "networkmanager" "docker" ];

  # Optional: local password hash file (NOT in repo).
  # Use this only if you want password-based console login or sudo with password.
  mainUserPasswordHashFile = null;
  # Example:
  # mainUserPasswordHashFile = "/etc/secrets/users/CHANGE_ME.shadowhash";
}

