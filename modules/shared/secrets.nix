{ config, lib, pkgs, ... }:

# Encrypted secrets live in secrets/*.age and are decrypted per-host by
# agenix's Home Manager module (imported from the flake). That module is pure
# user-space: it writes plaintext into the session runtime dir
# ($XDG_RUNTIME_DIR/agenix on Linux, $(getconf DARWIN_USER_TEMP_DIR)/agenix on
# macOS) and symlinks it to `path`. Nothing lands in the Nix store, so there is
# no plaintext derivation to garbage collect or copy between machines.
#
# Every host needs an age identity. These are encrypted to ~/.ssh/id_ed25519
# (the macbook key), so that private key has to exist on any host that enables
# a secret or agenix will warn and fail to decrypt.

{
  # Disabled by default: a host opts in by setting
  # `age.secrets.<name>.enable = true;`, so hosts that do not need a credential
  # neither get the launchd/systemd decrypt agent nor a dangling symlink.
  # mkDefault so the host's opt-in is a plain assignment rather than mkForce.
  age.secrets."lastfm-password" = {
    file = ../../secrets/lastfm-password.age;
    path = "${config.home.homeDirectory}/.config/mpdscribble/lastfm-password";
    mode = "0400";
    enable = lib.mkDefault false;
  };

  age.verbosity = lib.mkDefault "summary";

  # agenix's macOS module points its launchd agent at
  # ~/Library/Logs/agenix/{stdout,stderr}. launchd will not create that directory,
  # and Home Manager has no option for an empty dir, so make it before the agent
  # is loaded or the job dies on a missing log path.
  home.activation.agenixLogDir = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
    lib.hm.dag.entryBefore [ "setupLaunchAgents" ] ''
      mkdir -p "$HOME/Library/Logs/agenix"
    ''
  );
}
