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
    -- [CMD + f] serch
    {
      key = 'f',
      mods = 'SUPER',
      action = act.Search{ CaseSensitiveString='' }
    },
    -- [CMD + c] Copy
    {
      key = 'c',
      mods = 'SUPER',
      action = act.CopyTo('Clipboard')
    },
    -- [CMD + v] Paste
    {
      key = 'v',
      mods = 'SUPER',
      action = act.PasteFrom('Clipboard')
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
      action = act({ SpawnTab = 'CurrentPaneDomain' })
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
      action = act.ActivatePaneDirection 'Next'
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
    -- [CMD + 1] Active Tab 1
    {
      key = '1',
      mods = 'SUPER',
      action = act.ActivateTab(0)
    },
    -- [CMD + 2] Active Tab 2
    {
      key = '2',
      mods = 'SUPER',
      action = act.ActivateTab(1)
    },
    -- [CMD + 3] Active Tab 3
    {
      key = '3',
      mods = 'SUPER',
      action = act.ActivateTab(2)
    },
    -- [CMD + 4] Active Tab 4
    {
      key = '4',
      mods = 'SUPER',
      action = act.ActivateTab(3)
    },
    -- [CMD + 5] Active Tab 5
    {
      key = '5',
      mods = 'SUPER',
      action = act.ActivateTab(4)
    },
    -- [CMD + 6] Active Tab 6
    {
      key = '6',
      mods = 'SUPER',
      action = act.ActivateTab(5)
    },
    -- [CMD + 7] Active Tab 7
    {
      key = '7',
      mods = 'SUPER',
      action = act.ActivateTab(6)
    },
    -- [CMD + 8] Active Tab 8
    {
      key = '8',
      mods = 'SUPER',
      action = act.ActivateTab(7)
    },
    -- [CMD + 9] Active Tab 9
    {
      key = '9',
      mods = 'SUPER',
      action = act.ActivateTab(8)
    }
  }
}
