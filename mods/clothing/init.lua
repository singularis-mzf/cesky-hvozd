ch_base.open_mod(minetest.get_current_modname())
local modpath = minetest.get_modpath(minetest.get_current_modname())


dofile(modpath.."/api.lua")
dofile(modpath.."/clothing.lua")
dofile(modpath.."/character.lua")

-- Inventory mod support

if minetest.get_modpath("inventory_plus") then
	clothing.inv_mod = "inventory_plus"
	clothing.formspec = clothing.formspec..
		"button[6,0;2,0.5;main;Zpět]"
elseif minetest.get_modpath("unified_inventory") and
		not unified_inventory.sfinv_compat_layer then
	--[[
  local S = clothing.translator
  local F = minetest.formspec_escape
  local ui = unified_inventory

	clothing.inv_mod = "unified_inventory"
	unified_inventory.register_button("clothing", {
		type = "image",
		image = "inventory_plus_clothing.png",
		tooltip = S("Clothing"),
	})
	unified_inventory.register_page("clothing", {
		get_formspec = function(player, perplayer_formspec)
      local fy = perplayer_formspec.form_header_y + 0.5
      local gridx = perplayer_formspec.std_inv_x
      local gridy = 0.6
			local name = player:get_player_name()
      local formspec = perplayer_formspec.standard_inv_bg..
        perplayer_formspec.standard_inv..
        ui.make_inv_img_grid(gridx, gridy, 3, 3)..
        string.format("label[%f,%f;%s]",
          perplayer_formspec.form_header_x, perplayer_formspec.form_header_y, F(S("Clothing")))..
        string.format("list[detached:%s_clothing;clothing;%f,%f;3,3;]",
				name, gridx + ui.list_img_offset, gridy + ui.list_img_offset) ..
				"listring[current_player;main]"..
				"listring[detached:"..name.."_clothing;clothing]"
			return {formspec=formspec}
		end,
	})
	]]
elseif minetest.get_modpath("sfinv") then
	clothing.inv_mod = "sfinv"
	sfinv.register_page("clothing:clothing", {
		title = S("Clothing"),
		get = function(self, player, context)
			local name = player:get_player_name()
			local formspec = clothing.formspec..
				"list[detached:"..name.."_clothing;clothing;0,0.5;3,3;]"..
				"listring[current_player;main]"..
				"listring[detached:"..name.."_clothing;clothing]"
			return sfinv.make_formspec(player, context,
				formspec, false)
		end
	})
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	if clothing.inv_mod == "inventory_plus" and fields.clothing then
		inventory_plus.set_inventory_formspec(player, clothing.formspec..
			"list[detached:"..name.."_clothing;clothing;0,0.5;3,3;]"..
			"listring[current_player;main]"..
			"listring[detached:"..name.."_clothing;clothing]")
	end
end)

local function is_clothing(item)
	return minetest.get_item_group(item, "clothing") > 0 or
		minetest.get_item_group(item, "cape") > 0
end

local function save_clothing_metadata(player, clothing_inv)
	local player_inv = player:get_inventory()
	local is_empty = true
	local clothes = {}
	for i = 1, 9 do
		local stack = clothing_inv:get_stack("clothing", i)
		-- Move all non-clothes back to the player inventory
		if not stack:is_empty() and not is_clothing(stack:get_name()) then
			player_inv:add_item("main",
				clothing_inv:remove_item("clothing", stack))
			stack:clear()
		end
		if not stack:is_empty() then
			clothes[i] = stack:to_string()
			is_empty = false
		end
	end
  local player_meta = player:get_meta();
	if is_empty then
		player_meta:set_string("clothing:inventory", nil)
	else
		player_meta:set_string("clothing:inventory",
			minetest.serialize(clothes))
	end
end

local function load_clothing_metadata(player, clothing_inv, is_new)
	local player_inv = player:get_inventory()
	local player_meta = player:get_meta()
	local clothing_meta = player_meta:get_string("clothing:inventory")
	local clothes = clothing_meta and minetest.deserialize(clothing_meta)
	local dirty_meta = false
	if not clothes then
		if is_new then
			clothes = {"clothing:shirt_green", "clothing:pants_blue", "clothing:shoes_black"}
		else
			clothes = {}
		end
		dirty_meta = true
	end
	if not clothing_meta then
		-- Backwards compatiblity
		for i = 1, 9 do
			local stack = player_inv:get_stack("clothing", i)
			if not stack:is_empty() then
				clothes[i] = stack:to_string()
				dirty_meta = true
			end
		end
	end
	-- Fill detached slots
	clothing_inv:set_size("clothing", 9)
	for i = 1, 9 do
		clothing_inv:set_stack("clothing", i, clothes[i] or "")
		clothing:run_callbacks("on_load", player, i, ItemStack(clothes[i]))
	end

	if dirty_meta then
		-- Requires detached inventory to be set up
		save_clothing_metadata(player, clothing_inv)
	end

	-- Clean up deprecated garbage after saving
	player_inv:set_size("clothing", 0)
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local player_inv = player:get_inventory()
	local clothing_inv = minetest.create_detached_inventory(name.."_clothing",{
		on_put = function(inv, listname, index, stack, player)
			save_clothing_metadata(player, inv)
			clothing:run_callbacks("on_equip", player, index, stack)
			clothing:set_player_clothing(player)
		end,
		on_take = function(inv, listname, index, stack, player)
			save_clothing_metadata(player, inv)
			clothing:run_callbacks("on_unequip", player, index, stack)
			clothing:set_player_clothing(player)
		end,
		on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			save_clothing_metadata(player, inv)
			clothing:set_player_clothing(player)
		end,
		allow_put = function(inv, listname, index, stack, player)
			local item = stack:get_name()
			if is_clothing(item) then
				return 1
			end
			return 0
		end,
		allow_take = function(inv, listname, index, stack, player)
			return stack:get_count()
		end,
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			return count
		end,
	}, name)
	if clothing.inv_mod == "inventory_plus" then
		inventory_plus.register_button(player,"clothing", S("Clothing"))
	end

	local is_new = ch_data.get_offline_charinfo(name).past_playtime == 0.0
	load_clothing_metadata(player, clothing_inv, is_new)
	minetest.after(1, function(name)
		-- Ensure the ObjectRef is valid after 1s
		clothing:set_player_clothing(minetest.get_player_by_name(name))
	end, name)
end)

-- custom API methods

function clothing.add_clothing(self, player, stack)
	local name = player:get_player_name()
	local item = stack:get_name()
	if not is_clothing(item) then
		return stack
	end
	local clothing_inv = minetest.get_inventory({type = "detached", name = name.."_clothing"})
	local list_size = clothing_inv:get_size("clothing")
	for index = 1, list_size do
		if clothing_inv:get_stack("clothing", index):is_empty() then
			clothing_inv:set_stack("clothing", index, stack)
			save_clothing_metadata(player, clothing_inv)
			clothing:run_callbacks("on_equip", player, index, stack)
			clothing:set_player_clothing(player)
			return ItemStack()
		end
	end
	return stack
end

-- self: clothing; player: player ObjectRef; inv: clothing inventory (detached)
function clothing.update_player_skin_from_inv(self, player, inv)
	save_clothing_metadata(player, inv)
	clothing:set_player_clothing(player)
end

ch_base.close_mod(minetest.get_current_modname())
