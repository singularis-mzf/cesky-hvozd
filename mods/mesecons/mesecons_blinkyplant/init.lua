-- The BLINKY_PLANT

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local minimal_interval = 0.2
local default_interval = 3

local allowed_fractions = {
	[0.2] = true,
	[0.25] = true,
	[0.3] = true,
	[0.4] = true,
	[0.5] = true,
}
local allowed_fractions_desc = {}

for f, _ in pairs(allowed_fractions) do
	table.insert(allowed_fractions_desc, f)
end
table.sort(allowed_fractions_desc)
for i, v in pairs(allowed_fractions_desc) do
	allowed_fractions_desc[i] = tostring(v):gsub("[.]", ",")
end
allowed_fractions_desc = table.concat(allowed_fractions_desc, "   ")

-- => is_enabled, interval, interval_string
local function get_bplant_info(meta)
	local raw_interval = meta:get_float("interval")
	local is_enabled, interval
	if math.abs(raw_interval) < minimal_interval then
		is_enabled, interval = raw_interval >= 0.0, default_interval
	else
		is_enabled, interval = raw_interval >= 0.0, math.abs(raw_interval)
	end
	return is_enabled, interval, tostring(interval):gsub("[.](.?[^0]?).*$", ",%1")
end

local function get_formspec(pos, meta, player)
	local is_enabled, interval, interval_string = get_bplant_info(meta)
	local is_locked = meta:get_int("locked") ~= 0
	local owner = meta:get_string("owner")
	local is_registered_player = minetest.check_player_privs(player, "ch_registered_player")
	local formspec = {
		"formspec_version[4]",
		"size[8,7]",
		"item_image[0.25,0.25;1,1;mesecons_blinkyplant:blinky_plant_off]",
		"label[1.5,0.75;mrkající květina]",
		"label[0.25,1.75;vlastník/ice: ", ch_core.prihlasovaci_na_zobrazovaci(owner), "]",
		"label[0.25,2.5;mrká: ", is_enabled and "ano" or "ne", "]",
		"label[0.25,3.25;počítadlo: ", meta:get_int("counter"), "]",
		"label[0.25,4.0;zamčena: ", is_locked and "ano" or "ne", "]",
		"label[0.25,4.75;interval \\[s\\]:]",
		"field[2,4.5;1.5,0.5;interval;;", minetest.formspec_escape(interval_string), "]",
	}
	if is_registered_player and is_enabled then
		table.insert(formspec, "button[3.0,2.1;3,0.75;vyp;vypnout mrkání]")
	end
	if is_registered_player and (not is_locked or owner == "" or player:get_player_name() == owner or minetest.check_player_privs(player, "protection_bypass")) then
		-- owner interface
		local s
		if not is_enabled then
			table.insert(formspec, "button[3.0,2.1;3,0.75;zap;zapnout mrkání]")
		end
		table.insert(formspec, "button[3.0,2.85;3,0.75;reset;vynulovat počítadlo]")
		if is_locked then
			s = "unlock;odemknout květinu"
		else
			s = "lock;zamknout květinu"
		end
		table.insert(formspec, "button[3.0,3.55;3,0.75;")
		table.insert(formspec, s)
		table.insert(formspec, "]")
		table.insert(formspec, "button[3.75,4.4;3,0.75;setinterval;nastavit interval]")
		table.insert(formspec, "label[0.25,5.5;Povolena jsou pouze kladná celá čísla a tyto hodnoty:]")
		table.insert(formspec, "label[0.25,6.0;")
		table.insert(formspec, allowed_fractions_desc)
		table.insert(formspec, "]")
	end
	return table.concat(formspec)
end

local function get_infotext(meta)
	local line_1 = tostring(meta:get_int("counter"))
	local line_3 = ch_core.prihlasovaci_na_zobrazovaci(meta:get_string("owner"))
	local flags = {}
	local is_enabled, interval, interval_string = get_bplant_info(meta)

	if meta:get_int("locked") ~= 0 then
		table.insert(flags, "zamčena")
		line_3 = "vlastník/ice: "..line_3
	else
		line_3 = "květinu zasadil/a: "..line_3
	end
	if not is_enabled then
		table.insert(flags, "vypnuta")
	end
	table.insert(flags, interval_string.."s")
	local line_2 = "<"..table.concat(flags, ", ")..">"
	return line_1.."\n"..line_2.."\n"..line_3
end

local function set_counter(meta, new_value)
	meta:set_int("counter", new_value)
	meta:set_string("infotext", get_infotext(meta))
end

local function toggle_timer(pos)
	local timer = minetest.get_node_timer(pos)
	if timer:is_started() then
		timer:stop()
	else
		local meta = minetest.get_meta(pos)
		local is_enabled, interval = get_bplant_info(meta)
		if is_enabled then
			timer:start(interval)
		end
	end
end

local function on_timer(pos)
	local node = minetest.get_node(pos)
	local flipstate = mesecon.flipstate(pos, node)
	print("on_timer() called with node = "..node.name..", flipstate == "..flipstate)
	if flipstate == "on" then
		mesecon.receptor_on(pos)
	else
		mesecon.receptor_off(pos)
	end
	toggle_timer(pos)
	local meta = minetest.get_meta(pos)
	local counter = meta:get_int("counter") + 1
	meta:set_int("counter", counter)
	meta:set_string("infotext", get_infotext(meta))
end

--[[
metadata:
int counter -- počítadlo přepnutí
int locked -- je soukromá?
float interval -- interval časovače, záporný znamená, že květina je vypnutá

string infotext

]]

