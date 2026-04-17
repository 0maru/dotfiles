local settings = require("settings")
local colors = require("colors")

-- Japanese day of week
local day_of_week_ja = { "日", "月", "火", "水", "木", "金", "土" }

local cal = sbar.add("item", "widgets.calendar", {
	icon = { drawing = false },
	label = {
		color = colors.tn_blue,
		font = { family = settings.font.numbers },
		padding_left = 10,
		padding_right = 10,
	},
	position = "right",
	update_freq = 1,
})

sbar.add("bracket", "widgets.calendar.bracket", { cal.name }, {
	background = {
		color = colors.tn_black3,
		border_color = colors.tn_blue,
	},
})

sbar.add("item", { position = "right", width = settings.group_paddings })

cal:subscribe({ "forced", "routine", "system_woke" }, function(env)
	local wday = tonumber(os.date("%w")) + 1
	local date_str = os.date("%m月%d日") .. "(" .. day_of_week_ja[wday] .. ") " .. os.date("%H:%M")
	cal:set({ label = date_str })
end)

sbar.add("item", { position = "right", width = 6 })
