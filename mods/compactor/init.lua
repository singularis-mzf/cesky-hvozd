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

function compactor.register_block_recipes_override(ingot_name, ingot_count, block_name, clear_ingots_to_block, clear_block_to_ingots)
	local crafts = {}
	if clear_ingots_to_block then
		crafts["i-to-"..block_name] = {output = block_name}
	end
	if clear_block_to_ingots then
		crafts[block_name.."-to-i"] = {recipe = {{block_name}}}
	end
	ch_core.clear_crafts("compactor", crafts)
	--[[
	craft_result = minetest.get_craft_result({method = "normal", width = 1, items = {block_stack}})
	if not craft_result.item:is_empty() then
		craft_result = ch_core.clear_crafts("compactor", {{type = "shapeless", recipe = {block_name}}}) > 0
	end ]]
	--[[ craft_result = minetest.get_craft_result({method = "shapeless", width = 1, items = {block_stack}})
	if not craft_result.item:is_empty() then
		craft_result = minetest.clear_craft({type = "shapeless", recipe = {block_name}})
	end ]]

	compactor.register_compactor_recipe({input = {ingot_name.." "..ingot_count}, output = block_name})
	minetest.register_craft({output = ingot_name.." "..ingot_count, recipe = {{block_name}}})
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
