local ifthenelse = ch_core.ifthenelse

local function on_place(itemstack, placer, pointed_thing)
	if not minetest.is_player(placer) then
		return nil
	end
	if pointed_thing.type == "node" then
		local player_name = placer:get_player_name()
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		local pile_level = minetest.get_item_group(node.name, "wood_pile")
		if pile_level > 0 and pile_level < 4 and node.name:sub(1, -2) == itemstack:get_name():sub(1, -2) then
			-- addable pile of the same type
			if minetest.is_protected(pos, player_name) then
				minetest.record_protection_violation(pos, player_name)
				return
			end
			node.name = node.name:sub(1, -2)..(pile_level + 1)
			minetest.swap_node(pos, node)
			if minetest.is_creative_enabled(player_name) then
				return
			end
			itemstack:take_item()
			return itemstack
		end
	end
	return minetest.item_place(itemstack, placer, pointed_thing)
end

local function on_punch(pos, node, puncher, pointed_thing)
	if not minetest.is_player(puncher) then
		return nil
	end
	local player_name = puncher:get_player_name()
	local pile_level = minetest.get_item_group(node.name, "wood_pile")
	if pile_level > 0 then
		if minetest.is_protected(pos, player_name) then
			minetest.record_protection_violation(pos, player_name)
			return
		end
		if pile_level == 1 then
			minetest.node_dig(pos, node, puncher)
			return
		end
		local player_inv = puncher:get_inventory()
		local drop_stack = ItemStack(node.name:sub(1,-2).."1")
		if not minetest.is_creative_enabled(player_name) or not player_inv:contains_item("main", drop_stack) then
			if not player_inv:add_item("main", drop_stack):is_empty() then
				return
			end
		end
		node.name = node.name:sub(1, -2)..(pile_level - 1)
		minetest.swap_node(pos, node)
		return
	end
	return minetest.node_punch(pos, node, puncher, pointed_thing)
end

local function generate_pile_textures(top_texture, side_texture, noise_color)
	local top, side, middle = {"[combine:128x128"}, {"[combine:128x128"}, {"[combine:128x1"}

	top_texture = top_texture.."\\^[resize\\:64x64"
	side_texture = side_texture.."\\^[resize\\:64x64"
	if noise_color ~= nil then
		top_texture = top_texture.."\\^(ch_core_wood_noise_64.png\\^[multiply\\:"..noise_color..")"
	end
	for i = 0, 64, 64 do
		for j = 0, 64, 64 do
			table.insert(top, ":"..i..","..j.."="..side_texture)
			table.insert(side, ":"..i..","..j.."="..top_texture..":"..i..","..j.."=("..side_texture.."\\^[transformR90\\^[mask\\:ch_extras_pile_mask64.png)")
		end
		table.insert(middle, ":"..i..",-32="..top_texture)
	end
	table.insert(top, "^ch_extras_pile_overlay_top.png")
	table.insert(side, "^ch_extras_pile_overlay_side.png")
	table.insert(middle, "^[resize:128x128")
	if noise_color ~= nil then
		table.insert(middle, "^(ch_core_wood_noise_64.png^[multiply:"..noise_color.."^[resize:128x128)")
	end
	table.insert(middle, "^ch_extras_pile_overlay_top.png^[transformR270")
	top, side, middle = table.concat(top), table.concat(side), table.concat(middle)
	local tile_top = {name = top, backface_culling = true}
	local tile_top_R90 = {name = top.."^[transformR90", backface_culling = true}
	local tile_middle = {name = middle, backface_culling = true}
	local tile_side = {name = side, backface_culling = true}
	local tile_side_R180 = {name = side.."^[transformR180", backface_culling = true}
	return {
		tiles_even = {
			tile_top, -- top (+Y)
			tile_top_R90, -- bottom (-Y)
			tile_side, -- front (+X)
			tile_side, -- back (-X)
			tile_side_R180, -- right (+Z)
			tile_side_R180, -- left (-Z)
		},
		tiles_odd = {
			tile_middle, -- top (+Y)
			tile_top_R90, -- bottom (-Y)
			tile_side, -- front (+X)
			tile_side, -- back (-X)
			tile_side_R180, -- right (+Z)
			tile_side_R180, -- left (-Z)
		},
	}
