local wezterm = require 'wezterm'
local act = wezterm.action

return {
  keys = {
    -- [ctrl + a, s] Split Vertical
    {
      key = 's',
      mods = 'LEADER',
      action = act.SplitVertical { domain = 'CurrentPaneDomain' }
    },
    -- [ctrl + a, v] Split Horizontal
    {
      key = 'v',
      mods = 'LEADER',
      action = act.SplitHorizontal { domain = 'CurrentPaneDomain' }
    },
    -- [ctrl + a, w] Select Next Pane
    {
      key = 'w',
      mods = 'LEADER',
      action = act.ActivatePaneDirection "Next"
    },
    -- [cmd + w] Close Tab
    {
      key = 'w',
      mods = 'CMD',
      action = act.CloseCurrentTab { confirm = true },
    },
    -- [ctrl + w] Close Pane
    {
      key = 'w',
      mods = 'CTRL',
      action = act.CloseCurrentPane { confirm = true },
    },
  }
}
