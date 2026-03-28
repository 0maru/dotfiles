local wezterm = require('wezterm')

local M = {}

-- Custom tab titles set by LEADER+,
M.custom_title = {}

-- Process name to Nerd Font icon mapping
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
local default_icon = { icon = wezterm.nerdfonts.dev_terminal, color = '#CCCCCC' }

local function get_process_icon(pane)
  local process_name = pane.foreground_process_name or ''
  local basename = process_name:match('([^/]+)$') or ''
  return process_icons[basename] or default_icon
end

-- Extract project name from ghq-managed directory
local function get_tab_title(tab)
  -- Priority 1: Custom title
  if M.custom_title[tab.tab_id] then
    return M.custom_title[tab.tab_id]
  end

  -- Priority 2: ghq project name
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

  -- Priority 3: Default pane title
  return tab.active_pane.title
end

local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

function M.apply_to_config(config)
  wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local background = '#FFDBED'
    local foreground = '#333333'
    local edge_background = 'none'

    if tab.is_active then
      background = '#0067C0'
      foreground = '#E0FFFF'
    end

    local edge_foreground = background
    local title = get_tab_title(tab)
    local proc = get_process_icon(tab.active_pane)

    -- Claude Code status icon
    local status_icon = ''
    local claude_status = tab.active_pane.user_vars.claude_status or ''
    if claude_status == 'running' then
      status_icon = ' ' .. wezterm.nerdfonts.cod_loading
    end

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
