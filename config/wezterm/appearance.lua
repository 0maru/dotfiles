---------------------------------------------------------------
-- 外観設定
-- カラースキーム、フォント、ウィンドウ、ペイン、レンダリング、
-- タブバー、クイックセレクトの設定
---------------------------------------------------------------
local wezterm = require('wezterm')

local M = {}

function M.apply_to_config(config)
  ---------------------------------------------------------------
  -- カラースキーム
  ---------------------------------------------------------------
  config.color_scheme = 'GitHub Dark'

  ---------------------------------------------------------------
  -- フォント設定
  -- フォールバック順: Berkeley Mono → Hack Nerd Font → Zen Kaku Gothic New
  -- 英字 → アイコン（Nerd Font） → 日本語 の順で描画される
  ---------------------------------------------------------------
  config.font = wezterm.font_with_fallback {
    { family = "Berkeley Mono", weight = "Regular", stretch = "Normal", style = "Normal" },
    { family = "Hack Nerd Font", weight = "Regular", stretch = "Normal", style = "Normal" },
    { family = "Zen Kaku Gothic New", weight = "Regular", stretch = "Normal", style = "Normal" },
  }
  config.font_size = 12.0
  -- フォントサイズ変更時にウィンドウサイズを追従させない
  config.adjust_window_size_when_changing_font_size = false

  ---------------------------------------------------------------
  -- ウィンドウ設定
  ---------------------------------------------------------------
  -- 背景の透過度（0.0〜1.0、1.0で完全不透明）
  config.window_background_opacity = 0.85
  -- macOS のウィンドウ背景ぼかし度合い
  config.macos_window_background_blur = 20
  -- ウィンドウ装飾: リサイズのみ（タイトルバー非表示）
  config.window_decorations = 'RESIZE'
  -- ウィンドウ内側の余白（ピクセル）
  config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
  -- 起動時のウィンドウサイズ（行数×列数）
  config.initial_rows = 60
  config.initial_cols = 140
  -- カーソルスタイル: 点滅しない縦棒
  config.default_cursor_style = "SteadyBar"

  ---------------------------------------------------------------
  -- ペイン設定
  ---------------------------------------------------------------
  -- 非アクティブペインの色合い（彩度・明度を下げて区別しやすくする）
  config.inactive_pane_hsb = { saturation = 0.85, brightness = 0.7 }

  ---------------------------------------------------------------
  -- ベル設定
  -- Claude Code の Stop/Notification フックから BEL (\a) を送信して
  -- WezTerm の `bell` イベントでタブ未読マーカーを点ける（tab.lua 参照）。
  -- 音は鳴らさず、視覚的なフラッシュも控えめにする。
  ---------------------------------------------------------------
  config.audible_bell = "Disabled"
  config.visual_bell = {
    fade_in_function = 'EaseIn',
    fade_in_duration_ms = 0,
    fade_out_function = 'EaseOut',
    fade_out_duration_ms = 0,
  }

  ---------------------------------------------------------------
  -- レンダリング設定
  ---------------------------------------------------------------
  -- レンダリングバックエンド（WebGpu で GPU アクセラレーション）
  config.front_end = "WebGpu"
  -- 最大フレームレート
  config.max_fps = 120
  -- スクロールバッファの最大行数
  config.scrollback_lines = 10000

  ---------------------------------------------------------------
  -- タブバー設定
  ---------------------------------------------------------------
  -- タブバーをウィンドウ下部に表示
  config.tab_bar_at_bottom = true
  -- 「新しいタブ」ボタンを非表示
  config.show_new_tab_button_in_tab_bar = false
  -- タブの「閉じる」ボタンを非表示
  config.show_close_tab_button_in_tabs = false
  -- タブが1つだけの場合はタブバーを隠す
  config.hide_tab_bar_if_only_one_tab = true
  -- タイトルバーの背景色を透明にする
  config.window_frame = {
    inactive_titlebar_bg = 'none',
    active_titlebar_bg = 'none',
  }
  -- タブバーの境界線を透明にする
  config.colors = {
    tab_bar = {
      inactive_tab_edge = 'none',
    },
  }

  ---------------------------------------------------------------
  -- クイックセレクト パターン
  -- CMD+Space で画面上のテキストをパターンマッチで素早く選択・コピーできる
  ---------------------------------------------------------------
  config.quick_select_patterns = {
    -- ファイルパス（絶対パス・相対パス）
    '[\\w\\-\\.]*/[\\w\\-\\./]+',
    -- Git ハッシュ（7〜40桁の16進数）
    '\\b[0-9a-f]{7,40}\\b',
    -- UUID
    '\\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\\b',
    -- IPv4 アドレス
    '\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b',
  }
end

return M
