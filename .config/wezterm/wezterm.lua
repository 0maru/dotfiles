local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- keybinds
config.leader = { key = 'e', mods = 'CTRL', timetout_milliseconds = 1000 }
config.keys = require('keybinds').keys

-- colors
config.color_scheme = "GitHub Dark"

-- font
config.font = require("wezterm").font("HackGen35 Console NF")
config.use_ime = true
config.font_size = 13.0
config.adjust_window_size_when_changing_font_size = false

config.status_update_interval = 1000
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.9
config.audible_bell = "Disabled"

return config

