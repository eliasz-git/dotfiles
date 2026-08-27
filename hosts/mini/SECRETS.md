# Secrets — sops-nix (optional) + .env

You don't need sops-nix to get going — `.env` files for gluetun/mullvad are fine and already gitignored. This doc is for when you want secrets in the Nix store to be encrypted and versioned.

## Option A — simple (.env, today)

```bash
# mini2 media stack
cp hosts/mini/2/stacks/media/.env.example hosts/mini/2/stacks/media/.env
# fill WIREGUARD_PRIVATE_KEY, etc.
# .env is in .gitignore — never committed
```

Same for `hosts/mini/1/stacks/infra/.env` if you add caddy auth.

## Option B — sops-nix (later, recommended)

1. Add input to `flake.nix`:

```nix
inputs.sops-nix.url = "github:Mic92/sops-nix";
inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
```

2. Generate age key on your Mac (where you edit secrets):

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt  # copy public key
# public key looks like age1ql3z7hj...
```

3. Create `hosts/mini/secrets.yaml` encrypted with that key (sops):

```bash
nix shell nixpkgs#sops nixpkgs#age -c sops hosts/mini/secrets.yaml
```

Example `secrets.yaml` (before encryption):

```yaml
mullvad_private_key: YOUR_MULLVAD_WIREGUARD_PRIVATE_KEY
mullvad_addresses: 10.x.y.z/32
tailscale_auth_key: tskey-auth-...  # optional, for `tailscale up --auth-key`
```

4. Add to each `configuration.nix`:

```nix
imports = [ inputs.sops-nix.nixosModules.sops ];
sops.defaultSopsFile = ../secrets.yaml;
sops.age.keyFile = "/home/elias/.config/sops/age/keys.txt"; # or /etc/sops/age/keys.txt on minis
sops.secrets.mullvad_private_key.owner = "elias";
# then in systemd service:
# EnvironmentFile = config.sops.secrets.mullvad_private_key.path
```

5. On each mini, copy the same age private key to `/home/elias/.config/sops/age/keys.txt` (chmod 600) or provision via manual `scp`.

For now, skip this and use `.env` — you can migrate when the homelab is stable. Tailscale auth keys can also just be pasted once via `sudo tailscale up` interactively and you never need to store them.

## What not to commit

- `hosts/mini/*/stacks/*/.env`
- `hosts/mini/secrets.yaml` (if you use sops, commit the encrypted version — it's safe — but not the plaintext)
- `hosts/nixos/hardware-configuration.nix` (already gitignored, example is `*.example`)
- Any `*.age` private keys
