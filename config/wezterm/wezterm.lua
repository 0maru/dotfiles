local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font("HackGen35 Console NF")
config.font_size = 12.0

config.color_scheme = 'GitHub Dark'
config.window_background_opacity = 0.9

return config
