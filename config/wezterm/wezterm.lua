local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.use_ime = true
config.font = wezterm.font("HackGen35 Console NF")
config.font_size = 12.0
config.adjust_window_size_when_changing_font_size = false

config.color_scheme = 'GitHub Dark'
config.window_background_opacity = 0.9
config.show_new_tab_button_in_tabs = false
config.show_close_tab_button_in_tabs = false

-- keybindings
config.disable_default_key_bindings = true
config.keys = require('keybindings').keys
-- Leader key `
config.leader = {
  key = '`',
  timeout_milliseconds = 1000
}

return config
