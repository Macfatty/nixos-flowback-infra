{ config, lib, pkgs, vars, ... }:

{
  # This creates the fb-mgr script globally on the server, 
  # making it available to all users without needing manual copies.
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "fb-mgr" ''
      #!/bin/bash
      # --- Flowback Stack Manager ---
      # Manages the lifecycle of the infrastructure and application

      # Variables pulled directly from vars/local.nix
      FORGEJO_COMPOSE="${vars.forgejoCompose}"
      FLOWBACK_COMPOSE="${vars.flowbackCompose}"
      NETWORK_NAME="flowback-shared-net"

      case "$1" in
        up)
          echo "--- Starting full Flowback stack ---"
          
          # 1. Ensure the shared Docker network exists
          if ! docker network ls | grep -q "$NETWORK_NAME"; then
            echo "[1/3] Creating shared network: $NETWORK_NAME"
            docker network create "$NETWORK_NAME"
          fi

          # 2. Start Forgejo Infrastructure (Git server + DB)
          echo "[2/3] Starting Forgejo Infrastructure..."
          docker-compose -f "$FORGEJO_COMPOSE" up -d

          # 3. Start Flowback Application (BE/FE/Gateway)
          echo "[3/3] Starting Flowback Application..."
          docker-compose -f "$FLOWBACK_COMPOSE" up -d

          echo "--- All systems are up and running ---"
          ;;

        down)
          echo "--- Shutting down full stack ---"
          docker-compose -f "$FLOWBACK_COMPOSE" down
          docker-compose -f "$FORGEJO_COMPOSE" down
          echo "--- All systems stopped ---"
          ;;

        restart)
          $0 down
          $0 up
          ;;

        *)
          echo "Usage: fb-mgr {up|down|restart}"
          exit 1
          ;;
      esac
    '')
  ];
}
