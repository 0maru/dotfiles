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
config.show_new_tab_button_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.initial_rows = 60
config.initial_cols = 140
config.window_decorations = 'RESIZE'
config.tab_bar_at_bottom = true
config.window_frame = {
    inactive_titlebar_bg = "none",
    active_titlebar_bg = "none"
}

config.window_background_gradient = {
    colors = {'#000000'}
}
config.colors = {
    tab_bar = {
        inactive_tab_edge = "none"
    }
}

-- config.show_close_tab_button_in_tabs = false


-- keybindings
config.disable_default_key_bindings = true
config.keys = require('keybindings').keys
-- Leader key `
config.leader = {
  key = '`',
  timeout_milliseconds = 1000
}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local background = "#5c6d71"
    local foreground = "#FFFFFF"

    if tab.is_active then
        background = "#ae8b2d"
        foreground = "#FFFFFF"
    end

    local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

    return {{
        Background = {
            Color = background
        }
    }, {
        Foreground = {
            Color = foreground
        }
    }, {
        Text = title
    }}
end)


return config
