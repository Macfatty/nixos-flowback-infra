# nixos-flowback-infra

Infrastructure-as-code for the Flowback environment on **NixOS** (no flakes).
Focus: **secure, portable, reproducible** host configuration for internal use.

This repo is designed so a new host can be set up by changing **only variables** (and providing local secrets), not rewriting modules.

---

## Repo layout

```text
nixos-flowback-infra/
  hosts/
    laptop2/
      configuration.nix
      hardware-configuration.nix
  modules/
    base.nix
    aliases.nix
    remote-unlock.nix
  vars/
    example.nix
    local.nix        # ignored (your real values)
  .gitignore
  README.md


- `hosts/<name>/configuration.nix` = host entry point (imports modules + hardware)
- `modules/*.nix` = reusable building blocks (base services, aliases, remote unlock)
- `vars/example.nix` = template values (safe to commit)
- `vars/local.nix` = real values for a host (MUST NOT be committed)

---

## Security model (important)

### What must NOT be committed
- `vars/local.nix`
- any tokens, passwords, runner registration tokens
- `/etc/secrets/*` (initrd SSH host keys, etc.)

### What IS safe to commit
- `vars/example.nix` with placeholder keys (REPLACE_ME)
- `modules/*` and `hosts/*` (except secrets)

---

## First-time setup on a new host

### 1) Create your local vars
Copy the template and edit it:
- `vars/example.nix` → `vars/local.nix`

`local.nix` is the only place where you should need to set:
- hostname, interface name, IP/gateway/DNS
- open ports
- SSH authorized keys
- paths like `scriptsDir` / compose file location

### 2) Provide initrd remote-unlock prerequisites (if enabled)
This setup supports **remote LUKS unlocking** via SSH in initrd.

You must have initrd SSH host keys available at the paths referenced by the config (example):
- `/etc/secrets/initrd_ed25519_key`
- `/etc/secrets/initrd_rsa_key`

Permissions should be strict (root-only). Do **not** store these in git.

---

## Build / test flow (safe order)

### A) Parse check (fast sanity)
```bash
nix-instantiate --parse hosts/laptop2/configuration.nix >/dev/null
echo $?
