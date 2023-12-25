print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modpath = minetest.get_modpath("compactor")
compactor = {}

technic.register_recipe_type("compacting", {description = "průmyslové lisování"})

function compactor.register_compactor_recipe(data)
    data.time = data.time or 1
    technic.register_recipe("compacting", data)
end

function compactor.register_compactor(data)
    data.typename = "compacting"
    data.machine_name = "compactor"
    data.machine_desc = minetest.translate("technic", "@1 Compactor", "%s")
    technic.register_base_machine(data)
end

function compactor.register_block_recipes_override(ingot_name, ingot_count, block_name, options)
	if options == nil then
		options = {}
	end
	local crafts = {}
	if options.clear_ingots_to_block then
		crafts["i-to-"..block_name] = {output = block_name}
	end
	if options.clear_block_to_ingots then
		crafts[block_name.."-to-i"] = {recipe = {{block_name}}}
	end
	ch_core.clear_crafts("compactor", crafts)

	compactor.register_compactor_recipe({input = {ingot_name.." "..ingot_count}, output = block_name})
	if not options.not_craft_block_to_ingots then
		minetest.register_craft({output = ingot_name.." "..ingot_count, recipe = {{block_name}}})
	end
end

compactor.register_compactor({tier = "LV", demand = {100}, speed = 1})

minetest.register_craft({
    output = "compactor:lv_compactor",
    recipe = {
        {"technic:marble", "basic_materials:motor", "technic:granite"},
        {"pipeworks:autocrafter", "technic:machine_casing", "mesecons_pistons:piston_normal_off"},
        {"basic_materials:brass_ingot", "technic:lv_cable", "default:bronze_ingot"},
    },
})

compactor.register_compactor({tier = "MV", demand = {300, 250, 200}, speed = 2, upgrade = 1, tube = 1})

minetest.register_craft({
    output = "compactor:mv_compactor",
    recipe = {
        {"technic:stainless_steel_ingot", "compactor:lv_compactor", "technic:stainless_steel_ingot"},
        {"pipeworks:tube_1", "technic:mv_transformer", "pipeworks:tube_1"},
        {"technic:stainless_steel_ingot", "technic:mv_cable", "technic:stainless_steel_ingot"},
    },
})

dofile(modpath.."/recipes.lua")

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
