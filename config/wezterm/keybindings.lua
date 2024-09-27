local wezterm = require 'wezterm'
local act = wezterm.action

-- SUPER = CMD
return {
  keys = {
    -- [CMD + SHIFT + r] Reload Configuration
    {
        key = 'r',
        mods = 'SUPER|SHIFT',
        action = wezterm.action.ReloadConfiguration,
    },
    -- [CMD + p] Command Palette
    {
      key = 'p',
      mods = 'SUPER',
      action = act.ActivateCommandPalette
    },
    -- [CMD + q] QuitApplication
    {
      key = 'q',
      mods = 'SUPER',
      action = act.QuitApplication
    },
    -- [CMD + c] Copy
    {
      key = 'c',
      mods = 'SUPER',
      action = act.CopyTo("Clipboard")
    },
    -- [CMD + v] Paste
    {
      key = 'v',
      mods = 'SUPER',
      action = act.PasteFrom("Clipboard")
    },
    -- [CTRL + Tab] Next Tab
    {
      key = 'Tab',
      mods = 'CTRL',
      action = act.ActivateTabRelative(1)
    },
    -- [CTRL + SHIFT + Tab] Previous Tab
    {
      key = 'Tab',
      mods = 'CTRL|SHIFT',
      action = act.ActivateTabRelative(-1)
    },
    -- [CMD + t] New Tab
    {
      key = 't',
      mods = 'SUPER',
      action = act({ SpawnTab = "CurrentPaneDomain" })
    },
    -- [CMD + w]
    {
      key = 'w',
      mods = 'SUPER',
      action = act.CloseCurrentTab { confirm = true }
    },
    -- [CTRL + a, s] Split Vertical
    {
      key = 's',
      mods = 'LEADER',
      action = act.SplitVertical { domain = 'CurrentPaneDomain' }
    },
    -- [CTRL + a, v] Split Horizontal
    {
      key = 'v',
      mods = 'LEADER',
      action = act.SplitHorizontal { domain = 'CurrentPaneDomain' }
    },
    -- [CTRL + a, w] Select Next Pane
    {
      key = 'w',
      mods = 'LEADER',
      action = act.ActivatePaneDirection "Next"
    },
    -- [CMD + w] Close Tab
    {
      key = 'w',
      mods = 'SUPER',
      action = act.CloseCurrentTab { confirm = true },
    },
    -- [CTRL + w] Close Pane
    {
      key = 'w',
      mods = 'CTRL',
      action = act.CloseCurrentPane { confirm = true },
    },
  }
}
