# Nix Config Repository Overhaul Plan

**Status:** In progress; baseline, validation, operations, and repository documentation slices implemented; no system activation implied
**Scope:** Make this repository reliable to evaluate, understandable to maintain, and safe to deploy across macOS, NixOS desktop/laptop hosts, headless minis, and the Beattie showcase. Preserve the distinct role of each machine.

## Executive recommendation

Do **not** start with a wholesale directory rewrite or a migration to `flake-parts`. First establish a trustworthy baseline and validation gate, then repair the theme system—which currently has competing sources of truth—and improve host-aware operations. Keep host outputs explicit and keep Hyprland in the existing modular hyprlang/Home Manager setup. Refactor only where repeated code or a demonstrated maintenance problem justifies it.

Treat the existing [Omarchy alignment plan](./docs/OMARCHY_ALIGNMENT_PLAN.md) as a desktop-feature workstream within this broader repository plan, not as a mandate to make servers into desktops or to copy Omarchy's implementation literally.

## Current-state snapshot

The repository currently defines these principal outputs in `flake.nix`:

- **nix-darwin:** `macbook`
- **NixOS:** `laptop`, `mini1`, `mini2`, `beattie`, `gaming-pc`
- **Standalone Home Manager:** `mini1`, `mini2`

There are also `hosts/alpine` files but no clearly corresponding Alpine output in the flake; the top-level README still describes Artix/OpenRC and older machine/software assumptions. The mini documentation had conflict markers, now removed, but should be checked against actual outputs and install procedures.

Important findings that should drive the order of work:

1. The checked-out branch has a substantial set of **uncommitted changes**, including gaming, theme, Mac, scripts, lockfile, and CI work. These are user work: do not reset, clean, or silently overwrite them. Begin implementation by inventorying and classifying this diff.
2. CI currently attempts to build only `gaming-pc`; other system and Home Manager outputs are not covered by an equivalent gate.
3. Theme data and behavior are spread across `modules/system/themes.nix`, `modules/shared/themes.nix`, `modules/home/themes.nix`, host-specific Nix files, and scripts. The Nix theme option is not consistently the source for the actual app configuration. The theme CLI expects local theme files that are not reliably installed, and the generated theme-file format should be verified before use. `refresh-theme.sh` also hard-codes a different theme and writes files that Home Manager may own.
4. There are overlapping management paths: `tundra-cli.sh`, `tundra-apply-theme.sh`, `refresh-theme.sh`, `rebuild.sh`, host aliases, and direct rebuild commands. Some operations mutate Nix profiles or run cleanup rather than changing the declared host configuration.
5. The top-level README, the Omarchy plan, and host docs describe different generations of the config. Rebuild scripts also have host-detection and action semantics that should be tested before being treated as the supported interface.
6. The minis are intentionally headless. They should inherit appropriate shared shell/Fastfetch improvements, but not desktop modules. The MacBook uses AeroSpace, Ghostty, and SketchyBar rather than Linux-only Hyprland/Waybar/Foot components.

## Non-negotiable guardrails

- Preserve the current working tree and all host-specific hardware configuration; classify changes before editing. No blanket `git clean`, reset, or bulk reformat.
- Keep system activation separate from building. Build and inspect each target first; activate one host at a time with a known rollback path.
- Do not run `nix flake update` as an incidental part of a routine rebuild. Lockfile updates are reviewed changes and must pass the full validation matrix.
- Keep secrets out of Nix source, Git history, logs, and generated docs. Use the existing external secret conventions until a deliberate secrets migration is approved.
- Treat package ownership consistently: decide whether a package belongs to NixOS/nix-darwin, Home Manager, Homebrew, or the base OS. Avoid two managers claiming the same file or application.
- Keep the host roles intact: Mac laptop/desktop, NixOS gaming PC, NixOS laptop, headless infra/media minis, and Beattie GNOME showcase.
- Prefer a small explicit abstraction over a clever universal host factory. Do not introduce a new framework unless it materially reduces duplication without obscuring evaluation.

## Work plan

### Phase 0 — Establish a safe baseline

**Purpose:** Know what is already intended and what currently works before changing architecture.

