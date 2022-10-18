local S = ...

jonez.chisel = {
	chiselable = {},
	group_style_index = {},
	group_style_nodes = {},
	player_copied_style = {},
}

function jonez.chisel.register_chiselable(node_name, group_name, style)
	jonez.chisel.chiselable[node_name] = {}
	jonez.chisel.chiselable[node_name].group_name = group_name
	jonez.chisel.chiselable[node_name].style = style

	if not jonez.chisel.group_style_nodes[group_name] then
		jonez.chisel.group_style_nodes[group_name] = {}
	end

	jonez.chisel.group_style_nodes[group_name][style] = node_name
end

function jonez.chisel.register_chiselable_stair_and_slab(node_subname, group_subname, style)
	jonez.chisel.register_chiselable("stairs:stair_" .. node_subname, "stairs:stair_" .. group_subname, style)
	jonez.chisel.register_chiselable("stairs:stair_inner_" .. node_subname, "stairs:stair_inner_" .. group_subname, style)
	jonez.chisel.register_chiselable("stairs:stair_outer_" .. node_subname, "stairs:stair_outer_" .. group_subname, style)
	jonez.chisel.register_chiselable("stairs:slab_" .. node_subname, "stairs:slab_" .. group_subname, style)
end

local function chisel_interact(player, pointed_thing, is_right_click)
	if pointed_thing.type ~= "node" then
		return
	end

	local pos = pointed_thing.under
	local is_sneak = player and player:get_player_control().sneak or false
	local player_name = player and player:get_player_name()

	-- A true player is required
	if not player_name then
		return
	end

	-- Check for node protection
	if minetest.is_protected(pos, player_name) then
		-- minetest.chat_send_player(player_name, "You're not authorized to alter nodes in this area")
		minetest.record_protection_violation(pos, player_name)
		return
	end

	-- Retrieve group info and styles
	local node = minetest.get_node(pos)
	local node_name = node.name

	if not jonez.chisel.chiselable[node_name] then
		minetest.chat_send_player(player_name, S("Dláto neumí pracovat s tímto blokem"))
		return
	end

	local group_name = jonez.chisel.chiselable[node_name].group_name
	local style = jonez.chisel.chiselable[node_name].style
	local group = jonez.chisel.group_style_nodes[group_name]
	local new_style, new_node_name

	-- Now branch on the four user-input cases
	if is_right_click then
		if is_sneak then
			-- Copy style
			jonez.chisel.player_copied_style[player_name] = style
			minetest.chat_send_player(player_name, S("Dláto nastaveno na styl @1", S(jonez.style_names[style] or "neznámý")))
			return
		else
			-- Paste style
			new_style = jonez.chisel.player_copied_style[player_name]
			if not new_style then
				minetest.chat_send_player(player_name, S("Dláto není nastaveno. Použijte Shift + pravý klik na vhodný blok."))
				return
			end

			-- Already the correct style, exit now!
			if new_style == style then
				return
			end

			new_node_name = group[new_style]
			if not new_node_name then
				minetest.chat_send_player(player_name, S("Styl @1 není podporován skupinou @2", S(jonez.style_names[new_style] or "neznámý"), group_name))
				return
			end
		end
	else
		if is_sneak then
			-- Backward cycle mode
			for k,v in pairs(group) do
				if v == node_name then break end
				new_style = k
				new_node_name = v
			end

			if new_node_name == nil then
				-- Not found? Go for the last element
				for k,v in pairs(group) do
					new_style = k
					new_node_name = v
				end
			end
		else
			-- Forward cycle mode
			new_style , new_node_name = next(group,style)
			if new_node_name == nil then
				new_style , new_node_name = next(group)
			end
		end
	end

	-- Check if rotation could be preserved
	local nodedef = minetest.registered_nodes[node_name]
	local new_nodedef = minetest.registered_nodes[new_node_name]
	local rotation , new_rotation

	if nodedef and new_nodedef then
		if ( nodedef.paramtype2 == "facedir" or nodedef.paramtype2 == "colorfacedir" )
			and( new_nodedef.paramtype2 == "facedir" or new_nodedef.paramtype2 == "colorfacedir" ) then
				rotation = node.param2 % 32		--rotation are on the last 5 digits
		end
	end

	-- Set the new node
	minetest.set_node(pos, {name= new_node_name})
	local new_node = minetest.get_node(pos)

	-- Copy rotation if needed!
	if rotation ~= nil then
		new_rotation = new_node.param2 % 32

		if new_rotation ~= rotation then
			new_node.param2 = new_node.param2 - new_rotation + rotation
			minetest.swap_node(pos, new_node)
		end
	end

	minetest.sound_play("jonez_carve", {pos = pos, gain = 0.5, max_hear_distance = 5})
end

--The chisel to carve the marble
minetest.register_tool("jonez:chisel", {
	description = S("dláto"),
	_ch_help = "nástroj na opracování mramoru a kamene; levým klikem na podporované bloky změníte jejich styl;\nShift + pravým klikem si zapamatuje styl klinutého bloku\na pravým klikem pak tento styl aplikujete na další bloky",
	inventory_image = "jonez_chisel.png",
	wield_image = "jonez_chisel.png^[transformR180",
	on_use = function(itemstack, player, pointed_thing)
		chisel_interact(player, pointed_thing, false)
		return ch_core.add_wear(player, itemstack, 200)
	end,
	on_place = function(itemstack, player, pointed_thing)
		chisel_interact(player, pointed_thing, true)
		return ch_core.add_wear(player, itemstack, 200)
	end,
})

minetest.register_craft({
	type = "shaped",
	output = "jonez:chisel",
	recipe = {
		{"", "", "default:diamond"},
		{"", "default:steel_ingot", ""},
		{"default:stick", "", ""},
	}
})

if minetest.get_modpath("unified_inventory") then
	unified_inventory.register_craft_type("jonez:chisel", {
		description = S("dláto"),
		icon = "jonez_chisel.png",
		width = 1,
		height = 1,
	})

	minetest.register_on_mods_loaded(function()
		for _, group in pairs(jonez.chisel.group_style_nodes) do
			local prev_node
			local first_node

			for _, node in pairs(group) do
				if not first_node then
					first_node = node
				end
				if prev_node then
					minetest.log("info", ("[jonez] chisel recipe %s -> %s"):format(node, prev_node))
					unified_inventory.register_craft({
						type = "jonez:chisel",
						output = node,
						items = {prev_node},
						width = 1,
					})
				end
				prev_node = node
			end

			unified_inventory.register_craft({
				type = "jonez:chisel",
				output = first_node,
				items = {prev_node},
				width = 1,
			})
		end
	end)
end

if minetest.get_modpath("i3") then
	i3.register_craft_type("jonez:chisel", {
		description = S("dláto"),
		icon = "jonez_chisel.png",
	})

	minetest.register_on_mods_loaded(function()
		for _, group in pairs(jonez.chisel.group_style_nodes) do
			local prev_node
			local first_node

			for _, node in pairs(group) do
				if not first_node then
					first_node = node
				end
				if prev_node then
					i3.register_craft({
						type = "jonez:chisel",
						result = node,
						items = {prev_node},
					})
				end
				prev_node = node
			end

			i3.register_craft({
				type = "jonez:chisel",
				result = first_node,
				items = {prev_node},
			})
		end
	end)
end
