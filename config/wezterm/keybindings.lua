---------------------------------------------------------------
-- キーバインド設定
-- リーダーキー: CTRL+;（2秒タイムアウト）
-- ※ ALT キーは Aerospace が占有しているため使用禁止
---------------------------------------------------------------
local wezterm = require('wezterm')
local act = wezterm.action

local M = {}

local SHELL = os.getenv('SHELL') or '/bin/zsh'

---------------------------------------------------------------
-- ヘルパー関数
---------------------------------------------------------------

-- オーバーレイ状態を追跡（ウィンドウID → true）
local overlay_windows = {}

-- コマンドをオーバーレイペインで起動する（下方向に分割→ズーム）
-- lazygit などの TUI ツールをフルスクリーンで表示するのに使用
local function spawn_overlay_pane(command)
  return wezterm.action_callback(function(window, pane)
    local cwd_url = pane:get_current_working_dir()
    local new_pane = pane:split({
      direction = 'Bottom',
      size = 0.1,
      cwd = cwd_url and cwd_url.path or nil,
      args = { SHELL, '-lic', command }
    })
    window:perform_action(act.TogglePaneZoomState, new_pane)

    overlay_windows[window:window_id()] = true
    local overrides = window:get_config_overrides() or {}
    overrides.window_padding = { left = 24, right = 24, top = 16, bottom = 16 }
    window:set_config_overrides(overrides)
  end)
end

-- オーバーレイ終了時（ズーム解除時）にパディングを元に戻す
wezterm.on('update-status', function(window, pane)
  local window_id = window:window_id()
  if not overlay_windows[window_id] then return end

  local tab = window:active_tab()
  local is_zoomed = false
  for _, p in ipairs(tab:panes_with_info()) do
    if p.is_zoomed then
      is_zoomed = true
      break
    end
  end

  if not is_zoomed then
    overlay_windows[window_id] = nil
    local overrides = window:get_config_overrides() or {}
    overrides.window_padding = nil
    window:set_config_overrides(overrides)
  end
end)

-- ペインの高さをタブ全体に対するパーセンテージで設定する
local function set_pane_height_percent(percent)
  return wezterm.action_callback(function(window, pane)
    local tab = window:active_tab()
    local tab_size = tab:get_size()
    local total_rows = tab_size.rows

    -- 現在のペイン情報を取得
    local pane_info = nil
    for _, info in ipairs(tab:panes_with_info()) do
      if info.pane:pane_id() == pane:pane_id() then
        pane_info = info
        break
      end
    end
    if not pane_info then return end

    -- 目標行数と現在行数の差分を計算してリサイズ
    local current_rows = pane_info.pixel_height / tab_size.pixel_height * total_rows
    local target_rows = math.floor(total_rows * percent / 100)
    local delta = target_rows - math.floor(current_rows)

    if delta ~= 0 then
      -- ペインが上端にある場合は下方向、そうでなければ上方向にリサイズ
      local direction = pane_info.top == 0 and 'Down' or 'Up'
      window:perform_action(act.AdjustPaneSize { direction, math.abs(delta) }, pane)
    end
  end)
end

-- ペインの幅をタブ全体に対するパーセンテージで設定する
local function set_pane_width_percent(percent)
  return wezterm.action_callback(function(window, pane)
    local tab = window:active_tab()
    local tab_size = tab:get_size()
    local total_cols = tab_size.cols

    -- 現在のペイン情報を取得
    local pane_info = nil
    for _, info in ipairs(tab:panes_with_info()) do
      if info.pane:pane_id() == pane:pane_id() then
        pane_info = info
        break
      end
    end
    if not pane_info then return end

    -- 目標列数と現在列数の差分を計算してリサイズ
    local current_cols = pane_info.pixel_width / tab_size.pixel_width * total_cols
    local target_cols = math.floor(total_cols * percent / 100)
    local delta = target_cols - math.floor(current_cols)

    if delta ~= 0 then
      -- ペインが左端にある場合は右方向、そうでなければ左方向にリサイズ
      local direction = pane_info.left == 0 and 'Right' or 'Left'
      window:perform_action(act.AdjustPaneSize { direction, math.abs(delta) }, pane)
    end
  end)
end

