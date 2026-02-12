````md
# nixos-flowback-infra

Infrastructure-as-code for the Flowback environment on **NixOS** (no flakes).  
Focus: **secure, portable, reproducible** host configuration for internal use.

The goal is that a new host can be set up by changing **only variables** (and providing local secrets), not by rewriting modules.

---

## Quick start

1) Copy `vars/example.nix` → `vars/local.nix` and edit values  
2) Run a dry build with your host config  
3) Switch when you’re ready

---

## Repo layout

```text
nixos-flowback-infra/
  hosts/
    laptop2/
      configuration.nix
      hardware-configuration.nix   # ignored (host-specific)
  modules/
    base.nix
    aliases.nix
    remote-unlock.nix
  vars/
    example.nix
    local.nix                      # ignored (your real values)
  .gitignore
  README.md
````

* `hosts/<name>/configuration.nix` = host entry point (imports modules + hardware)
* `modules/*.nix` = reusable building blocks (base services, aliases, remote unlock)
* `vars/example.nix` = safe template values (commit)
* `vars/local.nix` = real host values (DO NOT commit)
* `hosts/*/hardware-configuration.nix` = machine-specific (DO NOT commit)

---

## Security model

### What must NOT be committed

* `vars/local.nix`
* any tokens, passwords, runner registration tokens
* `/etc/secrets/*` (initrd SSH host keys, etc.)
* `hosts/*/hardware-configuration.nix`

### What IS safe to commit

* `vars/example.nix` with placeholders (e.g. `REPLACE_ME`)
* `modules/*`
* `hosts/*/configuration.nix` (no secrets inside)

---

## First-time setup on a new host

### 1) Create your local vars

Copy the template and edit it:

* `vars/example.nix` → `vars/local.nix`

`vars/local.nix` should be the only place where you set:

* hostname, interface name, IP/gateway/DNS
* open ports
* SSH authorized keys
* paths like `scriptsDir` / compose file locations

### 2) Provide initrd remote-unlock prerequisites (if enabled)

This setup supports **remote LUKS unlocking** via SSH in initrd.

You must have initrd SSH host keys available at the paths referenced by the config (example):

* `/etc/secrets/initrd_ed25519_key`
* `/etc/secrets/initrd_rsa_key`

Permissions should be strict (root-only). Do **not** store these in git.

---

## Build / test flow (safe order)

### A) Parse check (fast sanity)

```bash
nix-instantiate --parse hosts/laptop2/configuration.nix >/dev/null
echo $?
```

### B) Dry build (no activation)

```bash
sudo nixos-rebuild dry-build -I nixos-config=hosts/laptop2/configuration.nix
```

### C) Switch (activates changes)

```bash
sudo nixos-rebuild switch -I nixos-config=hosts/laptop2/configuration.nix
```

---

## Notes on portability

* `hardware-configuration.nix` is intentionally ignored because it is tied to disks, UUIDs, and hardware layout.
* `remote-unlock.nix` depends on secrets existing under `/etc/secrets/` on the target host.

```
::contentReference[oaicite:0]{index=0}
```

