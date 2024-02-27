print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
local modpath = minetest.get_modpath(minetest.get_current_modname())

local function repair_stack(stack) -- => stack, message
	local stack_name = stack:get_name()
	if stack_name == "default:dirt" then
		stack:set_name("default:snow")
		return stack, "opraveno"
	elseif minetest.registered_items[stack_name] ~= nil then
		return stack, "tento předmět není neznámý či zastaralý"
	else
		minetest.log("warning", "Unkrep cannot repair item: "..stack_name)
		return stack, "tento předmět neumím opravit, obraťte se s ním na Administraci"
	end
end

local tile_front = {name = "ch_unkrep_front.png", backface_culling = true}
local tile_other = {name = "ch_unkrep.png", backface_culling = true}

local function get_formspec(custom_state)
	local pos = custom_state.pos
	local formspec =
		ch_core.formspec_header{
			formspec_version = 4,
			size = {10.5, 13.25},
			auto_background = true,
		}..
		"item_image[0.5,0.5;1,1;ch_unkrep:machine]"..
		"label[1.75,1.0;opravna neznámých a zastaralých předmětů]"..
		"list[nodemeta:"..pos.x.."\\,"..pos.y.."\\,"..pos.z..
		";main;0.4,2.25;8,2;]"..
		"button[0.4,4.75;2,0.75;opravit;opravit]"..
		"textarea[0.4,5.75;9.75,2;;;"..
		minetest.formspec_escape(custom_state.message)..
		"]"..
		"list[current_player;main;0.4,8;8,4;]"..
		"listring[]"..
		"button_exit[9.5,0.25;0.75,0.75;zavrit;x]"..
		"tooltip[zavrit;zavřít okno]"
	return formspec
end

local function formspec_callback(custom_state, player, formname, fields)
	if fields.opravit then
		local inv = minetest.get_meta(custom_state.pos):get_inventory()
		local list = inv:get_list("main")
		local messages = {}
		for i, stack in ipairs(list) do
			if not stack:is_empty() then
				local new_stack, message = repair_stack(stack)
				list[i] = new_stack
				table.insert(messages, "["..i.."] "..message)
			end
		end
		inv:set_list("main", list)
		custom_state.message = table.concat(messages, "\n")
		return get_formspec(custom_state)
	end
end

local def = {
	description = "opravna neznámých a zastaralých předmětů",
	drawtype = "normal",
	tiles = {tile_other, tile_other, tile_other, tile_other, tile_other, tile_front},
	paramtype = "none",
	paramtype2 = "4dir",
	groups = {cracky = 3},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		meta:set_string("infotext", "opravna neznámých a zastaralých předmětů")
		inv:set_size("main", 8 * 2)
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if not minetest.is_player(clicker) then return end
		local player_role = ch_core.get_player_role(clicker)
		if player_role == "new" then return end
		local custom_state = {
			pos = pos,
			message = "",
		}
		ch_core.show_formspec(clicker, "ch_unkrep:machine", get_formspec(custom_state), formspec_callback, custom_state, {})
	end,
}

minetest.register_node("ch_unkrep:machine", def)

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