---------------------------------------------------------------
-- 通常キーバインド
---------------------------------------------------------------
local keys = {
  -- === 一般操作 ===
  { key = 'r', mods = 'SUPER|SHIFT', action = act.ReloadConfiguration },  -- 設定リロード
  { key = 'p', mods = 'SUPER', action = act.ActivateCommandPalette },     -- コマンドパレット
  { key = 'q', mods = 'SUPER', action = act.QuitApplication },            -- アプリ終了
  { key = 'f', mods = 'SUPER', action = act.Search { CaseSensitiveString = '' } }, -- 検索
  { key = 'c', mods = 'SUPER', action = act.CopyTo('Clipboard') },        -- コピー
  { key = 'v', mods = 'SUPER', action = act.PasteFrom('Clipboard') },     -- 貼り付け
  { key = 'Space', mods = 'SUPER', action = act.QuickSelect },            -- クイックセレクト

  -- === タブ管理 ===
  { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },          -- 次のタブ
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },   -- 前のタブ
  { key = 't', mods = 'SUPER', action = act { SpawnTab = 'CurrentPaneDomain' } }, -- 新しいタブ
  { key = 'w', mods = 'SUPER', action = act.CloseCurrentTab { confirm = true } }, -- タブを閉じる
  { key = 'e', mods = 'SUPER', action = act.ShowTabNavigator },                   -- タブ一覧

  -- === ペイン分割 ===
  { key = 'v', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },   -- 上下に分割
  { key = 's', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } }, -- 左右に分割
  { key = 'w', mods = 'CTRL', action = act.CloseCurrentPane { confirm = true } },  -- ペインを閉じる
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },                -- ペインのズーム切り替え

  -- === ペイン移動（Vim風 hjkl） ===
  { key = 'h', mods = 'CTRL', action = act.ActivatePaneDirection('Left') },   -- 左のペインへ
  { key = 'j', mods = 'CTRL', action = act.ActivatePaneDirection('Down') },   -- 下のペインへ
  { key = 'k', mods = 'CTRL', action = act.ActivatePaneDirection('Up') },     -- 上のペインへ
  { key = 'l', mods = 'CTRL', action = act.ActivatePaneDirection('Right') },  -- 右のペインへ

  -- === ツール起動 ===
  -- lazygit をオーバーレイペインで起動
  { key = 'l', mods = 'LEADER', action = spawn_overlay_pane('lazygit') },
  -- Neovim をオーバーレイペインで起動
  { key = 'n', mods = 'LEADER', action = spawn_overlay_pane('nvim .') },

  -- === コピーモード（Vim風テキスト選択） ===
  { key = '}', mods = 'LEADER', action = act.ActivateCopyMode },

  -- === タブ名の変更 ===
  -- 空文字で確定するとカスタム名をリセット
  {
    key = ',',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'Tab name:',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          local tab = require('tab')
          local tab_id = window:active_tab():tab_id()
          if line == '' then
            tab.custom_title[tab_id] = nil
          else
            tab.custom_title[tab_id] = line
          end
        end
      end),
    },
  },

  -- === デバッグ ===
  -- WezTerm のデバッグオーバーレイを表示
  { key = 'L', mods = 'CTRL', action = act.ShowDebugOverlay },

  -- === Claude Code 用 ===
  -- SHIFT+ENTER で改行を送信（Claude Code のマルチライン入力用）
  { key = 'Enter', mods = 'SHIFT', action = act { SendString = '\x1b\r' } },

  -- === プロンプト間スクロール ===
  -- シェルのセマンティックゾーンを利用して前後のプロンプトにジャンプ
  { key = 'p', mods = 'CTRL|SHIFT', action = act.ScrollToPrompt(-1) },  -- 前のプロンプトへ
  { key = 'n', mods = 'CTRL|SHIFT', action = act.ScrollToPrompt(1) },   -- 次のプロンプトへ

  -- === グリッドレイアウト ===
  -- 3列レイアウトを一括作成（左1/3 + 右上1/3 + 右下1/3）
  {
    key = 'g',
    mods = 'LEADER',
    action = wezterm.action_callback(function(window, pane)
      local right_pane = pane:split { direction = 'Right', size = 0.67 }
      local mid_pane = right_pane:split { direction = 'Right', size = 0.5 }
      mid_pane:split { direction = 'Bottom' }
      pane:activate()
    end),
  },
}

