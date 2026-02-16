{ lib, config, pkgs, ... }:

let
  cfg = config.flowback.hardening;
in
{
  options.flowback.hardening = {
    enable = lib.mkEnableOption "Baseline hardening for Flowback hosts (portable defaults)";

    # Keep this true for rootless Docker / dev tooling that relies on user namespaces.
    allowUserNamespaces = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Allow unprivileged user namespaces (needed for rootless containers).";
    };

    # Audit is useful for servers; it adds some overhead but gives you execution telemetry.
    enableAuditd = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Linux audit subsystem + minimal exec auditing.";
    };

    # journald retention control; default is persistent logs with size limits.
    journaldVolatile = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Store logs in RAM only (volatile). Disables post-reboot log forensics.";
    };

    # Optional: disable extra “desktop-ish” services (good for servers).
    disableNoisyServices = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable services that often increase attack surface on servers.";
    };

    extraSysctl = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
      description = "Extra sysctl keys to merge into boot.kernel.sysctl.";
    };
  };

  config = lib.mkIf cfg.enable {

    /*
      Core idea:
      - Prefer “boring hardening”: reduce info leaks, enable audit, tighten SSH.
      - Avoid settings that commonly break CI/containers (keep user namespaces allowed).
      - Keep it portable: no hostnames, no interface names, no /persist paths.
    */
    
        # Fix: dbus reload can hang during activation. Force a fast, safe reload.
    systemd.services.dbus-broker.serviceConfig = {
      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      TimeoutSec = "10s";
    };

    
    # systemd-coredump can leak secrets via core files; disable for hardened servers.
    systemd.coredump.enable = false;

    # Use dbus-broker (more robust than classic dbus-daemon in many setups).
    services.dbus.implementation = "broker";

    # Prevent log disks from exploding; keep classic logs rotated too.
    services.logrotate.enable = true;

    services.journald = {
      storage = if cfg.journaldVolatile then "volatile" else "persistent";
      upload.enable = false;
      extraConfig = ''
        SystemMaxUse=500M
        SystemMaxFileSize=50M
      '';
    };

    # Baseline kernel hardening toggles (NixOS-level).
    security.protectKernelImage = true;

    # Keep user namespaces enabled if you're doing rootless Docker / modern tooling.
    security.allowUserNamespaces = cfg.allowUserNamespaces;

    # Sysctl: reduce common info leaks + tighten risky defaults.
    # Note: keep "net.ipv4.ip_unprivileged_port_start" in base.nix for rootless 80/443 use.
    boot.kernel.sysctl = lib.mkMerge [
      {
        "kernel.kptr_restrict" = 2;
        "kernel.dmesg_restrict" = 1;
        "fs.suid_dumpable" = 0;

        # Disable automatic loading of TTY line disciplines (historic attack surface).
        "dev.tty.ldisk_autoload" = 0;

        # Disable unprivileged userfaultfd (often used in exploit chains).
        "vm.unprivileged_userfaultfd" = 0;

        # Disable kexec loading (hardens against some persistence / bypass tricks).
        "kernel.kexec_load_disabled" = 1;

        # Reduce kernel attack surface from unprivileged perf use.
        "kernel.perf_event_paranoid" = 3;
      }
      cfg.extraSysctl
    ];

    # Minimal auditing: log execve on x86_64 (good signal with low rule complexity).
    boot.kernelParams = lib.mkIf cfg.enableAuditd [ "audit=1" ];
    security.auditd.enable = cfg.enableAuditd;
    security.audit.enable = cfg.enableAuditd;
    security.audit.rules = lib.mkIf cfg.enableAuditd [
      "-a exit,always -F arch=b64 -S execve"
    ];

    # SSH hardening (builds on whatever you already set in base.nix).
    services.openssh.settings = {
      # No interactive password auth (already in your base, but safe to enforce here too).
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";

      # Reduce brute force usefulness.
      MaxAuthTries = 3;
      LoginGraceTime = "30s";

      # Disable features you typically don't need on servers.
      X11Forwarding = false;
      AllowTcpForwarding = "no";
      AllowAgentForwarding = "no";
    };

    # Optional: reduce extra server attack surface (tweak per host).
    services.avahi.enable = lib.mkIf cfg.disableNoisyServices (lib.mkForce false);
    hardware.bluetooth.enable = lib.mkIf cfg.disableNoisyServices (lib.mkForce false);
    networking.modemmanager.enable = lib.mkIf cfg.disableNoisyServices (lib.mkForce false);
  };
}

