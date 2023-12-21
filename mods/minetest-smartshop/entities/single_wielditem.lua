
local v_add = vector.add
local v_mul = vector.multiply

local add_entity = minetest.add_entity
local get_node = minetest.get_node
local pos_to_string = minetest.pos_to_string

local element_dir = smartshop.entities.element_dir
local entity_offset = smartshop.entities.entity_offset

local element_offset = {
    { vector.new(0.2, 0.2, -0.1), vector.new(-0.2, 0.2, -0.1),
      vector.new(0.2, -0.2, -0.1), vector.new(-0.2, -0.2, -0.1) },

    { vector.new(-0.1, 0.2, 0.2), vector.new(-0.1, 0.2, -0.2),
      vector.new(-0.1, -0.2, 0.2), vector.new(-0.1, -0.2, -0.2) },

    { vector.new(-0.2, 0.2, 0.1), vector.new(0.2, 0.2, 0.1),
      vector.new(-0.2, -0.2, 0.1), vector.new(0.2, -0.2, 0.1) },

    { vector.new(0.1, 0.2, -0.2), vector.new(0.1, 0.2, 0.2),
      vector.new(0.1, -0.2, -0.2), vector.new(0.1, -0.2, 0.2) },
}

for i = 4, 23, 1 do
	local dir = minetest.facedir_to_dir(i)
	local rotation = vector.dir_to_rotation(vector.multiply(dir, -1))
	local input = element_offset[1]
	local output = {}
	for j = 1, 4, 1 do
		output[j] = vector.offset(vector.rotate(input[j], rotation), -0.25 * dir.x, 0.15 * dir.y, -0.25 * dir.z)
	end
	element_offset[i + 1] = output
end

-- for nodebox and mesh drawtypes without an inventory image, which can't be drawn well otherwise
minetest.register_entity("smartshop:single_wielditem", {
	initial_properties = {
		visual = "wielditem",
		visual_size = {x = .20, y = .20},
		collisionbox = {0, 0, 0, 0, 0, 0},
		physical = false,
		textures = {"air"},
		static_save = false,
	},
	smartshop2 = true,
})

function smartshop.entities.add_single_wielditem(shop, index)
	local shop_pos = shop.pos
	local param2 = get_node(shop_pos).param2
	local item_name = shop:get_give_stack(index):get_name()

	local dir = element_dir[param2 + 1]
    local base_pos = v_add(shop_pos, v_mul(dir, entity_offset))
    local offset = element_offset[param2 + 1][index]
	local entity_pos = v_add(base_pos, offset)

	local obj = add_entity(entity_pos, "smartshop:single_wielditem")
	if not obj then
		smartshop.log("warning", "could not create single_wielditem for %s @ %s", item_name, pos_to_string(shop_pos))
		return
	end

	obj:set_rotation(smartshop.util.facedir_to_rotation(param2))
	-- obj:set_yaw(math.pi * (2 - (param2 / 2)))
	obj:set_properties({wield_item = item_name})

	local entity = obj:get_luaentity()

	entity.pos = shop_pos
	entity.index = index
	entity.item = item_name

	return obj
end