-- CMD+数字キーでタブを直接切り替え（CMD+1〜9 → タブ1〜9）
for i = 1, 9 do
  table.insert(keys, {
    key = tostring(i),
    mods = 'SUPER',
    action = act.ActivateTab(i - 1),
  })
end

---------------------------------------------------------------
-- キーテーブル（モード別キーバインド）
---------------------------------------------------------------
local key_tables = {}

-- === セッティングモード ===
-- LEADER+s で入るモード。Escape/q/CTRL+c で抜ける
local setting_mode = {
  -- ペインリサイズ（1セル単位の細かい調整）
  { key = 'h', action = act.AdjustPaneSize { 'Left', 1 } },
  { key = 'j', action = act.AdjustPaneSize { 'Down', 1 } },
  { key = 'k', action = act.AdjustPaneSize { 'Up', 1 } },
  { key = 'l', action = act.AdjustPaneSize { 'Right', 1 } },
  -- 透過度の調整
  { key = ';', action = act.EmitEvent('increase-opacity') },  -- 透過度を上げる（不透明に）
  { key = '-', action = act.EmitEvent('decrease-opacity') },  -- 透過度を下げる（透明に）
  { key = '0', action = act.EmitEvent('reset-opacity') },     -- 透過度をリセット
  -- モード終了
  { key = 'Escape', action = act.PopKeyTable },
  { key = 'q', action = act.PopKeyTable },
  { key = 'c', mods = 'CTRL', action = act.PopKeyTable },
}

-- ペインの高さをパーセンテージで指定（1〜9キー → 10%〜90%）
for i = 1, 9 do
  table.insert(setting_mode, {
    key = tostring(i),
    action = set_pane_height_percent(i * 10),
  })
end

-- ペインの幅をパーセンテージで指定（CTRL+1〜9キー → 10%〜90%）
for i = 1, 9 do
  table.insert(setting_mode, {
    key = tostring(i),
    mods = 'CTRL',
    action = set_pane_width_percent(i * 10),
  })
end

key_tables.setting_mode = setting_mode

