-- PERISKOP
local periskop_step, periskop_max = 25, 250

local function periskop_cancel(player, online_charinfo)
	if online_charinfo.periskop ~= nil then
		local oeo = online_charinfo.periskop.orig_eye_offset
		player:set_eye_offset(oeo[1], oeo[2], oeo[3])
		online_charinfo.periskop = nil
	end
end

local function periskop_use(player, button)
	local player_name = player:get_player_name() or ""
	if player_name == "" then return end
	local online_charinfo = ch_data.online_charinfo[player_name]
	if online_charinfo == nil then
		return
	end
	if online_charinfo.periskop == nil then
		-- první použití
		local a, b, c = player:get_eye_offset()
		online_charinfo.periskop = {
			orig_eye_offset = {a, b, c},
			cancel = function() return periskop_cancel(player, online_charinfo) end,
		}
		player:set_eye_offset(vector.new(0, periskop_step, 0), b, c)
		ch_core.systemovy_kanal(player_name, "periskop: +5 metrů")
	else
		local a, b, c = player:get_eye_offset()
		if button ~= "left" then
			a.y = math.max(a.y - periskop_step, periskop_step)
		else
			a.y = math.min(a.y + periskop_step, periskop_max)
		end
		player:set_eye_offset(a, b, c)
		ch_core.systemovy_kanal(player_name, "periskop: +"..((a.y - 25) * 0.1 + 5).." metrů")
	end
end

local def = {
	description = "periskop",
	inventory_image = "ch_extras_periskop.png",
	wield_image = "ch_core_white_pixel.png^[opacity:0",
	range = 0,
	liquids_pointable = false,
	pointabilities = {nodes = {
		["group:cracky"] = false,
		["group:snappy"] = false,
		["group:crumbly"] = false,
		["group:oddly_breakable_by_hand"] = false,
		["group:dig_immediate"] = false,
	}, objects = {}},
	groups = {tool = 1},
	_ch_help = "když periskop držíte v ruce, umožní vám shlížet na svět z výšky,\n"..
"ačkoliv se ve skutečnosti pohybujete stále po zemi;\n"..
"levý klik = +2,5 metru, pravý klik = -2,5 metru, přepnout na jiný předmět = vypnout;\n"..
"periskop můžete skombinovat s dalekohledem (klávesou Z)",
	_ch_help_group = "chperisk",
	on_use = function(itemstack, user, pointed_thing)
		periskop_use(user, "left")
	end,
	on_place = function(itemstack, placer, pointed_thing)
		periskop_use(placer, "right")
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		periskop_use(user, "right")
	end,
}
minetest.register_tool("ch_extras:periskop", def)
minetest.register_craft{
	output = "ch_extras:periskop",
	recipe = {
		{"", "default:copper_ingot", "default:copper_ingot"},
		{"", "default:copper_ingot", ""},
		{"default:copper_ingot", "default:copper_ingot", ""},
	},
}
