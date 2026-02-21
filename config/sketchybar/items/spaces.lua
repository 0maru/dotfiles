local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.icon_map")

local spaces = {}
local workspace_ids = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "B", "C", "E", "S", "T" }

local colors_spaces = {
	colors.cmap_1,
	colors.cmap_2,
	colors.cmap_3,
	colors.cmap_4,
	colors.cmap_5,
	colors.cmap_6,
	colors.cmap_7,
	colors.cmap_8,
	colors.cmap_9,
	colors.cmap_10,
	colors.cmap_11,
	colors.cmap_12,
	colors.cmap_13,
	colors.cmap_14,
}

-- Register custom event for AeroSpace workspace changes
sbar.add("event", "aerospace_workspace_change")

for i, sid in ipairs(workspace_ids) do
	local space = sbar.add("item", "space." .. sid, {
		icon = {
			font = {
				family = settings.font.numbers,
				size = 14,
			},
			string = sid,
			padding_left = 5,
			padding_right = 0,
			color = colors.tn_black1,
		},
		label = {
			padding_right = 10,
			padding_left = 3,
			color = colors_spaces[i],
			font = "sketchybar-app-font-bg:Regular:21.0",
			y_offset = -2,
		},
		padding_right = 4,
		padding_left = 4,
		background = {
			color = colors.transparent,
			height = 22,
			border_width = 0,
			border_color = colors.transparent,
		},
	})

	spaces[i] = space

	space:subscribe("aerospace_workspace_change", function(env)
		local focused = env.FOCUSED_WORKSPACE == sid
		local prev = env.PREV_WORKSPACE == sid
		if focused or prev then
			space:set({
				icon = { color = focused and colors_spaces[i] or colors.tn_black1 },
				background = {
					height = 25,
					color = focused and colors.with_alpha(colors_spaces[i], 0.3) or colors.transparent,
					corner_radius = focused and 6 or 0,
				},
			})
		end
	end)

	space:subscribe("mouse.clicked", function(env)
		sbar.exec("aerospace workspace " .. sid)
	end)
end

-- Bracket for all workspace items
local space_names = {}
for i, space in ipairs(spaces) do
	space_names[i] = space.name
end

sbar.add("bracket", space_names, {
	background = {
		color = colors.background,
		border_color = colors.accent3,
		border_width = 2,
	},
})

-- Update app icons for all workspaces
local function update_workspace_icons()
	sbar.exec("aerospace list-windows --all --format '%{workspace}|%{app-name}'", function(result)
		local workspace_apps = {}
		for _, sid in ipairs(workspace_ids) do
			workspace_apps[sid] = {}
		end

		for line in string.gmatch(result, "[^\r\n]+") do
			local ws, app = string.match(line, "^(.-)|(.+)$")
			if ws and app and workspace_apps[ws] then
				workspace_apps[ws][app] = true
			end
		end

		for i, sid in ipairs(workspace_ids) do
			local icon_line = ""
			local has_apps = false
			for app, _ in pairs(workspace_apps[sid]) do
				has_apps = true
				local lookup = app_icons[app]
				local icon = ((lookup == nil) and app_icons["default"] or lookup)
				icon_line = icon_line .. utf8.char(0x202F) .. icon
			end

			if not has_apps then
				icon_line = "—"
			end

			sbar.animate("tanh", 10, function()
				spaces[i]:set({
					label = icon_line,
					icon = { color = has_apps and colors_spaces[i] or colors.tn_black1 },
				})
			end)
		end
	end)
end

-- Initial state: highlight focused workspace
sbar.exec("aerospace list-workspaces --focused", function(focused_ws)
	focused_ws = focused_ws:gsub("%s+", "")
	for i, sid in ipairs(workspace_ids) do
		local focused = (focused_ws == sid)
		spaces[i]:set({
			icon = { color = focused and colors_spaces[i] or colors.tn_black1 },
			background = {
				height = 25,
				color = focused and colors.with_alpha(colors_spaces[i], 0.3) or colors.transparent,
				corner_radius = focused and 6 or 0,
			},
		})
	end
end)

-- Observer for workspace changes to update app icons
local workspace_observer = sbar.add("item", {
	drawing = false,
	updates = true,
})

workspace_observer:subscribe("aerospace_workspace_change", function(env)
	update_workspace_icons()
end)

-- Initial icon update
update_workspace_icons()

sbar.add("item", { width = 6 })

local spaces_indicator = sbar.add("item", {
	background = {
		color = colors.with_alpha(colors.grey, 0.0),
		border_color = colors.with_alpha(colors.bg1, 0.0),
		border_width = 0,
		corner_radius = 6,
		height = 24,
		padding_left = 6,
		padding_right = 6,
	},
	icon = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = 14.0,
		},
		padding_left = 6,
		padding_right = 9,
		color = colors.accent1,
		string = icons.switch.on,
	},
	label = {
		drawing = "off",
		padding_left = 0,
		padding_right = 0,
	},
})

spaces_indicator:subscribe("swap_menus_and_spaces", function(env)
	local currently_on = spaces_indicator:query().icon.value == icons.switch.on
	spaces_indicator:set({
		icon = currently_on and icons.switch.off or icons.switch.on,
	})
end)

spaces_indicator:subscribe("mouse.entered", function(env)
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			background = {
				color = colors.tn_black1,
				border_color = { alpha = 1.0 },
				padding_left = 6,
				padding_right = 6,
			},
			icon = {
				color = colors.accent1,
				padding_left = 6,
				padding_right = 9,
			},
			label = { drawing = "off" },
			padding_left = 6,
			padding_right = 6,
		})
	end)
end)

spaces_indicator:subscribe("mouse.exited", function(env)
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			background = {
				color = { alpha = 0.0 },
				border_color = { alpha = 0.0 },
			},
			icon = { color = colors.accent1 },
			label = { width = 0 },
		})
	end)
end)

spaces_indicator:subscribe("mouse.clicked", function(env)
	sbar.trigger("swap_menus_and_spaces")
end)

local front_app_icon = sbar.add("item", "front_app_icon", {
	display = "active",
	icon = { drawing = false },
	label = {
		font = "sketchybar-app-font-bg:Regular:21.0",
	},
	updates = true,
	padding_right = 0,
	padding_left = -10,
})

front_app_icon:subscribe("front_app_switched", function(env)
	local icon_name = env.INFO
	local lookup = app_icons[icon_name]
	local icon = ((lookup == nil) and app_icons["default"] or lookup)
	front_app_icon:set({ label = { string = icon, color = colors.accent1 } })
end)

sbar.add("bracket", {
	spaces_indicator.name,
	front_app_icon.name,
}, {
	background = {
		color = colors.tn_black3,
		border_color = colors.accent1,
		border_width = 2,
	},
})