end

local wood_pile_boxes = {
	{type = "fixed", fixed =  {-0.5, -0.5, -0.5, 0.5, -0.5 + 1 / 4, 0.5}},
	{type = "fixed", fixed =  {-0.5, -0.5, -0.5, 0.5, -0.5 + 2 / 4, 0.5}},
	{type = "fixed", fixed =  {-0.5, -0.5, -0.5, 0.5, -0.5 + 3 / 4, 0.5}},
	{type = "fixed", fixed =  {-0.5, -0.5, -0.5, 0.5, -0.5 + 4 / 4, 0.5}},
}
local wood_pile_groups = {
	{oddly_breakable_by_hand = 1, flammable = 1, wood_pile = 1},
	{oddly_breakable_by_hand = 1, flammable = 1, wood_pile = 2, not_in_creative_inventory = 1},
	{oddly_breakable_by_hand = 1, flammable = 1, wood_pile = 3, not_in_creative_inventory = 1},
	{oddly_breakable_by_hand = 1, flammable = 1, wood_pile = 4, not_in_creative_inventory = 1},
}

function ch_extras.register_woodpiles(name, def)
	--[[
		def = {
			top_texture = string,
			side_texture = string,
			tree_node = string,
			noise_color = string or nil,
			burntime = int or nil,
		}
	]]
	assert(def.top_texture)
	assert(def.side_texture)
	local wood_desc
	if def.tree_node == nil then
		wood_desc = "dřevo"
	elseif (minetest.registered_nodes[def.tree_node] or {}).description ~= nil then
		wood_desc = minetest.registered_nodes[def.tree_node].description
	else
		minetest.log("warning", "register_woodpiles() ignored, because expected tree node "..def.tree_node.." is not registered!")
		return
	end
	local t = generate_pile_textures(def.top_texture, def.side_texture, def.noise_color)
	for i = 1, 4 do
		local desc = "hromada dřeva: "..wood_desc
		local ndef = {
			description = desc,
			tiles = ifthenelse(i % 2 == 0, t.tiles_even, t.tiles_odd),
			drawtype = "nodebox",
			paramtype = "light",
			paramtype2 = "facedir",
			node_box = wood_pile_boxes[i],
			selection_box = wood_pile_boxes[i],
			collision_box = wood_pile_boxes[i],
			groups = wood_pile_groups[i],
			drop = "ch_extras:woodpile_"..name.."_1 "..i,
			is_ground_content = false,
			node_placement_prediction = "",
			sounds = default.node_sound_wood_defaults(),
			on_punch = on_punch,
			_ch_node_viewname = desc..ifthenelse(i == 1, " (1 vrstva)"," ("..i.." vrstvy)"),
		}
		if i == 1 then
			ndef.on_place = on_place
		end
		if i == 4 then
			ndef.drawtype = "normal"
			ndef.node_box = nil
			ndef.selection_box = nil
			ndef.collision_box = nil
		end
		minetest.register_node("ch_extras:woodpile_"..name.."_"..i, ndef)
	end
	minetest.register_craft{
		output = "ch_extras:woodpile_"..name.."_1 3",
		recipe = {
			{def.tree_node, def.tree_node, def.tree_node},
			{"", "", ""},
			{"", "", ""},
		},
	}
	minetest.register_craft{
		type = "fuel",
		recipe = "ch_extras:woodpile_"..name.."_1",
		burntime = def.burntime or 20,
	}
end

if minetest.get_modpath("charcoal") then
	minetest.register_craft{
		type = "cooking",
		output = "charcoal:charcoal 2",
		recipe = "group:wood_pile",
		cooktime = 8,
	}
end

