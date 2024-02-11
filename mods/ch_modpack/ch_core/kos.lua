ch_core.open_submod("kos", {lib = true})

local player_name_to_trash_inv = {}
local trash_inv_width, trash_inv_height = 4, 2

local function return_zero()
	return 0
end

local function on_take(inv, listname, index, stack, player)
	local s = stack:to_string()
	s = s:sub(1, 1024)
	minetest.log("action", player:get_player_name().." retreived from the trash bin: "..s)
end

local inv_callbacks = {
	allow_move = return_zero,
	allow_put = return_zero,
	-- allow_take = yes,
	on_take = on_take,
}

local function on_joinplayer(player, _last_login)
	local player_name = player:get_player_name()
	local trash_inv = minetest.create_detached_inventory("ch_core_trash_"..player_name, inv_callbacks, player_name)
	trash_inv:set_size("main", trash_inv_width * trash_inv_height)
	player_name_to_trash_inv[player_name] = trash_inv
end

local function on_leaveplayer(player, _timeouted)
	local player_name = player:get_player_name()
	minetest.remove_detached_inventory("ch_core_trash_"..player_name)
	player_name_to_trash_inv[player_name] = nil
end

minetest.register_on_joinplayer(on_joinplayer)
minetest.register_on_leaveplayer(on_leaveplayer)

--[[
	Vrací nil, pokud pro danou postavu inventář koše neexistuje.
	Jinak vrací:
	{
		inventory = InvRef,
		location = string,
		listname = string,
		width = int,
		height = int,
	}
]]
function ch_core.get_trash_inventory(player_name)
	local result = {
		inventory = player_name_to_trash_inv[player_name],
		location = "detached:ch_core_trash_"..player_name,
		listname = "main",
		width = trash_inv_width,
		height = trash_inv_height,
	}
	if result.inventory ~= nil then
		return result
	end
end

--[[
	Smaže obsah zadaného inventáře a zaznamená to jako příkaz daného
	hráče/ky.
	player_name -- přihlašovací jméno hráče/ky nebo nil
	inv -- odkaz na inventář
	listname -- listname ke smazání
	description -- heslovitý popis kontextu mazání
]]
function ch_core.vyhodit_inventar(player_name, inv, listname, description)
	if not player_name then
		player_name = "???"
	end
	if not description then
		description = "???"
	end
	local t = inv:get_list(listname)
	if t == nil then
		return false
	end
	local craftitems, tools, item_strings = {}, {}, {}
	for _, stack in ipairs(t) do
		if not stack:is_empty() then
			if stack:get_stack_max() <= 1 then
				table.insert(tools, stack)
			else
				table.insert(craftitems, stack)
			end
			table.insert(item_strings, stack:to_string():sub(1, 1024))
		end
	end

	if #item_strings > 0 then
		minetest.log("action", "Player "..player_name.." trashed "..#item_strings.." items ("..description.."): "..table.concat(item_strings, ", "))
		local empty_list = {}
		inv:set_list(listname, empty_list)
		if player_name ~= "???" then

			-- Trash inventory:
			local trash_inv = player_name_to_trash_inv[player_name]
			if trash_inv ~= nil then
				local old_trash_list = trash_inv:get_list("main")
				trash_inv:set_list("main", empty_list)
				for i = #tools, 1, -1 do
					trash_inv:add_item("main", tools[i])
				end
				for i = #craftitems, 1, -1 do
					trash_inv:add_item("main", craftitems[i])
				end
				for i = #old_trash_list, 1, -1 do
					local stack = old_trash_list[i]
					if not stack:is_empty() then
						trash_inv:add_item("main", stack)
					end
				end
				if not trash_inv:is_empty("main") then
					old_trash_list = trash_inv:get_list("main")
					local n = 1
					while n < #old_trash_list and not old_trash_list[n + 1]:is_empty() do
						n = n + 1
					end
					-- reverse the list:
					for i = 1, math.floor(n / 2) do
						old_trash_list[i], old_trash_list[1 + n - i] = old_trash_list[1 + n - i], old_trash_list[i]
					end
					trash_inv:set_list("main", old_trash_list)
				end
			else
				minetest.log("warning", "Player "..player_name.." has no trash inventory!")
			end

			local trash_sound
			if #item_strings == 1 then
				trash_sound = ch_core.trash_one_sound
			else
				trash_sound = ch_core.trash_all_sound
			end
			if trash_sound ~= nil and trash_sound ~= "" then
				minetest.sound_play(trash_sound, { to_player = player_name, gain = 1.0 })
			else
				minetest.chat_send_all("Will not play the sound, because: "..dump2({trash_one_sound = ch_core.trash_one_sound, trash_all_sound = ch_core.trash_all_sound, trash_sound = trash_sound or "nil"}))
			end
		end
	end
	return true
end

function ch_core.vyhodit_predmet(player_name, stack, description)
	if not player_name then
		player_name = "???"
	end
	if not description then
		description = "???"
	end
	if stack == nil or stack:is_empty() then
		return false
	end
	minetest.log("action", "Player "..player_name.." trashed an item ("..description.."): "..stack:to_string():sub(1, 1024))
	local trash_inv = player_name_to_trash_inv[player_name]
	if trash_inv == nil then
		minetest.log("warning", "Player "..player_name.." has no trash inventory!")
	elseif trash_inv:room_for_item("main", stack) then
		trash_inv:add_item("main", stack)
	else
		-- shift the inventory:
		local list = trash_inv:get_list("main")
		for i = 1, #list - 1 do
			list[i] = list[i + 1]
		end
		list[#list] = stack
		trash_inv:set_list("main", list)
	end
	local trash_sound = ch_core.trash_one_sound
	if trash_sound ~= nil and trash_sound ~= "" then
		minetest.sound_play(trash_sound, { to_player = player_name, gain = 1.0 })
	end
	return true
end

-- přepsat minetest.item_drop:
local old_minetest_item_drop = minetest.item_drop
function minetest.item_drop(itemstack, dropper, pos)
	if minetest.is_player(dropper) then
		local player_name = assert(dropper:get_player_name())
		local offline_charinfo = ch_core.offline_charinfo[player_name]
		if
			offline_charinfo ~= nil and
			offline_charinfo.discard_drops ~= nil and
			offline_charinfo.discard_drops == 1 and
			ch_core.get_trash_inventory(player_name) ~= nil
		then
			ch_core.vyhodit_predmet(player_name, itemstack, "item_drop")
			return ItemStack()
		end
	end
	return old_minetest_item_drop(itemstack, dropper, pos)
end

ch_core.close_submod("kos")