- Inventory every tracked and untracked change, including the current lockfile and `.github` workflow. Group changes by host, shared module, operation/script, and documentation; preserve all of them.
- For each host, record the current source revision, declared flake output, machine role, architecture, active generation where observable, and last known successful build/activation. Keep host state separate; do not infer that a successful gaming build proves the Mac or minis are valid.
- Reconcile host names across `flake.nix`, scripts, shell aliases, install scripts, and docs. Confirm whether `hosts/alpine` is retired, standalone-only, or needs a supported output.
- Establish reproducible baseline checks for the current dirty tree before reorganizing it.

**Exit gate:** A reviewed host/output inventory and a classified diff; no user changes discarded; current known-good generations and rollback commands documented.

### Phase 1 — Add a real validation gate

**Purpose:** Catch broken outputs and generated configuration before they reach hardware.

- Expand CI beyond `gaming-pc`: evaluate/build all NixOS outputs and Home Manager outputs; add a Darwin evaluation/build lane on a suitable macOS runner or an explicit Darwin evaluation lane where cross-building is unavailable.
- Add formatting and static checks for Nix and shell scripts. Select and pin tools such as `nixfmt`/`alejandra`, `statix`, `deadnix`, and `shellcheck` only after checking compatibility with this repo; make formatter choice singular and documented.
- Add tests for generated configuration artifacts: JSON, RASI, Foot INI, shell syntax, and host-specific config generation. Test behavior rather than only parsing source `.nix` files.
- Run `nix flake check` where outputs support it, and explicit `nix eval`/build targets for outputs it does not cover. CI should report the failing host/output clearly.
- Add a lightweight secret and repository hygiene scan, plus checks against conflict markers and stale generated files.

**Exit gate:** A clean PR receives a clear pass/fail result for each supported output and each selected formatter/linter; CI performs no activation or destructive host mutation.

### Phase 2 — Make the theme system real and single-source

**Purpose:** Ensure the selected theme actually drives generated app configuration.

- Choose one canonical theme schema and registry, with validated color roles and a single selected-theme option. Retire duplicate registries after mapping all current names and palette fields.
- Keep theme selection reproducible. Prefer an explicit Nix option/host selector and rebuild-driven file generation; allow runtime IPC only for settings an app can safely reload. Do not let ad hoc scripts overwrite Home Manager-managed files.
- Replace the current theme-file lookup/parser approach with Nix-generated theme artifacts or a structured data format (for example JSON) generated from the canonical registry. Do not parse Nix with `grep`/`sed`.
- Generate per-platform consumers from the same palette: Hyprland, Waybar, Rofi, Dunst, Foot on Linux; Ghostty, SketchyBar, AeroSpace borders, Starship, Bat, and FZF on macOS; shell/Fastfetch on headless hosts. Respect platform differences rather than installing unavailable apps.
- Verify every supported theme end-to-end on one desktop host before advertising it in `tundra theme list`. Remove themes that lack correct renderers or declare them partial.
- Retire or replace `refresh-theme.sh` and `tundra-apply-theme.sh` only after their intended behavior has parity and tests. Fix the invalid/out-of-date generated Foot/Rofi configuration cases as part of this work.

**Exit gate:** Selecting a theme yields the same palette in all supported consumers, generated config parsers pass, and switching back to the previous theme is documented and testable.

### Phase 3 — Clarify module and host boundaries

**Purpose:** Reduce accidental cross-host coupling without destabilizing the flake.

- Document four layers: shared CLI/home programs, NixOS-only services, desktop environment modules, and Darwin-specific modules. State which layer owns packages and generated dotfiles.
- Keep host declarations explicit. Extract a small shared flake helper only if it reduces repeated Home Manager wiring and remains easy to debug; do not change output names during the same change as behavior.
- Audit NixOS vs Home Manager duplicates, option renames/deprecations, host-specific `specialArgs`, unfree policy, and system architecture declarations. Make package ownership explicit.
- Maintain distinct profiles: **gaming-pc** gets Hyprland/gaming; **laptop** retains its Niri role; **mini1/mini2** stay headless and service-focused; **Beattie** stays GNOME; **MacBook** keeps AeroSpace/SketchyBar.
- Treat hardware configurations as host-owned inputs. Keep placeholders/examples clearly separate from live machine files and do not copy one host's hardware config to another.

**Exit gate:** Every output evaluates independently, shared imports are intentional, and a module change has a documented list of affected hosts.

### Phase 4 — Make operations safe and predictable

**Purpose:** Provide one understandable interface without undermining declarative Nix.

