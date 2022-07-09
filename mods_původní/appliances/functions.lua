
--local S = appliances.translator

local use_craftguide = nil;
if minetest.global_exists("craftguide") then
  use_craftguide = craftguide;
end
if minetest.global_exists("hades_craftguide2") then
  use_craftguide = hades_craftguide2;
end

-- help function for swap appliance node
-- typicaly between active and inactive appliance
function appliances.swap_node(pos, name)
  local node = minetest.get_node(pos);
  if (node.name == name) then
    return
  end
  node.name = name;
  minetest.swap_node(pos, node);
end

function appliances.swap_stack(stack, name)
  local stack_name = stack:get_name()
  if (stack_name == name) then
    return
  end
  local meta = stack:get_meta()
  local meta_table = meta:to_table()
  local wear = stack:get_wear()
  stack:set_name(name)
  if wear>0 then
    stack:set_wear(wear)
  end
  meta = stack:get_meta()
  meta:from_table(meta_table)
end

appliances.random = PcgRandom(os.time());

--
-- {
--   description = "", -- description text
--   icon = "", -- path to icon file, can be nil
--   width = 1, -- width of recipe (unified only)
--   height = 1, -- height of recipe (unified only)
--   dynamic_display_size = nil, -- unified callback only
-- }
--
function appliances.register_craft_type(type_name, type_def)
  if appliances.have_unified then
    unified_inventory.register_craft_type(type_name, {
        description = type_def.description,
        icon = type_def.icon,
        width = type_def.width,
        height = type_def.height,
        dynamic_display_size = type_def.dynamic_display_size,
      })
  end
  if appliances.have_craftguide then
    use_craftguide.register_craft_type(type_name, {
        description = type_def.description,
        icon = type_def.icon,
      })
  end
  if appliances.have_i3 then
    minetest.register_on_mods_loaded(function()
        i3.register_craft_type(type_name, {
            description = type_def.description,
            icon = type_def.icon,
          })
      end)
  end
end

--
-- {
--   type = "", -- type name
--   output = "", -- item string
--   items = {""}, -- input items
-- }
--
function appliances.register_craft(craft_def)
  if appliances.have_unified then
    unified_inventory.register_craft({
        type = craft_def.type,
        output = craft_def.output,
        items = craft_def.items,
      })
  end
  if appliances.have_craftguide or appliances.have_i3 then
    local items = craft_def.items;
    if craft_def.width then
      items = {};
      local line = "";
      for index, item in pairs(craft_def.items) do
        if (line~="") then
          line = line..",";
        end
        if (item~="") then
          line = line..item;
        else
          line = line.." ";
        end
        if ((index%craft_def.width)==0) then
          table.insert(items, line);
          line = "";
        end
      end
      if (line~="") then
        table.insert(items, line);
      end
    end
    
    if appliances.have_craftguide then
      use_craftguide.register_craft({
          type = craft_def.type,
          result = craft_def.output,
          items = items,
        })
    end
    if appliances.have_i3 then
      if minetest.global_exists("i3") then
        i3.register_craft({
            type = craft_def.type,
            result = craft_def.output,
            items = items,
          })
      else
        minetest.register_on_mods_loaded(function()
            i3.register_craft({
                type = craft_def.type,
                result = craft_def.output,
                items = items,
              })
          end)
      end
    end
  end
end

-- generate conversion table
-- add this vector to position vector to get position on wanted side
local facedir_toside = {front={},back={},right={},left={},bottom={},top={}}
for facedir=0,23 do
  local axis = math.floor(facedir/4);
  local around = facedir%4;
  facedir_toside.back[facedir] = minetest.facedir_to_dir(axis*4+around)
  facedir_toside.front[facedir] = minetest.facedir_to_dir(axis*4+(around+2)%4)
  facedir_toside.left[facedir] = minetest.facedir_to_dir(axis*4+(around+1)%4)
  facedir_toside.right[facedir] = minetest.facedir_to_dir(axis*4+(around+3)%4)
  facedir_toside.bottom[facedir] = vector.cross(facedir_toside.front[facedir], facedir_toside.left[facedir])
  facedir_toside.top[facedir] = vector.multiply(facedir_toside.bottom[facedir], -1)
end
function appliances.get_side_pos(pos_from, node_from, side)
  if not node_from then
    node_from = minetest.get_node(pos_from);
  end
  return vector.add(pos_from, facedir_toside[side][node_from.param2%32])
end
function appliances.get_sides_pos(pos_from, node_from, sides)
  if not node_from then
    node_from = minetest.get_node(pos_from);
  end
  local side_pos = vector.new(pos_from)
  for _,side in pairs(sides) do
    side_pos = vector.add(side_pos, facedir_toside[side][node_from.param2%32])
  end
  return side_pos
end

appliances.opposite_side = {
    front = "back",
    back = "front",
    right = "left",
    left = "right",
    bottom = "top",
    top = "bottom",
  }

function appliances.is_connected_to(pos_from, node_from, pos_to, sides)
  if not node_from then
    node_from = minetest.get_node(pos_from);
  end
  for _,side in pairs(sides) do
    local side_pos = appliances.get_side_pos(pos_from, node_from, side);
    if vector.equals(pos_to, side_pos) then
      return side
    end
  end
  return nil
end

function appliances.add_item_help(item_name, text_to_add)
  local def = minetest.registered_items[item_name]
  if appliances.have_tt then
    local tt_help = def._tt_help
    if not tt_help then
      tt_help = ""
    else
      tt_help = tt_help .. "\n"
    end
    minetest.override_item(item_name, {
        _tt_help = tt_help..text_to_add
      })
  else
    minetest.override_item(item_name, {
        description = def.description.."\n"..text_to_add
      })
  end
end

