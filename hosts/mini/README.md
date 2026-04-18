This directory contains per-host Home Manager modules and install scripts for the two HP ProDesk mini hosts.

Hosts:
- mini/1 — HP ProDesk 600 G1 DM (Intel i3-4160T) — headless server
  - Files:
    - home.nix
    - install.sh
  - Brief install steps (run as the local user with doas/sudo):
    1. On the target machine, clone your config to ~/.config/nix-config if not already present.
    2. Make the installer executable: chmod +x ~/.config/nix-config/hosts/mini/1/install.sh
    3. Run the installer: bash ~/.config/nix-config/hosts/mini/1/install.sh
    4. After the script finishes, run: home-manager switch --flake ~/.config/nix-config#mini1
    5. Verify docker service is running: doas rc-service docker status

- mini/2 — HP ProDesk 405 G4 DM (AMD Ryzen 5 PRO 2400GE, Vega) — desktop + light gaming
  - Files:
    - home.nix
    - install.sh
  - Brief install steps (run as the local user):
    1. On the target Artix machine, clone your config to ~/.config/nix-config if not already present.
    2. Make the installer executable: chmod +x ~/.config/nix-config/hosts/mini/2/install.sh
    3. Run the installer: bash ~/.config/nix-config/hosts/mini/2/install.sh [username]
       - The script defaults to username "elias" if not provided.
    4. After the script finishes, run: home-manager switch --flake ~/.config/nix-config#mini2
    5. If you installed AUR packages, verify yay installed them: yay -Qs ollama-rocm steam

Notes / Safety:
- I updated flake.nix to register both homeConfigurations.mini1 and mini2. Home Manager flakes will reference those names.
- The install scripts are conservative scaffolds derived from the alpine/artix scripts. Review them before running as root.
- Replace the placeholder userEmail in each home.nix (programs.git.userEmail) with your real email.
- I did not push changes to the remote by default — tell me to push and I'll push the commits to origin/main.