local function on_construct(pos)
	local meta = minetest.get_meta(pos)
	meta:set_int("locked", 1)
	meta:set_float("interval", default_interval)
	toggle_timer(pos)
end

local function set_interval(pos, new_interval)
	local meta = minetest.get_meta(pos)
	local timer = minetest.get_node_timer(pos)
	local is_enabled, current_interval = get_bplant_info(meta)
	if is_enabled then
		local timeout, elapsed = timer:get_timeout(), timer:get_elapsed()
		meta:set_float("interval", new_interval)
		meta:set_string("infotext", get_infotext(meta))
		local new_elapsed = math.min(elapsed, new_interval - 0.05)
		timer:set(new_interval, new_elapsed)
	else
		meta:set_float("interval", -new_interval)
		meta:set_string("infotext", get_infotext(meta))
		timer:stop()
		local node = minetest.get_node(pos)
		node.name = "mesecons_blinkyplant:blinky_plant_off"
		minetest.swap_node(pos, node)
		mesecon.receptor_off(pos)
	end
	return new_interval
end

local function after_place_node(pos, placer, itemstack, pointed_thing)
	local player_name = placer and placer:get_player_name()
	if player_name ~= nil and player_name ~= "" then
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", player_name)
	end
end

local function can_dig(pos, player)
	local player_name = player and player:get_player_name()

	if not player_name then
		return false -- only player can dig this
	end
	if minetest.is_protected(pos, player_name) then
		minetest.record_protection_violation(pos, player_name)
		return false
	end
	local meta = minetest.get_meta(pos)
	local owner, locked = meta:get_string("owner"), meta:get_int("locked")
	if locked ~= 0 and not minetest.check_player_privs(player, "protection_bypass") and owner ~= "" and owner ~= player_name then
		return false
	end
	return true
end

local function formspec_callback(custom_state, player, formname, fields)
	if fields.quit then
		return false
	end
	local player_name = player:get_player_name()
	local pos = custom_state.pos
	local node = minetest.get_node(pos)
	if node.name ~= "mesecons_blinkyplant:blinky_plant_off"
	  and node.name ~= "mesecons_blinkyplant:blinky_plant_on" then
		return false -- invalid node
	end
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	local update_infotext = false
	local is_locked = meta:get_int("locked") ~= 0

	if fields.vyp then
		-- disable the blinky plant
		local is_enabled, interval = get_bplant_info(meta)
		meta:set_float("interval", -interval)
		set_interval(pos, interval)
		update_infotext = true
		minetest.log("action", player_name.." disabled blinky plant owned by "..owner.." at "..minetest.pos_to_string(pos))
	end

	if not is_locked or owner == "" or owner == player_name or minetest.check_player_privs(player_name, "protection_bypass") then
		if not fields.vyp and fields.zap then
			local is_enabled, interval = get_bplant_info(meta)
			meta:set_float("interval", interval)
			set_interval(pos, interval)
			update_infotext = true
			minetest.log("action", player_name.." enabled blinky plant owned by "..owner.." at "..minetest.pos_to_string(pos))
		elseif fields.reset then
			meta:set_int("counter", 0)
			update_infotext = true
			minetest.log("action", player_name.." reset blinky plant counter owned by "..owner.." at "..minetest.pos_to_string(pos))
		elseif fields.lock then
			meta:set_int("locked", 1)
			update_infotext = true
		elseif fields.unlock then
			meta:set_int("locked", 0)
			update_infotext = true
		elseif fields.setinterval then
			local new_interval = fields.interval:gsub(",", ".")
			new_interval = tonumber(new_interval)
			if new_interval ~= nil then
				local check = math.round(new_interval)
				if new_interval >= 0 and (allowed_fractions[new_interval] or new_interval == check) then
					minetest.log("action", "[blinky_plant @ "..minetest.pos_to_string(pos).."] interval will be set to "..new_interval)
					set_interval(pos, new_interval)
					update_infotext = true
				else
					ch_core.systemovy_kanal(player_name, "Chyba! "..fields.interval.." není platná a povolená hodnota intervalu v sekundách!")
				end
			end
		end
	end
	if update_infotext then
		meta:set_string("infotext", get_infotext(meta))
	end
	return get_formspec(pos, meta, player)
end

local function on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local player_name = clicker and clicker:get_player_name()
	if not player_name then
		return
	end
	ch_core.show_formspec(clicker, "mesecons_blinkyplant:blinky_plant", get_formspec(pos, minetest.get_meta(pos), clicker), formspec_callback, {pos = pos}, {})
end

mesecon.register_node("mesecons_blinkyplant:blinky_plant", {
	description="mrkající květina",
	drawtype = "plantlike",
	inventory_image = "jeija_blinky_plant_off.png",
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	sounds = mesecon.node_sound.leaves,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, -0.5+0.7, 0.3},
	},
	on_timer = on_timer,
	on_rightclick = on_rightclick,
	on_construct = on_construct,
	after_place_node = after_place_node,
	can_dig = can_dig,
},{
	tiles = {"jeija_blinky_plant_off.png"},
	groups = {dig_immediate=3},
	mesecons = {receptor = { state = mesecon.state.off }}
},{
	tiles = {"jeija_blinky_plant_on.png"},
	groups = {dig_immediate=3, not_in_creative_inventory=1},
	mesecons = {receptor = { state = mesecon.state.on }}
})

minetest.register_craft({
	output = "mesecons_blinkyplant:blinky_plant_off 1",
	recipe = {	{"","group:mesecon_conductor_craftable",""},
			{"","group:mesecon_conductor_craftable",""},
			{"group:sapling","group:sapling","group:sapling"}}
})

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