-- === コピーモード ===
-- LEADER+[ で入るモード。Vim ライクなキーバインドでテキストを選択・コピーできる
key_tables.copy_mode = {
  -- カーソル移動（hjkl）
  { key = 'h', action = act.CopyMode('MoveLeft') },
  { key = 'j', action = act.CopyMode('MoveDown') },
  { key = 'k', action = act.CopyMode('MoveUp') },
  { key = 'l', action = act.CopyMode('MoveRight') },
  -- 単語移動
  { key = 'w', action = act.CopyMode('MoveForwardWord') },     -- 次の単語の先頭へ
  { key = 'b', action = act.CopyMode('MoveBackwardWord') },    -- 前の単語の先頭へ
  { key = 'e', action = act.CopyMode('MoveForwardWordEnd') },  -- 単語の末尾へ
  -- 行内移動
  { key = '0', action = act.CopyMode('MoveToStartOfLine') },                     -- 行頭へ
  { key = '^', mods = 'SHIFT', action = act.CopyMode('MoveToStartOfLineContent') }, -- 行頭（空白除く）へ
  { key = '$', mods = 'SHIFT', action = act.CopyMode('MoveToEndOfLineContent') },   -- 行末へ
  -- ページ移動
  { key = 'u', mods = 'CTRL', action = act.CopyMode('PageUp') },    -- 半ページ上へ
  { key = 'd', mods = 'CTRL', action = act.CopyMode('PageDown') },  -- 半ページ下へ
  { key = 'b', mods = 'CTRL', action = act.CopyMode('PageUp') },    -- 1ページ上へ
  { key = 'f', mods = 'CTRL', action = act.CopyMode('PageDown') },  -- 1ページ下へ
  -- ドキュメント先頭・末尾
  { key = 'g', action = act.CopyMode('MoveToScrollbackTop') },                    -- スクロールバッファの先頭へ
  { key = 'G', mods = 'SHIFT', action = act.CopyMode('MoveToScrollbackBottom') }, -- スクロールバッファの末尾へ
  -- 画面内位置
  { key = 'H', mods = 'SHIFT', action = act.CopyMode('MoveToViewportTop') },     -- 画面上端へ
  { key = 'M', mods = 'SHIFT', action = act.CopyMode('MoveToViewportMiddle') },  -- 画面中央へ
  { key = 'L', mods = 'SHIFT', action = act.CopyMode('MoveToViewportBottom') },  -- 画面下端へ
  -- 文字検索（f/F/t/T）
  { key = 'f', action = act.CopyMode { JumpForward = { prev_char = false } } },                 -- 前方の文字へジャンプ
  { key = 'F', mods = 'SHIFT', action = act.CopyMode { JumpBackward = { prev_char = false } } }, -- 後方の文字へジャンプ
  { key = 't', action = act.CopyMode { JumpForward = { prev_char = true } } },                   -- 前方の文字の手前へ
  { key = 'T', mods = 'SHIFT', action = act.CopyMode { JumpBackward = { prev_char = true } } },  -- 後方の文字の手前へ
  -- 選択モード
  { key = 'v', action = act.CopyMode { SetSelectionMode = 'Cell' } },               -- 文字単位選択
  { key = 'V', mods = 'SHIFT', action = act.CopyMode { SetSelectionMode = 'Line' } }, -- 行単位選択
  { key = 'v', mods = 'CTRL', action = act.CopyMode { SetSelectionMode = 'Block' } }, -- 矩形選択
  -- ヤンク（コピーしてコピーモードを終了）
  {
    key = 'y',
    action = act.Multiple {
      { CopyTo = 'ClipboardAndPrimarySelection' },
      { CopyMode = 'Close' },
    },
  },
  -- 検索
  { key = '/', action = act.CopyMode('EditPattern') },    -- 検索パターンを入力
  { key = 'n', action = act.CopyMode('NextMatch') },      -- 次のマッチへ
  { key = 'N', mods = 'SHIFT', action = act.CopyMode('PriorMatch') }, -- 前のマッチへ
  -- セマンティックゾーン移動（プロンプト間の移動等）
  { key = '[', action = act.CopyMode('MoveBackwardSemanticZone') },  -- 前のゾーンへ
  { key = ']', action = act.CopyMode('MoveForwardSemanticZone') },   -- 次のゾーンへ
  -- モード終了
  { key = 'Escape', action = act.CopyMode('Close') },
  { key = 'q', action = act.CopyMode('Close') },
}

-- === 検索モード ===
-- コピーモード内で / を押すと入る。検索パターンの入力と結果のナビゲーション
key_tables.search_mode = {
  { key = 'Enter', action = act.CopyMode('PriorMatch') },                       -- 前のマッチへ（確定）
  { key = 'Escape', action = act.CopyMode('Close') },                           -- 検索を終了
  { key = 'n', mods = 'CTRL', action = act.CopyMode('NextMatch') },             -- 次のマッチへ
  { key = 'p', mods = 'CTRL', action = act.CopyMode('PriorMatch') },            -- 前のマッチへ
  { key = 'r', mods = 'CTRL', action = act.CopyMode('CycleMatchType') },        -- マッチ方式を切り替え（文字列/正規表現）
  { key = 'u', mods = 'CTRL', action = act.CopyMode('ClearPattern') },          -- 検索パターンをクリア
}

---------------------------------------------------------------
-- 設定の適用
---------------------------------------------------------------
function M.apply_to_config(config)
  -- WezTerm のデフォルトキーバインドを無効化（独自定義のみ使う）
  config.disable_default_key_bindings = true
  -- リーダーキー: CTRL+;
  config.leader = {
    key = ';',
    mods = 'CTRL',
    timeout_milliseconds = 2000,
  }
  config.keys = keys
  config.key_tables = key_tables
end

-- augment-command-palette イベントでコマンドパレットにカスタムアクションを追加
wezterm.on("augment-command-palette", function(window, pane)
  local commands = {
    {
      brief = "Lauch: lazygit",
      icon = "md_git",
      action = spawn_overlay_pane('lazygit'),
    },
    {
      brief = "Launch: Neovim",
      icon = "md_vim",
      action = spawn_overlay_pane("nvim"),
    },
    {
      brief = "Launch: Claude Code",
      icon = "md_robot",
      action = spawn_overlay_pane("claude"),
    },
  }
  return commands
end)

return M
