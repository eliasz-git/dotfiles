{ ... }:

{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        padding = { top = 1; left = 2; right = 2; };
        color = { "1" = "blue"; "2" = "cyan"; };
      };
      display = {
        separator = " → ";
        color = { keys = "blue"; title = "cyan"; };
      };
      modules = [
        {
          type = "title";
          format = "{user-name}@{host-name}";
        }
        {
          type = "separator";
          string = "─";
        }
        
        {
          type = "custom";
          format = "󰍛 HARDWARE";
        }
        {
          type = "host";
          key = "  Host";
        }
        {
          type = "cpu";
          key = "  CPU";
        }
        {
          type = "gpu";
          key = "  GPU";
        }
        {
          type = "memory";
          key = "  Memory";
        }
        {
          type = "disk";
          key = "  Disk";
        }
        {
          type = "battery";
          key = "  Battery";
        }
        
        {
          type = "separator";
          string = "─";
        }

        {
          type = "custom";
          format = " SOFTWARE";
        }
        {
          type = "os";
          key = "  OS";
        }
        {
          type = "kernel";
          key = "  Kernel";
        }
        {
          type = "packages";
          key = "  Packages";
        }
        {
          type = "shell";
          key = "  Shell";
        }
        
        {
          type = "separator";
          string = "─";
        }

        {
          type = "custom";
          format = " DESKTOP";
        }
        {
          type = "de";
          key = "  DE";
        }
        {
          type = "wm";
          key = "  WM";
        }
        {
          type = "wmtheme";
          key = "  Theme";
        }
        {
          type = "terminal";
          key = "  Terminal";
        }
        {
          type = "terminalfont";
          key = "  Font";
        }
        
        {
          type = "separator";
          string = "─";
        }

        {
          type = "custom";
          format = "󰥔 SYSTEM";
        }
        {
          type = "uptime";
          key = "  Uptime";
        }
        {
          type = "localip";
          key = "  Local IP";
        }
        
        {
          type = "separator";
          string = "─";
        }
        {
          type = "colors";
          paddingLeft = 2;
          symbol = "circle";
        }
      ];
    };
  };
}