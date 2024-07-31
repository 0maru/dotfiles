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

-- keybindings
config.keys = require('keybindings').keys
-- ctrl + a
config.leader = {
  key = 'a',
  mods = 'CTRL',
  timeout_milliseconds = 1000
}


return config
