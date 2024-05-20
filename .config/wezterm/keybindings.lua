local wezterm = require 'wezterm'
local act = wezterm.action

return {
    -- コマンドパレットを出す
    keys = {{
        key = 'p',
        mods = 'CTRL',
        action = wezterm.action.ActivateCommandPalette,
    }, {
        key = 'a',
        mods = 'LEADER',
        action = act.ClearScrollback 'ScrollbackOnly'
    }, -- 画面を左右に分割
    {
        key = 'v',
        mods = 'LEADER|CTRL',
        action = wezterm.action.SplitHorizontal {
            domain = 'CurrentPaneDomain'
        }
    }, -- 画面を上下に分割
    {
        key = 's',
        mods = 'LEADER|CTRL',
        action = wezterm.action.SplitVertical {
            domain = 'CurrentPaneDomain'
        }
    }, -- 画面を閉じる
    {
        key = 'w',
        mods = 'LEADER',
        action = wezterm.action.CloseCurrentPane {
            confirm = true
        }
    }, -- パンの移動
    {
        key = "l",
        mods = "LEADER",
        action = wezterm.action({
            ActivatePaneDirection = "Right"
        })
    }, {
        key = "h",
        mods = "LEADER",
        action = wezterm.action({
            ActivatePaneDirection = "Left"
        })
    }, {
        key = "k",
        mods = "LEADER",
        action = wezterm.action({
            ActivatePaneDirection = "Up"
        })
    }, {
        key = "j",
        mods = "LEADER",
        action = wezterm.action({
            ActivatePaneDirection = "Down"
        })
    }, {
        key = "w",
        mods = "LEADER",
        action = wezterm.action({
            ActivatePaneDirection = "Next",
        }),
	}},
}

