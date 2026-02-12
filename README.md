````md
# nixos-flowback-infra

Infrastructure-as-code for the Flowback environment on **NixOS** (no flakes).  
Focus: **secure, portable, reproducible** host configuration for internal use.

The goal is that a new host can be set up by changing **only variables** (and providing local secrets), not by rewriting modules.

---

## Requirements

- A working NixOS installation on the target host
- SSH access to the host
- Optional (only if you enable remote unlock): initrd SSH host keys available under `/etc/secrets/`

---

## Quick start

1) Copy `vars/example.nix` → `vars/local.nix` and edit values  
2) Create a host entry under `hosts/<your-host>/`  
3) Run a dry build with your host config  
4) Switch when you’re ready

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
* `hosts/*/hardware-configuration.nix` = ignored (DO NOT commit)

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

## Host onboarding (portable workflow)

### 1) Create your local vars

Copy the template and edit it:

* `vars/example.nix` → `vars/local.nix`

`vars/local.nix` should be the only place where you set:

* hostname, interface name, IP/gateway/DNS
* open ports
* SSH authorized keys
* paths like `scriptsDir` / compose file locations

### 2) Create a host entry

Create a new directory and add your host configuration:

* `hosts/<your-host>/configuration.nix`

**Important:** `hardware-configuration.nix` is machine-specific and intentionally ignored by git.
On a new host, generate it normally under `/etc/nixos/` (or copy it into `hosts/<your-host>/` locally) but do not commit it.

### 3) State version is required

Every host must set `system.stateVersion` (do not change it later unless you know why).
This prevents surprising defaults when NixOS evolves.

Example locations to set it:

* in `hosts/<your-host>/configuration.nix`, or
* centrally in `modules/base.nix` (if you want a single default for all hosts)

---

## Remote LUKS unlock (optional)

This repo supports **remote LUKS unlocking** via SSH in initrd **only if you import** `modules/remote-unlock.nix`.

* If you do **not** need remote unlock: **do not import** `modules/remote-unlock.nix` in your host config.
* If you **do** enable it: you must have initrd SSH host keys available at the paths referenced by the config (example):

  * `/etc/secrets/initrd_ed25519_key`
  * `/etc/secrets/initrd_rsa_key`

Permissions should be strict (root-only). Do **not** store these keys in git.

---

## Build / test flow (safe order)

Replace `laptop2` with your actual host folder name.

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

## Git strategy (current + future)

### Current phase (today)

* **GitHub = source of truth**
* **Forgejo = internal mirror**
* You pull from GitHub and push to Forgejo.

### Future phase (when stable)

* **Forgejo = source of truth**
* **GitHub = mirror**
* You push to Forgejo and mirror to GitHub.

Keep secrets out of git in both phases (tokens, deploy keys, runner tokens).

---

## Notes on portability

* `hardware-configuration.nix` is intentionally **ignored** because it is tied to disks, UUIDs, and hardware layout.
* `remote-unlock.nix` depends on secrets existing under `/etc/secrets/` on the target host (only if enabled).
* Prefer host-specific settings in `vars/local.nix` so onboarding a new machine is mostly “copy + edit variables”.

```
