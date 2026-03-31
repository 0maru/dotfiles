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
-- 各モジュールの設定を適用
require('appearance').apply_to_config(config)  -- 外観（色、フォント、ウィンドウ等）
require('keybindings').apply_to_config(config)  -- キーバインド
require('tab').apply_to_config(config)          -- タブタイトルの表示

return config
