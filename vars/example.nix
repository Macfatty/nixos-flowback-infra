{
  # Paths
  scriptsDir = "/persist/scripts";
  flowbackCompose = "/persist/compose/flowback/docker-compose.yml";

  # Host identity
  hostName = "laptop2";
  iface = "enp0s31f6";

  # Network
  ip = "192.168.0.75";
  prefixLength = 24;
  gateway = "192.168.0.1";
  nameservers = [ "1.1.1.1" "8.8.8.8" ];

  forgejoHost = "git.local";
  forgejoIp = "192.168.0.75";

  allowedTCPPorts = [ 22 2222 3001 8000 3000 8080 80 ];

  authorizedKeys = [
    "ssh-ed25519 REPLACE_ME your@key"
  ];
}

