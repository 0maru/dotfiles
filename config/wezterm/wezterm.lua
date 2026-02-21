local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.use_ime = true

-- themes
config.color_scheme = 'GitHub Dark'
config.font = wezterm.font_with_fallback {
  { family = "Berkeley Mono", weight = "Regular", stretch = "Normal", style = "Normal"},
  { family = "Zen Kaku Gothic New", weight = "Regular", stretch = "Normal", style = "Normal"}
}
config.font_size = 12.0

config.adjust_window_size_when_changing_font_size = false
config.automatically_reload_config = true
config.window_background_opacity = 0.9
config.show_new_tab_button_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.show_close_tab_button_in_tabs = false
config.initial_rows = 60
config.initial_cols = 140
config.window_decorations = 'RESIZE'
config.front_end = "WebGpu"
config.max_fps = 120
config.scrollback_lines = 10000
config.macos_window_background_blur = 20
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.default_cursor_style = "SteadyBar"
config.tab_bar_at_bottom = true
config.window_frame = {
  inactive_titlebar_bg = 'none',
  active_titlebar_bg = 'none'
}
config.colors = {
  tab_bar = {
    inactive_tab_edge = 'none'
  }
}

-- keybindings
config.disable_default_key_bindings = true
config.keys = require('keybindings').keys
-- Leader key ctrl+a
config.leader = {
  key = 'a',
  mods = 'CTRL',
  timeout_milliseconds = 1000
}

local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

-- ghq で管理しているプロジェクトフォルダ以下にいる場合はプロジェクト名を取得してタブのタイトルに設定する
function tab_name(tab)
  local cwd = tab.active_pane.current_working_dir
  if not cwd or not cwd.path then
    return tab.active_pane.title
  end
  local workspaces_dir = os.getenv('HOME')..'/workspaces/github.com'
  local full_path = cwd.path
  if string.sub(full_path, 1, #workspaces_dir) == workspaces_dir then
    -- $HOME/workspaces/github.com/organization/<project_name> のproject_name を抽出する
    local project_name = full_path:match('^/[^/]+/[^/]+/[^/]+/[^/]+/[^/]+/([^/]+)')
    return project_name
  end

  return tab.active_pane.title
end

wezterm.on(
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)
    local background = '#FFDBED'
    local foreground = '#333333'
    local edge_background = 'none'
    if tab.is_active then
      background = '#0067C0'
      foreground = '#E0FFFF'
    end
    local edge_foreground = background
    local title = tab_name(tab)

    -- Claude Code の実行状態をタブに表示
    local status_icon = ''
    local claude_status = tab.active_pane.user_vars.claude_status or ''
    if claude_status == 'running' then
      status_icon = ' ' .. wezterm.nerdfonts.cod_loading
    end

    return {
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = SOLID_LEFT_ARROW },
      { Background = { Color = background } },
      { Foreground = { Color = foreground } },
      { Text = ' ' .. (tab.tab_index + 1) .. ': ' .. title .. status_icon .. ' ' },
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = SOLID_RIGHT_ARROW },
    }
  end
)


return config
