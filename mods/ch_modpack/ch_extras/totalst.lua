--ts Total Station

local def
-- local empty_table = {}
local default_tool_sounds = {breaks = "default_tool_breaks"}
local has_technic = minetest.get_modpath("technic")
local max_charge = 20000
local power_usage = 100

local ch_help = "Zeměměřičský nástroj k vyměřování vzdáleností a úhlů.\nLevý klik přičte vzdálenost od předchozího bodu, Aux1+levý klik začne nové měření,\npravý klik provede měření nanečisto."
local ch_help_group = "tot_stat2"

if has_technic then
	ch_help = ch_help.."\nElektrický nástroj — před použitím nutno nabít."
end

local function get_vector(meta, suffix)
	return vector.new(meta:get_int("x"..suffix), meta:get_int("y"..suffix), meta:get_int("z"..suffix))
end

local function set_vector(meta, suffix, xyz)
	meta:set_int("x"..suffix, xyz.x)
	meta:set_int("y"..suffix, xyz.y)
	meta:set_int("z"..suffix, xyz.z)
end

local function ts_work(player_name, itemstack, new_pos, mode)
	local meta = itemstack:get_meta()

	-- Fetch and update data
	local orig_count, sum = meta:get_int("count"), meta:get_float("sum")
	local pos1, pos0

	if orig_count >= 2 then
		pos1 = get_vector(meta, "1")
	end
	if orig_count >= 1 then
		pos0 = get_vector(meta, "0")
		set_vector(meta, "1", pos0)
	end
	set_vector(meta, "0", new_pos)
	local count = orig_count + 1
	meta:set_int("count", count)

	-- Compute sum and angle
	local dist0
	if orig_count >= 1 then
		dist0 = vector.distance(new_pos, pos0)
		sum = sum + dist0
		meta:set_float("sum", sum)
	end
	local angle
	if orig_count >= 2 then
		angle = vector.angle(vector.subtract(pos1, pos0), vector.subtract(pos0, new_pos))
	end

	-- Display values to the user
	if player_name then
		local pos0c = pos0 or new_pos
		local result = string.format("Totální stanice: Bod č. %d: úsečka = %.3f m (dx=%d,dy=%d,dz=%d), celkem %.3f m, úhel posl. 2 úseček: %d°.",
	                             count, dist0 or 0, new_pos.x - pos0c.x, new_pos.y - pos0c.y, new_pos.z - pos0c.z, sum, angle and math.round(angle * 180 / 3.14159265358979323846) or 0)
		ch_core.systemovy_kanal(player_name, result)
	end

	return itemstack
end

local function on_use(itemstack, user, pointed_thing)
	local player_name, meta, technic_meta, charge

	player_name = user and user:get_player_name()
	if not player_name or pointed_thing.type ~= "node" then
		return
	end
	meta = itemstack:get_meta()
	if has_technic then
		technic_meta = minetest.deserialize(meta:get_string("")) or {}
		charge = (technic_meta.charge or 0) - power_usage
		if charge < 0 then
			return
		end
	end
	local controls = user:get_player_control()
	if controls.aux1 then
		-- reset
		local meta = itemstack:get_meta()
		meta:set_int("count", 0)
		meta:set_float("sum", 0)
		meta:set_int("x1", 0)
		meta:set_int("y1", 0)
		meta:set_int("z1", 0)
	end
	ts_work(player_name, itemstack, pointed_thing.under, "on_use")

	if has_technic and not minetest.is_creative_enabled(player_name) then
		technic_meta.charge = charge
		technic.set_RE_wear(itemstack, charge, max_charge)
		meta:set_string("", minetest.serialize(technic_meta))
	end
	return itemstack
end

local function on_place(itemstack, placer, pointed_thing)
	local player_name, meta, technic_meta, charge

	player_name = placer and placer:get_player_name()
	if not player_name or pointed_thing.type ~= "node" then
		return
	end
	meta = itemstack:get_meta()
	if has_technic then
		technic_meta = minetest.deserialize(meta:get_string("")) or {}
		charge = (technic_meta.charge or 0) - power_usage
		if charge < 0 then
			return
		end
	end
	ts_work(player_name, ItemStack(itemstack), pointed_thing.under, "on_place")

	if has_technic and not minetest.is_creative_enabled(player_name) then
		technic_meta.charge = charge
		technic.set_RE_wear(itemstack, charge, max_charge)
		meta:set_string("", minetest.serialize(technic_meta))
	end

	return itemstack
end

def = {
	description = "totální stanice",
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
	inventory_image = "ch_extras_total_station.png",
	sound = default_tool_sounds,
	groups = {tool = 1},
	on_use = on_use,
	on_place = on_place,
}
if has_technic then
	def.wear_represents = "technic_RE_charge"
	def.on_refill = technic.refill_RE_charge
end

minetest.register_tool("ch_extras:total_station", def)

if has_technic then
	technic.register_power_tool("ch_extras:total_station", max_charge)
end

minetest.register_craft({
	output = "ch_extras:total_station",
	recipe = {
		{"basic_materials:plastic_sheet", "basic_materials:ic", "basic_materials:plastic_sheet"},
		{"basic_materials:plastic_sheet", "basic_materials:energy_crystal_simple", "basic_materials:plastic_sheet"},
		{"basic_materials:steel_bar", "basic_materials:steel_bar", "basic_materials:steel_bar"},
	}
})
