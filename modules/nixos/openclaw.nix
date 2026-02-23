programs.openclaw = {
  enable = true;
  settings = {
    gateway = {
      mode = "local";
      bind = "loopback";
    };
    agents.defaults.model.primary = "github-copilot/gpt-5-mini";
  };
};