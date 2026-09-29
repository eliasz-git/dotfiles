{ config, lib, pkgs, ... }:

let
  # Theme Definitions
  themes = {
    catppuccin-mocha = { name = "Catppuccin Mocha"; background = "#1e1e2e"; surface = "#181825"; overlay = "#313244"; primary = "#89b4fa"; secondary = "#f5c2e7"; accent = "#fab387"; success = "#a6e3a1"; warning = "#f9e2af"; error = "#f38ba8"; text = "#cdd6f4"; subtext = "#a6adc8"; border = "#313244"; };
    catppuccin-latte = { name = "Catppuccin Latte"; background = "#eff1f5"; surface = "#e6e9ef"; overlay = "#ccd0da"; primary = "#1e66f5"; secondary = "#ea76cb"; accent = "#fe640b"; success = "#40a02b"; warning = "#df8e1d"; error = "#d20f39"; text = "#4c4f69"; subtext = "#6c6f85"; border = "#ccd0da"; };
    catppuccin-frappe = { name = "Catppuccin Frappé"; background = "#303446"; surface = "#292c3c"; overlay = "#414559"; primary = "#8caaee"; secondary = "#f4b8e4"; accent = "#e78284"; success = "#a6d189"; warning = "#e5c890"; error = "#e78284"; text = "#c6d0f5"; subtext = "#949cbb"; border = "#414559"; };
    catppuccin-macchiato = { name = "Catppuccin Macchiato"; background = "#24273a"; surface = "#1e2030"; overlay = "#363a4f"; primary = "#8aadf4"; secondary = "#f5bde6"; accent = "#f5a97f"; success = "#a6da95"; warning = "#eed49f"; error = "#ed8796"; text = "#cad3f5"; subtext = "#939ab7"; border = "#363a4f"; };
    gruvbox-dark = { name = "Gruvbox Dark"; background = "#282828"; surface = "#1d2021"; overlay = "#3c3836"; primary = "#83a598"; secondary = "#d3869b"; accent = "#fe8019"; success = "#b8bb26"; warning = "#fabd2f"; error = "#fb4934"; text = "#ebdbb2"; subtext = "#a89984"; border = "#3c3836"; };
    gruvbox-light = { name = "Gruvbox Light"; background = "#fbf1c7"; surface = "#f2e5bc"; overlay = "#ebdbb2"; primary = "#076678"; secondary = "#b16286"; accent = "#af3a03"; success = "#427b58"; warning = "#b57614"; error = "#9d0006"; text = "#282828"; subtext = "#665c54"; border = "#ebdbb2"; };
    nord = { name = "Nord"; background = "#2e3440"; surface = "#3b4252"; overlay = "#434c5e"; primary = "#88c0d0"; secondary = "#b48ead"; accent = "#ebcb8b"; success = "#a3be8c"; warning = "#ebcb8b"; error = "#bf616a"; text = "#eceff4"; subtext = "#d8dee9"; border = "#434c5e"; };
    tokyo-night = { name = "Tokyo Night"; background = "#1a1b26"; surface = "#16161e"; overlay = "#24283b"; primary = "#7aa2f7"; secondary = "#bb9af7"; accent = "#ff9e64"; success = "#9ece6a"; warning = "#e0af68"; error = "#f7768e"; text = "#c0caf5"; subtext = "#a9b1d6"; border = "#24283b"; };
    tokyo-night-storm = { name = "Tokyo Night Storm"; background = "#24283b"; surface = "#1f2335"; overlay = "#292e42"; primary = "#7aa2f7"; secondary = "#bb9af7"; accent = "#ff9e64"; success = "#9ece6a"; warning = "#e0af68"; error = "#f7768e"; text = "#c0caf5"; subtext = "#a9b1d6"; border = "#292e42"; };
    tokyo-night-day = { name = "Tokyo Night Day"; background = "#e1e2e7"; surface = "#fafafa"; overlay = "#e1e2e7"; primary = "#2e7de9"; secondary = "#8839ef"; accent = "#b65611"; success = "#587539"; warning = "#8c6c3e"; error = "#c64343"; text = "#3760bf"; subtext = "#545c7e"; border = "#e1e2e7"; };
    kanagawa-wave = { name = "Kanagawa Wave"; background = "#1f1f28"; surface = "#181616"; overlay = "#363646"; primary = "#7e9cd8"; secondary = "#957fb8"; accent = "#ff9e3b"; success = "#98bb6c"; warning = "#e6c384"; error = "#c34043"; text = "#dcd7ba"; subtext = "#727169"; border = "#363646"; };
    kanagawa-dragon = { name = "Kanagawa Dragon"; background = "#181616"; surface = "#0d0c0c"; overlay = "#282727"; primary = "#7e9cd8"; secondary = "#957fb8"; accent = "#ff9e3b"; success = "#98bb6c"; warning = "#e6c384"; error = "#c34043"; text = "#dcd7ba"; subtext = "#727169"; border = "#282727"; };
    kanagawa-lotus = { name = "Kanagawa Lotus"; background = "#fefaf0"; surface = "#faf5eb"; overlay = "#f2ecbc"; primary = "#2d4f67"; secondary = "#6b4d6f"; accent = "#b85b2b"; success = "#4e8036"; warning = "#a36400"; error = "#b83040"; text = "#54546d"; subtext = "#7c7c9c"; border = "#f2ecbc"; };
    rose-pine = { name = "Rose Pine"; background = "#191724"; surface = "#1f1d2e"; overlay = "#26233a"; primary = "#ebbcba"; secondary = "#f6c177"; accent = "#eb6f92"; success = "#31748f"; warning = "#f6c177"; error = "#eb6f92"; text = "#e0def4"; subtext = "#908caa"; border = "#26233a"; };
    rose-pine-moon = { name = "Rose Pine Moon"; background = "#232136"; surface = "#1f1d2e"; overlay = "#26233a"; primary = "#ebbcba"; secondary = "#f6c177"; accent = "#eb6f92"; success = "#31748f"; warning = "#f6c177"; error = "#eb6f92"; text = "#e0def4"; subtext = "#908caa"; border = "#26233a"; };
    rose-pine-dawn = { name = "Rose Pine Dawn"; background = "#faf4ed"; surface = "#fffaf3"; overlay = "#f2e9e1"; primary = "#907aa9"; secondary = "#d7827e"; accent = "#a84c8a"; success = "#286983"; warning = "#d7827e"; error = "#a84c8a"; text = "#575279"; subtext = "#9893a5"; border = "#f2e9e1"; };
    everforest-dark = { name = "Everforest Dark"; background = "#2d353b"; surface = "#272e33"; overlay = "#3d464d"; primary = "#7fbbb3"; secondary = "#d699b6"; accent = "#e69875"; success = "#a7c080"; warning = "#dbbc7f"; error = "#e67e80"; text = "#d3c6aa"; subtext = "#a7a89c"; border = "#3d464d"; };
    everforest-light = { name = "Everforest Light"; background = "#fdf6e3"; surface = "#f5eeda"; overlay = "#eddec9"; primary = "#47a09a"; secondary = "#c67096"; accent = "#c87a54"; success = "#7fa06e"; warning = "#b8974c"; error = "#cc6e73"; text = "#5c6a72"; subtext = "#8a8c7f"; border = "#eddec9"; };
    flexoki-dark = { name = "Flexoki Dark"; background = "#1c1b1a"; surface = "#100f0f"; overlay = "#343331"; primary = "#4385be"; secondary = "#ce5d97"; accent = "#d14d72"; success = "#57ab5a"; warning = "#eda94a"; error = "#f07878"; text = "#cecdcc"; subtext = "#a9a8a6"; border = "#343331"; };
    flexoki-light = { name = "Flexoki Light"; background = "#f2f0ec"; surface = "#fffcf7"; overlay = "#e6e4df"; primary = "#105c9c"; secondary = "#a02f6f"; accent = "#a02f6f"; success = "#358239"; warning = "#b2691d"; error = "#c93939"; text = "#343331"; subtext = "#575653"; border = "#e6e4df"; };
    matte-black = { name = "Matte Black"; background = "#0d0d0d"; surface = "#0a0a0a"; overlay = "#1a1a1a"; primary = "#00d7ff"; secondary = "#ff6b9d"; accent = "#ffcc00"; success = "#00ff88"; warning = "#ffcc00"; error = "#ff4444"; text = "#ffffff"; subtext = "#888888"; border = "#333333"; };
    miasma = { name = "Miasma"; background = "#1a1a2e"; surface = "#161625"; overlay = "#2a2a4a"; primary = "#00ffff"; secondary = "#ff00ff"; accent = "#ffff00"; success = "#00ff00"; warning = "#ffff00"; error = "#ff0000"; text = "#e0e0e0"; subtext = "#8080a0"; border = "#3a3a5a"; };
    solitude = { name = "Solitude"; background = "#0f0f1a"; surface = "#0a0a12"; overlay = "#1e1e30"; primary = "#60a0ff"; secondary = "#ff60a0"; accent = "#ffcc00"; success = "#60ff60"; warning = "#ffcc00"; error = "#ff4040"; text = "#d0d0e0"; subtext = "#707090"; border = "#2e2e40"; };
    ristretto = { name = "Ristretto"; background = "#151515"; surface = "#101010"; overlay = "#252525"; primary = "#ff8800"; secondary = "#ff4444"; accent = "#ffcc00"; success = "#88cc00"; warning = "#ffcc00"; error = "#ff4444"; text = "#eeeeee"; subtext = "#888888"; border = "#333333"; };
    osaka-jade = { name = "Osaka Jade"; background = "#0d1a15"; surface = "#08120e"; overlay = "#1a2a22"; primary = "#00ff88"; secondary = "#ff88cc"; accent = "#ffcc00"; success = "#00ff88"; warning = "#ffcc00"; error = "#ff4444"; text = "#cceecc"; subtext = "#668877"; border = "#2a3a32"; };
    last-horizon = { name = "Last Horizon"; background = "#0a0f1a"; surface = "#050812"; overlay = "#1a2230"; primary = "#00aaff"; secondary = "#ff66aa"; accent = "#ffcc00"; success = "#00ff88"; warning = "#ffcc00"; error = "#ff4444"; text = "#cceeff"; subtext = "#6688aa"; border = "#1a2a3a"; };
    lupine = { name = "Lupine"; background = "#1a0a1a"; surface = "#120512"; overlay = "#2a1a2a"; primary = "#cc88ff"; secondary = "#ff88cc"; accent = "#ffcc00"; success = "#88ff88"; warning = "#ffcc00"; error = "#ff4444"; text = "#eeccff"; subtext = "#aa77aa"; border = "#3a2a3a"; };
    hackerman = { name = "Hackerman"; background = "#000000"; surface = "#000000"; overlay = "#0a0a0a"; primary = "#00ff00"; secondary = "#ff00ff"; accent = "#ffff00"; success = "#00ff00"; warning = "#ffff00"; error = "#ff0000"; text = "#00ff00"; subtext = "#00aa00"; border = "#003300"; };
    ethereal = { name = "Ethereal"; background = "#f5f0ff"; surface = "#ede8f5"; overlay = "#e0d8ea"; primary = "#8866cc"; secondary = "#cc66aa"; accent = "#ccaa00"; success = "#66cc66"; warning = "#ccaa00"; error = "#cc4444"; text = "#443355"; subtext = "#887799"; border = "#d0c8e0"; };
    lumon = { name = "Lumon"; background = "#fafafa"; surface = "#f0f0f0"; overlay = "#e0e0e0"; primary = "#0066cc"; secondary = "#cc3366"; accent = "#cc9900"; success = "#339933"; warning = "#cc9900"; error = "#cc3333"; text = "#222222"; subtext = "#666666"; border = "#cccccc"; };
    retro-82 = { name = "Retro 82"; background = "#1a0a2a"; surface = "#12051e"; overlay = "#2a1a3a"; primary = "#00ffff"; secondary = "#ff00ff"; accent = "#ffff00"; success = "#00ff00"; warning = "#ffff00"; error = "#ff0000"; text = "#e0e0ff"; subtext = "#8888aa"; border = "#3a2a4a"; };
  };

  # Generate theme files - use Python to avoid Nix escaping issues
  # Write themes JSON to temp file, then use Python to generate nix theme files
  generateThemeFiles = pkgs.runCommand "tundra-themes" {
    themesJson = builtins.toJSON themes;
    nativeBuildInputs = [ pkgs.python3 ];
  } ''
    mkdir -p /share/tundra/themes
    # Write themes JSON to temp file
    echo "" > /tmp/tundra_themes_input.json
    # Generate nix theme files using Python
    python3 /home/elias/.config/nix-config/scripts/gen_themes.py
  '';

