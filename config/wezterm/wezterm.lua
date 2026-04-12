---------------------------------------------------------------
-- WezTerm メイン設定ファイル
-- 各モジュールを読み込んで config に適用するオーケストレーター
---------------------------------------------------------------
local wezterm = require('wezterm')
local config = wezterm.config_builder()

-- IME（日本語入力）を有効にする
config.use_ime = true
-- 設定ファイル変更時に自動でリロードする
config.automatically_reload_config = true
-- macSKK向け Ctrl+j で改行されないようにするs
config.macos_forward_to_ime_modifier_mask = "SHIFT|CTRL"
-- mailto リンクを無効化（メールアプリの起動を防ぐ）
local hyperlink_rules = wezterm.default_hyperlink_rules()
for i = #hyperlink_rules, 1, -1 do
  if hyperlink_rules[i].format and hyperlink_rules[i].format:find('mailto') then
    table.remove(hyperlink_rules, i)
  end
end
config.hyperlink_rules = hyperlink_rules

-- 各モジュールの設定を適用
require('appearance').apply_to_config(config)  -- 外観（色、フォント、ウィンドウ等）
require('keybindings').apply_to_config(config) -- キーバインド
require('tab').apply_to_config(config)         -- タブタイトルの表示

-- WezTerm Agent Dashboard
-- keybindings.apply_to_config が config.keys を丸ごと代入するため、
-- それより後で table.insert する必要がある
local agent_dashboard = wezterm.plugin.require('https://github.com/0maru/wezterm-agent-dashboard')
agent_dashboard.setup({
  binary_name = wezterm.home_dir .. "/.local/bin/wezterm-agent-dashboard"
})
agent_dashboard.apply_to_config(config)

return config
