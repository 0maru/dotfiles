local wezterm = require('wezterm')

local M = {}

function M.apply_to_config(config)
  -- Color scheme
  config.color_scheme = 'GitHub Dark'

  -- Font
  config.font = wezterm.font_with_fallback {
    { family = "Berkeley Mono", weight = "Regular", stretch = "Normal", style = "Normal" },
    { family = "Hack Nerd Font", weight = "Regular", stretch = "Normal", style = "Normal" },
    { family = "Zen Kaku Gothic New", weight = "Regular", stretch = "Normal", style = "Normal" },
  }
  config.font_size = 12.0
  config.adjust_window_size_when_changing_font_size = false

  -- Window
  config.window_background_opacity = 0.9
  config.macos_window_background_blur = 20
  config.window_decorations = 'RESIZE'
  config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
  config.initial_rows = 60
  config.initial_cols = 140
  config.default_cursor_style = "SteadyBar"

  -- Pane
  config.inactive_pane_hsb = { saturation = 0.85, brightness = 0.7 }

  -- Rendering
  config.front_end = "WebGpu"
  config.max_fps = 120
  config.scrollback_lines = 10000

  -- Tab bar
  config.tab_bar_at_bottom = true
  config.show_new_tab_button_in_tab_bar = false
  config.show_close_tab_button_in_tabs = false
  config.hide_tab_bar_if_only_one_tab = true
  config.window_frame = {
    inactive_titlebar_bg = 'none',
    active_titlebar_bg = 'none',
  }
  config.colors = {
    tab_bar = {
      inactive_tab_edge = 'none',
    },
  }

  -- Quick Select patterns
  config.quick_select_patterns = {
    -- File paths (absolute and relative)
    '[\\w\\-\\.]*/[\\w\\-\\./]+',
    -- Git hashes (7-40 hex chars)
    '\\b[0-9a-f]{7,40}\\b',
    -- UUIDs
    '\\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\\b',
    -- IPv4 addresses
    '\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b',
  }
end

return M
