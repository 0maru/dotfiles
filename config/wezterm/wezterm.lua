local wezterm = require('wezterm')
local config = wezterm.config_builder()

config.use_ime = true
config.automatically_reload_config = true

require('appearance').apply_to_config(config)
require('keybindings').apply_to_config(config)
require('tab').apply_to_config(config)
-- require('statusbar').apply_to_config(config)

return config
