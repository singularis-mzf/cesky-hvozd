local S = minetest.get_translator("ch_decor")
local has_mesecons = minetest.get_modpath("mesecons")
local common_def, def

local lanterns = {
	blue = {
		description = "modrá ozdobná lampa",
		dye = "dye:blue",
	},
	green = {
		description = "zelená ozdobná lampa",
		dye = "dye:green",
	},
	red = {
		description = "červená ozdobná lampa",
		dye = "dye:red",
	},
	yellow = {
		description = "žlutá ozdobná lampa",
		dye = "dye:yellow",
	},
	red_green_yellow = {
		description = "trojbarevná ozdobná lampa",
		dye1 = "dye:red", dye2 = "dye:green", dye3 = "dye:yellow",
	},
}

local function switch_node_to(pos, node, new_node_name, player)
	if node.name == new_node_name then
		return true -- no change
	end
	if player ~= nil and minetest.is_player(player) then
		-- check protection:
		local player_name = player:get_player_name()
		if minetest.is_protected(pos, player_name) then
			minetest.record_protection_violation(pos, player_name)
			return false
		end
	end
	node.name = new_node_name
	minetest.swap_node(pos, node)
	return true
end

local function switch_node_on(pos, node, puncher, pointed_thing)
	local ndef = minetest.registered_nodes[node.name]
	if not ndef then return end -- bad block
	local new_node_name = ndef._ch_node_on
	if new_node_name ~= nil then
		switch_node_to(pos, node, new_node_name, puncher)
	end
end

local function switch_node_off(pos, node, puncher, pointed_thing)
	local ndef = minetest.registered_nodes[node.name]
	if not ndef then return end -- bad block
	local new_node_name = ndef._ch_node_off
	if new_node_name ~= nil then
		switch_node_to(pos, node, new_node_name, puncher)
	end
end

local groups_normal = {cracky = 3, oddly_breakable_by_hand = 3}
local groups_lit = table.copy(groups_normal)
groups_lit.not_in_creative_inventory = 1
local node_box_full = {type = "fixed", fixed = {-0.499, -0.499, -0.499, 0.499, 0.499, 0.499}}

node_box_full = {type = "fixed", fixed = {-0.4, -0.4, -0.4, 0.4, 0.4, 0.4}} -- DEBUG

local box = {
	type = "fixed",
	fixed = {-0.375, -0.5, -0.375, 0.375, 0.25, 0.375},
}

local mesecons
if has_mesecons then
	mesecons = {
		effector = {
			action_off = switch_node_off,
			action_on = switch_node_on,
			rules = mesecon.rules.default,
		}
	}
end

for id, ldef in pairs(lanterns) do
	local normal_lantern = "stoneblocks:stoneblocks_lantern_"..id
	local lit_lantern = "stoneblocks:stoneblocks_lantern_"..id.."_lit"

	common_def = {
		description = assert(ldef.description),
		drawtype = "mesh",
		mesh = "ch_decor_lantern.obj",
		selection_box = box,
		collision_box = box,
		paramtype = "light",
		paramtype2 = "facedir",

		is_ground_content = false,
		sunlight_propagates = true,
		sounds = default.node_sound_glass_defaults(),
		_ch_node_off = normal_lantern,
		_ch_node_on = lit_lantern,
	}

	if has_mesecons ~= nil then
		common_def.mesecons = mesecons
	end

	def = table.copy(common_def)
	-- def.drawtype = "nodebox"
	-- def.node_box = node_box_full
	-- def.selection_box = node_box_full
	def.tiles = {
		{name = "stoneblocks_lantern_"..id..".png^[opacity:200", backface_culling = true},
	}
	def.use_texture_alpha = "blend"
	def.groups = groups_normal
	def.on_punch = switch_node_on

	minetest.register_node(":"..normal_lantern, def)

	-- Lit lantern:
	def = table.copy(common_def)
	def.tiles = {{name = "stoneblocks_lantern_"..id.."_lit.png", backface_culling = true}}
	def.groups = groups_lit
	def.light_source = 11
	def._ch_alt_node = normal_lantern
	def.on_punch = switch_node_off
	def.drop = normal_lantern

	minetest.register_node(":"..lit_lantern, def)

	if ldef.dye ~= nil then
		minetest.register_craft{
			output = normal_lantern,
			recipe = {
				{"", ldef.dye, ""},
				{"", "moreblocks:glow_glass", ""},
				{ldef.dye, "", ldef.dye},
			},
		}
	elseif ldef.dye1 ~= nil and ldef.dye2 ~= nil and ldef.dye3 ~= nil then
		minetest.register_craft{
			output = normal_lantern,
			recipe = {
				{"", ldef.dye1, ""},
				{"", "moreblocks:glow_glass", ""},
				{ldef.dye2, "", ldef.dye3},
			},
		}
	end
end

if not minetest.registered_nodes["stoneblocks:stoneblocks_lantern_blue"] then
	error("TEST")
end
