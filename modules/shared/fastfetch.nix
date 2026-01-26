  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "medium";
        padding = {
          top = 1;
          left = 2;
          right = 2;
        };
        color = {
          "1" = "green";
          "2" = "cyan";
        };
      };
      display = {
        separator = " → ";
        color = {
          keys = "green";
          title = "cyan";
        };
      };
      modules = [
        # Title and separator
        {
          type = "title";
          format = "{user-name}@{host-name}";
        }
        {
          type = "separator";
          string = "─";
        }
        
        # Hardware Section
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
        
        # Separator
        {
          type = "separator";
          string = "─";
        }
        
        # Software Section
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
        
        # Separator
        {
          type = "separator";
          string = "─";
        }
        
        # Desktop Section
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
        
        # Separator
        {
          type = "separator";
          string = "─";
        }
        
        # System Section
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
        
        # Color palette
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