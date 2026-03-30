local wezterm = require('wezterm')
local act = wezterm.action

local M = {}

local SHELL = os.getenv('SHELL') or '/bin/zsh'

-- Helper: spawn a command as an overlay pane (split + zoom)
local function spawn_overlay_pane(command)
  return wezterm.action_callback(function(window, pane)
    local new_pane = pane:split({ direction = 'Bottom', size = 1.0,
                                  args = { SHELL, '-lc', command } })
    window:perform_action(act.TogglePaneZoomState, new_pane)
  end)
end

-- Helper: set pane height to a percentage of the tab
local function set_pane_height_percent(percent)
  return wezterm.action_callback(function(window, pane)
    local tab = window:active_tab()
    local tab_size = tab:get_size()
    local total_rows = tab_size.rows

    local pane_info = nil
    for _, info in ipairs(tab:panes_with_info()) do
      if info.pane:pane_id() == pane:pane_id() then
        pane_info = info
        break
      end
    end
    if not pane_info then return end

    local current_rows = pane_info.pixel_height / tab_size.pixel_height * total_rows
    local target_rows = math.floor(total_rows * percent / 100)
    local delta = target_rows - math.floor(current_rows)

    if delta ~= 0 then
      local direction = pane_info.top == 0 and 'Down' or 'Up'
      window:perform_action(act.AdjustPaneSize { direction, math.abs(delta) }, pane)
    end
  end)
end

-- Helper: set pane width to a percentage of the tab
local function set_pane_width_percent(percent)
  return wezterm.action_callback(function(window, pane)
    local tab = window:active_tab()
    local tab_size = tab:get_size()
    local total_cols = tab_size.cols

    local pane_info = nil
    for _, info in ipairs(tab:panes_with_info()) do
      if info.pane:pane_id() == pane:pane_id() then
        pane_info = info
        break
      end
    end
    if not pane_info then return end

    local current_cols = pane_info.pixel_width / tab_size.pixel_width * total_cols
    local target_cols = math.floor(total_cols * percent / 100)
    local delta = target_cols - math.floor(current_cols)

    if delta ~= 0 then
      local direction = pane_info.left == 0 and 'Right' or 'Left'
      window:perform_action(act.AdjustPaneSize { direction, math.abs(delta) }, pane)
    end
  end)
end

-- Opacity control events
wezterm.on('increase-opacity', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local current = overrides.window_background_opacity or 0.9
  overrides.window_background_opacity = math.min(current + 0.1, 1.0)
  window:set_config_overrides(overrides)
end)

wezterm.on('decrease-opacity', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local current = overrides.window_background_opacity or 0.9
  overrides.window_background_opacity = math.max(current - 0.1, 0.1)
  window:set_config_overrides(overrides)
end)

wezterm.on('reset-opacity', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  overrides.window_background_opacity = nil
  window:set_config_overrides(overrides)
end)