ch_extras.register_woodpiles("jungletree", {
	side_texture = "default_jungletree.png",
	top_texture = "default_jungletree_top.png",
	tree_node = "default:jungletree",
	noise_color = "#280d06",
	burntime = 38,
})

ch_extras.register_woodpiles("aspen", {
	side_texture = "default_aspen_tree.png",
	top_texture = "default_aspen_tree_top.png",
	tree_node = "default:aspen_tree",
	noise_color = "#cba988",
	burntime = 22,
})

--[[
-- STARÝ KÓD PRO HROMADY 3x3:

local function generate_pile_textures()
	local indices = {0, 32, 64}
	local indices2 = {0,}
	local top_pile = {"[combine:96x96"}
	local side_pile = {"[combine:96x96"}

	for i = 0, 64, 32 do
		for j = 0, 64, 32 do
			table.insert(top_pile, ":"..i..","..j.."=@side\\^[resize\\:32x32")
			table.insert(side_pile, ":"..i..","..j.."=@top\\^[resize\\:32x32") -- \\^(@side\\^[resize\\:32x32\\^[transformR90\\^[mask\\:ch_extras_pile_mask.png)
		end
	end
	for i = 0, 64, 32 do
		table.insert(top_pile, ":"..i..",0=ch_extras_pile_overlay.png")
		table.insert(side_pile, ":"..i..",0=ch_extras_pile_overlay.png")
	end
	for i = 0, 64, 32 do
		for j = 0, 64, 32 do
			table.insert(side_pile, ":"..i..","..j.."=(@side\\^[resize\\:32x32\\^[transformR90\\^[mask\\:ch_extras_pile_mask.png)")
		end
	end
	table.insert(side_pile, "^[transformR90^[combine:96x96")
	for i = 0, 80, 16 do
		table.insert(side_pile, ":"..i..",0=ch_extras_pile_overlay.png")
	end
	table.insert(side_pile, "^[transformR270")
	return table.concat(top_pile), table.concat(side_pile)
end

local top_pile, side_pile = generate_pile_textures()

top_pile = top_pile:gsub("@top", "default_jungletree_top.png"):gsub("@side", "default_jungletree.png")
side_pile = side_pile:gsub("@top", "default_jungletree_top.png"):gsub("@side", "default_jungletree.png")

local tile_top = {name = top_pile, backface_culling = true}
local tile_top_R90 = {name = top_pile.."^[transformR90", backface_culling = true}
local tile_top_R270 = {name = top_pile.."^[transformR270", backface_culling = true}
local tile_side = {name = side_pile, backface_culling = true}
local tile_side_R180 = {name = side_pile.."^[transformR180", backface_culling = true}

local tiles_even = {
	tile_top, -- top (+Y)
	tile_top_R90, -- bottom (-Y)
	tile_side, -- front (+X)
	tile_side, -- back (-X)
	tile_side_R180, -- right (+Z)
	tile_side_R180, -- left (-Z)
}
local tiles_odd = {
	tile_top_R270, -- top (+Y)
	tile_top_R90, -- bottom (-Y)
	tile_side, -- front (+X)
	tile_side, -- back (-X)
	tile_side_R180, -- right (+Z)
	tile_side_R180, -- left (-Z)
}
local common_def = {
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "4dir", -- => color4dir
	groups = {oddly_breakable_by_hand = 1, wood_pile = 1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
}

for i = 1, 6 do
	local box = {
		type = "fixed",
		fixed =  {-0.5, -0.5, -0.5, 0.5, -0.5 + i / 6, 0.5},
	}
	local def = table.copy(common_def)
	def.description = "testovací hromada dřeva A "..i.."/6 [EXPERIMENTÁLNÍ]"
	if i % 2 == 0 then
		def.tiles = tiles_even
	else
		def.tiles = tiles_odd
	end
	def.node_box = box
	def.selection_box = box
	def.collision_box = box
	minetest.register_node("ch_extras:test_woodpile_"..i, def)
end
]]