in {
  options.tundra = {
    enable = lib.mkEnableOption "Tundra theme system";
    theme = lib.mkOption {
      type = lib.types.str;
      default = "catppuccin-mocha";
      description = "Current theme name";
    };
    themes = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({ ... }: {
        options = {
          name = lib.mkOption { type = lib.types.str; };
          background = lib.mkOption { type = lib.types.str; };
          surface = lib.mkOption { type = lib.types.str; };
          overlay = lib.mkOption { type = lib.types.str; };
          primary = lib.mkOption { type = lib.types.str; };
          secondary = lib.mkOption { type = lib.types.str; };
          accent = lib.mkOption { type = lib.types.str; };
          success = lib.mkOption { type = lib.types.str; };
          warning = lib.mkOption { type = lib.types.str; };
          error = lib.mkOption { type = lib.types.str; };
          text = lib.mkOption { type = lib.types.str; };
          subtext = lib.mkOption { type = lib.types.str; };
          border = lib.mkOption { type = lib.types.str; };
        };
      }));\n
      default = themes;
      description = "Theme definitions";
    };
  };

  # System-level config (NixOS + nix-darwin)
  config = lib.mkIf config.tundra.enable {
    # Install theme switcher system-wide
    environment.systemPackages = [ themeSwitcher ];
    # Generate theme files to nix store
    environment.etc."tundra/themes".source = generateThemeFiles;
  };
}