---------------------------------------------------------------
-- Keys
---------------------------------------------------------------
local keys = {
  -- [CMD+SHIFT+r] Reload Configuration
  { key = 'r', mods = 'SUPER|SHIFT', action = act.ReloadConfiguration },
  -- [CMD+p] Command Palette
  { key = 'p', mods = 'SUPER', action = act.ActivateCommandPalette },
  -- [CMD+q] Quit
  { key = 'q', mods = 'SUPER', action = act.QuitApplication },
  -- [CMD+f] Search
  { key = 'f', mods = 'SUPER', action = act.Search { CaseSensitiveString = '' } },
  -- [CMD+c] Copy
  { key = 'c', mods = 'SUPER', action = act.CopyTo('Clipboard') },
  -- [CMD+v] Paste
  { key = 'v', mods = 'SUPER', action = act.PasteFrom('Clipboard') },
  -- [CMD+Space] QuickSelect
  { key = 'Space', mods = 'SUPER', action = act.QuickSelect },

  -- Tab management
  { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = 't', mods = 'SUPER', action = act { SpawnTab = 'CurrentPaneDomain' } },
  { key = 'w', mods = 'SUPER', action = act.CloseCurrentTab { confirm = true } },
  { key = 'e', mods = 'SUPER', action = act.ShowTabNavigator },

  -- Pane split (LEADER+d = vertical, LEADER+v = horizontal)
  { key = 'd', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'v', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  -- [CTRL+w] Close Pane
  { key = 'w', mods = 'CTRL', action = act.CloseCurrentPane { confirm = true } },
  -- [LEADER+z] Toggle Pane Zoom
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },

  -- Pane navigation (CTRL+h/j/k/l)
  { key = 'h', mods = 'CTRL', action = act.ActivatePaneDirection('Left') },
  { key = 'j', mods = 'CTRL', action = act.ActivatePaneDirection('Down') },
  { key = 'k', mods = 'CTRL', action = act.ActivatePaneDirection('Up') },
  { key = 'l', mods = 'CTRL', action = act.ActivatePaneDirection('Right') },

  -- Pane resize (LEADER+SHIFT+h/j/k/l)
  { key = 'H', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'J', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Down', 5 } },
  { key = 'K', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Up', 5 } },
  { key = 'L', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },

  -- [LEADER+s] Enter Setting Mode
  {
    key = 's',
    mods = 'LEADER',
    action = act.ActivateKeyTable { name = 'setting_mode', one_shot = false },
  },

  -- [LEADER+m] Launch lazygit (overlay pane)
  { key = 'm', mods = 'LEADER', action = spawn_overlay_pane('lazygit') },

  -- [LEADER+[] Copy Mode
  { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },

  -- [LEADER+,] Rename Tab
  {
    key = ',',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'Tab name:',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          local tab = require('tab')
          local tab_id = window:active_tab():tab_id()
          if line == '' then
            tab.custom_title[tab_id] = nil
          else
            tab.custom_title[tab_id] = line
          end
        end
      end),
    },
  },

  -- [CTRL+L] Debug Overlay
  { key = 'L', mods = 'CTRL', action = act.ShowDebugOverlay },

  -- [SHIFT+ENTER] Claude Code newline
  { key = 'Enter', mods = 'SHIFT', action = act { SendString = '\x1b\r' } },

  -- [CTRL+SHIFT+p/n] Scroll to previous/next prompt
  { key = 'p', mods = 'CTRL|SHIFT', action = act.ScrollToPrompt(-1) },
  { key = 'n', mods = 'CTRL|SHIFT', action = act.ScrollToPrompt(1) },

  -- [LEADER+g] Grid layout (3 columns, right split)
  {
    key = 'g',
    mods = 'LEADER',
    action = wezterm.action_callback(function(window, pane)
      local right_pane = pane:split { direction = 'Right', size = 0.67 }
      local mid_pane = right_pane:split { direction = 'Right', size = 0.5 }
      mid_pane:split { direction = 'Bottom' }
      pane:activate()
    end),
  },
}

-- [CMD+1-9] Activate Tab 1-9
for i = 1, 9 do
  table.insert(keys, {
    key = tostring(i),
    mods = 'SUPER',
    action = act.ActivateTab(i - 1),
  })
end

---------------------------------------------------------------
-- Key Tables
---------------------------------------------------------------
local key_tables = {}

-- Setting Mode: pane resize + opacity control
local setting_mode = {
  -- Fine-grained pane resize (1 cell)
  { key = 'h', action = act.AdjustPaneSize { 'Left', 1 } },
  { key = 'j', action = act.AdjustPaneSize { 'Down', 1 } },
  { key = 'k', action = act.AdjustPaneSize { 'Up', 1 } },
  { key = 'l', action = act.AdjustPaneSize { 'Right', 1 } },
  -- Opacity control
  { key = ';', action = act.EmitEvent('increase-opacity') },
  { key = '-', action = act.EmitEvent('decrease-opacity') },
  { key = '0', action = act.EmitEvent('reset-opacity') },
  -- Exit
  { key = 'Escape', action = act.PopKeyTable },
  { key = 'q', action = act.PopKeyTable },
  { key = 'c', mods = 'CTRL', action = act.PopKeyTable },
}

-- Percentage-based pane height (1-9 = 10%-90%)
for i = 1, 9 do
  table.insert(setting_mode, {
    key = tostring(i),
    action = set_pane_height_percent(i * 10),
  })
end

-- Percentage-based pane width (CTRL+1-9 = 10%-90%)
for i = 1, 9 do
  table.insert(setting_mode, {
    key = tostring(i),
    mods = 'CTRL',
    action = set_pane_width_percent(i * 10),
  })
end

key_tables.setting_mode = setting_mode

-- Copy Mode: full Vim keybindings
key_tables.copy_mode = {
  -- Movement
  { key = 'h', action = act.CopyMode('MoveLeft') },
  { key = 'j', action = act.CopyMode('MoveDown') },
  { key = 'k', action = act.CopyMode('MoveUp') },
  { key = 'l', action = act.CopyMode('MoveRight') },
  -- Word movement
  { key = 'w', action = act.CopyMode('MoveForwardWord') },
  { key = 'b', action = act.CopyMode('MoveBackwardWord') },
  { key = 'e', action = act.CopyMode('MoveForwardWordEnd') },
  -- Line movement
  { key = '0', action = act.CopyMode('MoveToStartOfLine') },
  { key = '^', mods = 'SHIFT', action = act.CopyMode('MoveToStartOfLineContent') },
  { key = '$', mods = 'SHIFT', action = act.CopyMode('MoveToEndOfLineContent') },
  -- Page movement
  { key = 'u', mods = 'CTRL', action = act.CopyMode('PageUp') },
  { key = 'd', mods = 'CTRL', action = act.CopyMode('PageDown') },
  { key = 'b', mods = 'CTRL', action = act.CopyMode('PageUp') },
  { key = 'f', mods = 'CTRL', action = act.CopyMode('PageDown') },
  -- Document movement
  { key = 'g', action = act.CopyMode('MoveToScrollbackTop') },
  { key = 'G', mods = 'SHIFT', action = act.CopyMode('MoveToScrollbackBottom') },
  -- Screen position
  { key = 'H', mods = 'SHIFT', action = act.CopyMode('MoveToViewportTop') },
  { key = 'M', mods = 'SHIFT', action = act.CopyMode('MoveToViewportMiddle') },
  { key = 'L', mods = 'SHIFT', action = act.CopyMode('MoveToViewportBottom') },
  -- Find character
  { key = 'f', action = act.CopyMode { JumpForward = { prev_char = false } } },
  { key = 'F', mods = 'SHIFT', action = act.CopyMode { JumpBackward = { prev_char = false } } },
  { key = 't', action = act.CopyMode { JumpForward = { prev_char = true } } },
  { key = 'T', mods = 'SHIFT', action = act.CopyMode { JumpBackward = { prev_char = true } } },
  -- Selection
  { key = 'v', action = act.CopyMode { SetSelectionMode = 'Cell' } },
  { key = 'V', mods = 'SHIFT', action = act.CopyMode { SetSelectionMode = 'Line' } },
  { key = 'v', mods = 'CTRL', action = act.CopyMode { SetSelectionMode = 'Block' } },
  -- Yank and exit
  {
    key = 'y',
    action = act.Multiple {
      { CopyTo = 'ClipboardAndPrimarySelection' },
      { CopyMode = 'Close' },
    },
  },
  -- Search
  { key = '/', action = act.CopyMode('EditPattern') },
  { key = 'n', action = act.CopyMode('NextMatch') },
  { key = 'N', mods = 'SHIFT', action = act.CopyMode('PriorMatch') },
  -- Semantic zone navigation
  { key = '[', action = act.CopyMode('MoveBackwardSemanticZone') },
  { key = ']', action = act.CopyMode('MoveForwardSemanticZone') },
  -- Exit
  { key = 'Escape', action = act.CopyMode('Close') },
  { key = 'q', action = act.CopyMode('Close') },
}

-- Search Mode
key_tables.search_mode = {
  { key = 'Enter', action = act.CopyMode('PriorMatch') },
  { key = 'Escape', action = act.CopyMode('Close') },
  { key = 'n', mods = 'CTRL', action = act.CopyMode('NextMatch') },
  { key = 'p', mods = 'CTRL', action = act.CopyMode('PriorMatch') },
  { key = 'r', mods = 'CTRL', action = act.CopyMode('CycleMatchType') },
  { key = 'u', mods = 'CTRL', action = act.CopyMode('ClearPattern') },
}

---------------------------------------------------------------
-- Apply
---------------------------------------------------------------
function M.apply_to_config(config)
  config.disable_default_key_bindings = true
  config.leader = {
    key = 'a',
    mods = 'CTRL',
    timeout_milliseconds = 2000,
  }
  config.keys = keys
  config.key_tables = key_tables
end

return M
