{ ... }:
{
  home.file.".hammerspoon/init.lua".text = ''
    -- Hammerspoon — reload sketchybar on display change, hyper+R reload
    hs.hotkey.bind({"cmd","ctrl"}, "r", function() hs.reload() end)
    hs.screen.watcher.new(function()
      os.execute("sketchybar --reload &")
    end):start()
    hs.alert.show("Hammerspoon loaded — navy rice", 1)
  '';
}
