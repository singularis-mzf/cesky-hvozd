if not minetest.get_modpath("unifieddyes") then
	return
end
minetest.override_item("default:stone", {
	paramtype2 = "color",
	palette = "unifieddyes_palette_bright_extended.png",
})

local get_us_time = minetest.get_us_time
local pos_to_string = minetest.pos_to_string
local swap_node = minetest.swap_node
local get_gametime = minetest.get_gametime

local last_message_us = 0
local total_count = 0

local gametime_limit = 753800 - 1000
local gametime = 0

local function globalstep(dtime)
	gametime = get_gametime()
end

minetest.register_globalstep(globalstep)

local cache = {}

minetest.register_lbm{
	label = "Colored Stone Test",
	name = "ch_test:colored_stone_test_1",
	nodenames = {"default:stone"},
	run_at_every_load = true,
	action = function(pos, node, dtime_s)
		if gametime - dtime_s >= gametime_limit then return end

		if cache[dtime_s] == nil then
			cache[dtime_s] = true
			print("new dtime_s "..dtime_s.." at position "..pos_to_string(pos)..", gametime = "..(get_gametime() or "nil"))
		end
		total_count = total_count + 1
		local us = get_us_time()
		if us - last_message_us > 1000000 then
			last_message_us = us
			print("Total count: "..total_count)
		end
		if node.param2 == 0 then
			node.param2 = math.random(1, 255)
			swap_node(pos, node)
		end
	end,
}