- Consolidate supported user commands behind `tundra` (or keep `scripts/rebuild.sh` as a thin wrapper) and deprecate duplicate implementations after parity.
- Require an explicit host when detection is ambiguous. Current generic NixOS detection must not silently choose `gaming-pc`; hostname-to-flake mapping should be explicit and fail closed on unknown hosts.
- Separate `eval`, `build`, temporary `test`, `switch`, `boot`, `rollback`, and `update`. Explain each command and whether it affects the running system, boot profile, lockfile, or Nix profile.
- Make normal update behavior: update lockfile only when requested; show the diff; build the affected target; never silently switch all machines. Provide a separate reviewed activation step.
- Move “install/remove app” toward declarative edits or clearly label Nix-profile operations as imperative and outside the repo's source of truth. Put destructive garbage collection behind an explicit confirmation and do not couple it to rebuild.
- Add `doctor` checks for output existence, dirty tree, Nix availability, target resolution, available rollback generations, and required host services; ensure read-only checks are the default.

**Exit gate:** A dry run never mutates; unknown hosts fail without choosing another; every mutating command says exactly what it will change; rollback instructions are tested.

### Phase 5 — Finish host work in risk order

1. **Gaming PC:** Preserve the newly repaired active generation as the known-good fallback. Continue Omarchy-aligned improvements only with generated-config validation and on-hardware checks. Complete theme consumers, Waybar/notification/clipboard/screenshot behavior, and document keybindings. Do not migrate to runtime Lua unless a concrete limitation justifies it; retain modular Nix-generated hyprlang for now.
2. **MacBook:** Keep AeroSpace + SketchyBar + Ghostty + Raycast. Apply the canonical theme tokens, verify Home Manager/nix-darwin builds, audit Homebrew/Nix ownership and activation cleanup behavior, then activate independently with a tested rollback path. Do not add Wayland-only packages or services.
3. **Mini1 and mini2:** Keep headless. Validate each NixOS and Home Manager output, check service/storage/firewall/Tailscale configuration, clarify secrets and first-boot steps, and test one mini at a time. Avoid theme work beyond shared shell/Fastfetch colors.
4. **Laptop and Beattie:** Validate and document their Niri/GNOME roles; remove misleading legacy README instructions only after the maintained installation path is confirmed.

**Exit gate:** Per-host build and acceptance record, with no assumption that one host's activation proves another host.

### Phase 6 — Documentation and maintenance contract

- Replace the stale top-level README host table, installation steps, package descriptions, keybindings, and OS claims with the actual supported output matrix.
- Give each host a concise README: purpose, target output, bootstrap/rebuild command, persistent data, secrets location, validation command, and rollback command.
- Update or supersede `docs/OMARCHY_ALIGNMENT_PLAN.md` with completed/deferred items after implementation, not before. Keep “Omarchy-inspired” goals separate from non-negotiable host requirements.
- Document the lockfile update cadence, supported Nix versions, formatter/linter commands, CI checks, and emergency rollback procedure.
- Add contribution guidance for module ownership and naming only after the directory/host model is settled.

**Exit gate:** A new maintainer can identify the correct output and make a safe build without relying on outdated README claims or undocumented shell aliases.

## Suggested first milestones

1. **Baseline report:** classify the existing dirty tree and reconcile supported outputs/docs; no source refactor.
2. **Validation PR:** broaden CI and add formatter/static checks, without changing host behavior.
3. **Theme correctness PR:** canonical palette + generated config + parser tests, starting with the already-used Catppuccin Mocha theme.
4. **CLI/rebuild PR:** explicit host mapping, safe build/switch separation, and rollback-oriented help.
5. **Host-by-host documentation and polish:** MacBook, minis, laptop, Beattie, and gaming PC in separate reviewable chunks.

Keep each milestone small enough to build and review independently. Do not combine lockfile updates, host renames, module moves, and runtime behavior changes in one PR.

## Definition of done

- All supported outputs are listed once and have passing evaluation/build checks.
- CI detects format, static-analysis, generated-config, and host-evaluation failures before activation.
- Theme names, palette definitions, and generated app themes have one authoritative source.
- Shared modules are platform-safe; headless minis remain headless.
- Rebuild/update commands resolve the intended host explicitly and have clear non-activating and rollback paths.
- Current README and per-host docs match the flake and actual ownership of persistent data/secrets.
- Each deployed host has an independently validated result and a known-good rollback generation.
