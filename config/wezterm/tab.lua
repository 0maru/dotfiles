---------------------------------------------------------------
-- タブタイトル設定
-- タブに表示するタイトルとアイコンのカスタマイズ
-- - プロセスに応じた Nerd Font アイコン表示
-- - ghq 管理下のプロジェクト名を自動表示
-- - Claude Code の実行状態をアイコンで表示
---------------------------------------------------------------
local wezterm = require('wezterm')

local M = {}

-- LEADER+, で設定したカスタムタブ名を保持するテーブル
M.custom_title = {}

-- プロセス名に対応する Nerd Font アイコンと色のマッピング
local process_icons = {
  nvim = { icon = wezterm.nerdfonts.linux_neovim, color = '#73C936' },
  vim = { icon = wezterm.nerdfonts.linux_neovim, color = '#73C936' },
  docker = { icon = wezterm.nerdfonts.md_docker, color = '#2496ED' },
  lazygit = { icon = wezterm.nerdfonts.md_git, color = '#F05032' },
  git = { icon = wezterm.nerdfonts.md_git, color = '#F05032' },
  claude = { icon = wezterm.nerdfonts.md_star_four_points, color = '#D4A574' },
  node = { icon = wezterm.nerdfonts.md_nodejs, color = '#539E43' },
  python3 = { icon = wezterm.nerdfonts.md_language_python, color = '#3776AB' },
  python = { icon = wezterm.nerdfonts.md_language_python, color = '#3776AB' },
  ssh = { icon = wezterm.nerdfonts.md_server, color = '#E04C4C' },
}
-- 上記に該当しないプロセス用のデフォルトアイコン
local default_icon = { icon = wezterm.nerdfonts.dev_terminal, color = '#CCCCCC' }

-- ペインのフォアグラウンドプロセス名からアイコン情報を取得する
local function get_process_icon(pane)
  local process_name = pane.foreground_process_name or ''
  local basename = process_name:match('([^/]+)$') or ''
  return process_icons[basename] or default_icon
end

-- タブタイトルを決定する（優先度順）
local function get_tab_title(tab)
  -- 優先度1: ユーザーが LEADER+, で設定したカスタム名
  if M.custom_title[tab.tab_id] then
    return M.custom_title[tab.tab_id]
  end

  -- 優先度2: ghq 管理ディレクトリの場合、プロジェクト名（リポジトリ名）を表示
  local cwd = tab.active_pane.current_working_dir
  if cwd and cwd.path then
    local workspaces_dir = os.getenv('HOME') .. '/workspaces/github.com'
    local full_path = cwd.path
    if string.sub(full_path, 1, #workspaces_dir) == workspaces_dir then
      local project_name = full_path:match('^/[^/]+/[^/]+/[^/]+/[^/]+/[^/]+/([^/]+)')
      if project_name then
        return project_name
      end
    end
  end

  -- 優先度3: WezTerm のデフォルトタイトル
  return tab.active_pane.title
end

-- タブの左右に使う矢印型のセパレータ（Powerline 風）
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

function M.apply_to_config(config)
  -- タブタイトルのフォーマットをカスタマイズするイベントハンドラ
  wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    -- タブの状態に応じた配色
    local background = '#FFDBED'   -- 非アクティブタブ: ピンク
    local foreground = '#333333'
    local edge_background = 'none'

    if tab.is_active then
      background = '#0067C0'       -- アクティブタブ: 青
      foreground = '#E0FFFF'
    end

    local edge_foreground = background
    local title = get_tab_title(tab)
    local proc = get_process_icon(tab.active_pane)

    -- Claude Code の実行状態をアイコンで表示
    -- user_vars.claude_status は Claude Code が自動設定する
    local status_icon = ''
    local claude_status = tab.active_pane.user_vars.claude_status or ''
    if claude_status == 'running' then
      status_icon = ' ' .. wezterm.nerdfonts.cod_loading
    end

    -- Powerline 風セパレータ付きのタブタイトルを構築
    -- 構成: [左矢印][アイコン][番号: タイトル][右矢印]
    return {
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = SOLID_LEFT_ARROW },
      { Background = { Color = background } },
      { Foreground = { Color = proc.color } },
      { Text = ' ' .. proc.icon },
      { Foreground = { Color = foreground } },
      { Text = ' ' .. (tab.tab_index + 1) .. ': ' .. title .. status_icon .. ' ' },
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = SOLID_RIGHT_ARROW },
    }
  end)
end

return M
