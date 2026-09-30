#!/usr/bin/env bash
# Environment exports for Darwin (Nix-managed) — place or source this file from your Nix profile
# Provides bun path and disables oh-my-opencode telemetry

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export OMO_SEND_ANONYMOUS_TELEMETRY=0
export OMO_DISABLE_POSTHOG=1
export TERM="${TERM:-xterm-256color}"
