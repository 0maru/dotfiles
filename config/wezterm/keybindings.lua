local wezterm = require 'wezterm'
local act = wezterm.action

-- SUPER = CMD
local keys = {
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
    -- [CMD + w] Close Tab
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
    -- [CTRL + a, ;] Select Next Pane
    {
      key = ';',
      mods = 'LEADER',
      action = act.ActivatePaneDirection 'Next'
    },
    -- [CTRL + w] Close Pane
    {
      key = 'w',
      mods = 'CTRL',
      action = act.CloseCurrentPane { confirm = true },
    },
    -- [LEADER + z] Toggle Pane Zoom
    {
      key = 'z',
      mods = 'LEADER',
      action = act.TogglePaneZoomState
    },
    -- [LEADER + h/j/k/l] Pane Direction Navigation
    {
      key = 'h',
      mods = 'LEADER',
      action = act.ActivatePaneDirection 'Left'
    },
    {
      key = 'j',
      mods = 'LEADER',
      action = act.ActivatePaneDirection 'Down'
    },
    {
      key = 'k',
      mods = 'LEADER',
      action = act.ActivatePaneDirection 'Up'
    },
    {
      key = 'l',
      mods = 'LEADER',
      action = act.ActivatePaneDirection 'Right'
    },
    -- [LEADER + SHIFT + h/j/k/l] Pane Resize
    {
      key = 'H',
      mods = 'LEADER|SHIFT',
      action = act.AdjustPaneSize { 'Left', 5 }
    },
    {
      key = 'J',
      mods = 'LEADER|SHIFT',
      action = act.AdjustPaneSize { 'Down', 5 }
    },
    {
      key = 'K',
      mods = 'LEADER|SHIFT',
      action = act.AdjustPaneSize { 'Up', 5 }
    },
    {
      key = 'L',
      mods = 'LEADER|SHIFT',
      action = act.AdjustPaneSize { 'Right', 5 }
    },
    -- [LEADER + [] Copy Mode
    {
      key = '[',
      mods = 'LEADER',
      action = act.ActivateCopyMode
    },
    -- [CMD + e] Tab Navigator (fuzzy tab switcher)
    {
      key = 'e',
      mods = 'SUPER',
      action = act.ShowTabNavigator
    },
    -- [CTRL + L] Debug Overlay
    {
      key = 'L',
      mods = 'CTRL',
      action = wezterm.action.ShowDebugOverlay
    },
    -- [SHIFT + ENTER] SendString "\x1b\r"
    -- Claude Code の改行
    {
      key="Enter",
      mods="SHIFT",
      action=wezterm.action{SendString="\x1b\r"}
    },
}

-- [CMD + 1-9] Active Tab 1-9
for i = 1, 9 do
  table.insert(keys, {
    key = tostring(i),
    mods = 'SUPER',
    action = act.ActivateTab(i - 1)
  })
end

return { keys = keys }
