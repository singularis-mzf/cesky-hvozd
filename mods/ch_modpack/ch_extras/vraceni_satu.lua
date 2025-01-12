-- regál na vracení šatů
local def = {
	description = "regál na vracení šatů",
	drawtype = "nodebox",
	tiles = {{name = "default_wood.png^[transformR90^[colorize:#f0f0f0:192", backface_culling = true}},
	paramtype2 = "color4dir",
	palette = "unifieddyes_palette_color4dir.png",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.5 - 1/16, 0.5, 1.5, 0.5}, -- zadní stěna
			{-0.5, -0.5, 0.0, 0.5, -0.5 + 1 /16, 0.5 - 1/16}, -- spodní stěna
			{-0.5, 1.5 - 1/16, 0.0, 0.5, 1.5, 0.5 - 1/16}, -- horní stěna
			{-0.5, -0.5 + 1/16, 0.0, -0.5 + 1/16, 1.5 - 1/16, 0.5 - 1/16}, -- levá stěna
			{0.5 - 1/16, -0.5 + 1/16, 0.0, 0.5, 1.5 - 1/16, 0.5 - 1/16}, -- pravá stěna
			{-0.5 + 1/16, 1.2, 0.2, 0.5 - 1/16, 1.2 + 1/32, 0.2 + 1/16}, -- tyč
		},
	},
	groups = {oddly_breakable_by_hand = 2, ud_param2_colorable = 1, flammable = 2},
	is_ground_content = false,
	on_construct = function(pos)
		minetest.get_meta(pos):set_string("infotext", "vracení šatů a obuvi po vyzkoušení\n(pravý klik => dostanete zpět plnou cenu)")
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if not minetest.is_player(clicker) then
			return
		end
		local player_name = clicker:get_player_name()
		if itemstack:get_count() ~= 1 then
			return
		end
		local name = itemstack:get_name()
		if minetest.get_item_group(name, "clothing") == 0 and minetest.get_item_group(name, "cape") == 0 then
			return -- není oblečení
		end
		local meta = itemstack:get_meta()
		if meta:get_int("ch_buy_id") == 0 then
			ch_core.systemovy_kanal(player_name, "Tyto šaty nejsou označeny k vyzkoušení.")
			return
		end
		local now = ch_time.aktualni_cas():znamka32()
		local buy_timestamp = meta:get_int("ch_buy_timestamp")
		if now - buy_timestamp > 600 then
			ch_core.systemovy_kanal(player_name, "Na vrácení je příliš pozdě. Tyto šaty byly vydány obchodním terminálem před "..math.floor((now - buy_timestamp) / 60).." minutami.")
			return
		end
		-- vrátit peníze
		local price = meta:get_int("ch_buy_price")
		if price > 0 then
			local success, errors = ch_core.pay_to(player_name, price, {label = "vrácení vyzkoušených šatů"})
			if not success then
				ch_core.systemovy_kanal(player_name, "Vrácení peněz selhalo.")
				minetest.log("warning", "ch_core.pay_to() failed to pay "..price.." to "..player_name.."!\n"..dump2(errors))
				return
			end
		end
		itemstack:get_meta():set_string("description", "")
		ch_core.systemovy_kanal(player_name, "Vráceno: "..(itemstack:get_description() or ""))
		return ItemStack()
	end,
}
minetest.register_node("ch_extras:vraceni_satu", def)
minetest.register_craft{
	output = "ch_extras:vraceni_satu",
	recipe = {
		{"homedecor:wardrobe", "default:mese_crystal_fragment"},
		{"default:mese_crystal_fragment", ""},
	},
}

-- pás na potvrzení nákupu šatů

local tile
if minetest.get_modpath("bakedclay") then
	tile = {name = "baked_clay_black.png", backface_culling = true}
else
	tile = {name = "default_clay.png", color = "#202020", backface_culling = true}
end

local fields = {
	"ch_buy_id",
	"ch_buy_price",
	"ch_buy_timestamp",
	"count_alignment",
	"count_meta",
	"description",
}

def = {
	description = "pás na potvrzení nákupu šatů",
	drawtype = "nodebox",
	tiles = {tile},
	paramtype2 = "leveled",
	node_box = {
		type = "leveled",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.5 + 2/16, 0.5},
	},
	groups = {cracky = 2},
	is_ground_content = false,
	place_param2 = 4,
	on_construct = function(pos)
		minetest.get_meta(pos):set_string("infotext", "potvrzení nákupu šatů a obuvi\n(pravý klik => potvrdíte nákup)")
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if not minetest.is_player(clicker) then
			return
		end
		local player_name = clicker:get_player_name()
		if itemstack:get_count() ~= 1 then
			return
		end
		local name = itemstack:get_name()
		if minetest.get_item_group(name, "clothing") == 0 and minetest.get_item_group(name, "cape") == 0 then
			return -- není oblečení
		end
		local meta = itemstack:get_meta()
		if meta:get_int("ch_buy_id") == 0 then
			ch_core.systemovy_kanal(player_name, "Tyto šaty nejsou označeny k vyzkoušení.")
			return
		end
		local meta_table = meta:to_table()
		local meta_fields = meta_table.fields
		for _, key in ipairs(fields) do
			meta_fields[key] = nil
		end
		meta:from_table(meta_table)
		ch_core.systemovy_kanal(player_name, "Nákup potvrzen: "..(itemstack:get_description() or ""))
		return itemstack
	end,
}

minetest.register_node("ch_extras:potvrzeni_nakupu_satu", def)

minetest.register_craft{
	output = "ch_extras:potvrzeni_nakupu_satu",
	recipe = {
		{"bakedclay:black", "bakedclay:black"},
		{"", ""},
	},
}
