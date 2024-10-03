local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.use_ime = true
config.adjust_window_size_when_changing_font_size = false
config.automatically_reload_config = true
config.show_new_tab_button_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

-- themes
config.color_scheme = 'GitHub Dark'
config.font = wezterm.font("HackGen35 Console NF")
config.font_size = 12.0
config.window_background_opacity = 0.9
config.initial_cols = 100
config.initial_rows = 40

-- keybindings
config.disable_default_key_bindings = true
config.keys = require('keybindings').keys
-- Leader key `
config.leader = {
  key = '`',
  timeout_milliseconds = 1000
}

return config
