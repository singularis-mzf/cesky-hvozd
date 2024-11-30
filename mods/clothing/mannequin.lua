-- this code isdelivered from code in 3d_armor_stand mod.
-- support for i18n
local S = clothing.translator

local mannequin_stand_formspec = "size[8,7]" ..
  default.gui_bg ..
  default.gui_bg_img ..
  default.gui_slots ..
  default.get_hotbar_bg(0,3) ..
  "list[current_name;clothing;2,0.0;3,3;]" ..
  "list[current_player;main;0,3;8,1;]" ..
  "list[current_player;main;0,4.25;8,3;8]" ..
  "listring[current_name;clothing]"..
  "listring[current_player;main]"

local y_change = - 7.0/16

local function drop_armor(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  for index = 1,inv:get_size("clothing") do
    local stack = inv:get_stack("clothing", index)
    if stack and stack:get_count() > 0 then
      armor.drop_armor(pos, stack)
      inv:set_stack("armor_"..element, 1, nil)
    end
  end
end

--[[
local function get_stand_object(pos)
  local object = nil
  local objects = minetest.get_objects_inside_radius(pos, 0.5) or {}
  for _, obj in pairs(objects) do
    local ent = obj:get_luaentity()
    if ent then
      if ent.name == "clothing:mannequin_entity" then
        -- Remove duplicates
        if object then
          obj:remove()
        else
          object = obj
        end
      end
    end
  end
  return object
end
]]

local function update_entity(pos, entity_hint) -- pos is a node position
  local opos = vector.offset(pos, 0, y_change, 0)
  local node = minetest.get_node(pos)
  local object
  if entity_hint ~= nil then
    object = assert(entity_hint.object)
  else
    local meta = minetest.get_meta(pos)
    local handle = meta:get_int("entity_handle")
    if handle ~= 0 then
      local entity = ch_core.get_entity_by_handle(handle)
      if entity ~= nil then
        object = entity.object
      end
    end
  end
  if object then
    if not string.find(node.name, "clothing:mannequin_") then
      object:remove()
      return
    end
  else
    object = minetest.add_entity(opos, "clothing:mannequin_entity")
  end
  if object then
    local cape_texture = "clothing_mannequin.png"
    local cloth_texture = "clothing_transparent.png"
    local trans_texture = "clothing_transparent.png"
    local cloth_textures = {}
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local yaw = 0
    if inv then
      for index = 1,inv:get_size("clothing") do
        local stack = inv:get_stack("clothing", index)
        if stack:get_count() == 1 then
          local item = stack:get_name() or ""
          local def = stack:get_definition() or {}
          local groups = def.groups or {}
          if groups["clothing"] then
            if def.uv_image then
              table.insert(cloth_textures, "("..def.uv_image..")")
            else
              table.insert(cloth_textures, item:gsub("%:", "_")..".png")
            end
          elseif groups["cape"] then
            if def.uv_image then
              cape_texture = "clothing_mannequin.png^("..def.uv_image..")"
            else
              cape_textures = "clothing_mannequin.png^"..item:gsub("%:", "_")..".png"
            end
          end
        end
      end
    end
    if (cloth_textures[1]~=nil) then
      cloth_texture = table.concat(cloth_textures, "^")
    end
    if node.param2 then
      local rot = node.param2 % 4
      if rot == 1 then
        yaw = 3 * math.pi / 2
      elseif rot == 2 then
        yaw = math.pi
      elseif rot == 3 then
        yaw = math.pi / 2
      end
    end
    object:set_yaw(yaw+math.pi)
    object:set_properties({textures={cape_texture, cloth_texture, trans_texture, trans_texture}})
  end
end

local function has_locked_armor_stand_privilege(meta, player)
  local name = ""
  if player then
    if minetest.check_player_privs(player, "protection_bypass") then
      return true
    end
    name = player:get_player_name()
  end
  if name ~= meta:get_string("owner") then
    return false
  end
  return true
end

local function add_hidden_node(pos, player)
  local p = {x=pos.x, y=pos.y + 1, z=pos.z}
  local name = player:get_player_name()
  local node = minetest.get_node(p)
  if node.name == "air" and not minetest.is_protected(pos, name) then
    minetest.set_node(p, {name="clothing:mannequin_stand_top"})
  end
end

local function remove_hidden_node(pos)
  local p = {x=pos.x, y=pos.y + 1, z=pos.z}
  local node = minetest.get_node(p)
  if node.name == "clothing:mannequin_stand_top" then
    minetest.remove_node(p)
  end
end

minetest.register_node("clothing:mannequin_stand_top", {
  description = S("Mannequin stand top"),
  paramtype = "light",
  drawtype = "plantlike",
  sunlight_propagates = true,
  walkable = true,
  pointable = false,
  diggable = false,
  buildable_to = false,
  drop = "",
  groups = {not_in_creative_inventory = 1},
  on_blast = function() end,
  tiles = {"clothing_transparent.png"},
})

minetest.register_node("clothing:mannequin_stand", {
  description = S("Mannequin stand"),
  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.0625, -0.4375, -0.0625, 0.0625, 1.25, 0.0625},
      {-0.25, -0.5, -0.25, 0.25, -0.4375, 0.25},
    },
  },
  tiles = {"clothing_mannequin_stand.png"},
  use_texture_alpha = "clip",
  paramtype = "light",
  paramtype2 = "facedir",
  walkable = false,
  selection_box = {
    type = "fixed",
    fixed = {
      {-0.25, -0.4375, -0.25, 0.25, 1.4, 0.25},
      {-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
    },
  },
  groups = {choppy=2, oddly_breakable_by_hand=2},
  sounds = default.node_sound_wood_defaults(),
  on_construct = function(pos)
    local meta = minetest.get_meta(pos)
    meta:set_string("formspec", mannequin_stand_formspec)
    meta:set_string("infotext", S("Mannequin Stand"))
    local inv = meta:get_inventory()
    inv:set_size("clothing", 9)
  end,
  can_dig = function(pos, player)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    if not inv:is_empty("clothing") then
      return false
    end
    return true
  end,
  after_place_node = function(pos, placer)
    local opos = {x=pos.x, z=pos.z}
    opos.y = pos.y + y_change
    minetest.add_entity(opos, "clothing:mannequin_entity")
    add_hidden_node(opos, placer)
  end,
  allow_metadata_inventory_put = function(pos, listname, index, stack)
    local def = stack:get_definition() or {}
    local groups = def.groups or {}
    if (groups["clothing"] or groups["cape"]) then
      return 1
    end
    return 0
  end,
  allow_metadata_inventory_move = function(pos)
    return 0
  end,
  on_metadata_inventory_put = function(pos)
    update_entity(pos)
  end,
  on_metadata_inventory_take = function(pos)
    update_entity(pos)
  end,
  after_destruct = function(pos)
    update_entity(pos)
    remove_hidden_node(pos)
  end,
  on_blast = function(pos)
    drop_armor(pos)
    armor.drop_armor(pos, "3d_armor_stand:armor_stand")
    minetest.remove_node(pos)
  end,
})

minetest.register_entity("clothing:mannequin_entity", {
	initial_properties = {
    physical = true,
    visual = "mesh",
    --mesh = "skinsdb_3d_armor_character_5.b3d",
    mesh = "clothing_mannequin.obj",
    visual_size = {x=1, y=1},
    collisionbox = {0,0,0,0,0,0},
    textures = {"clothing_mannequin.png", "clothing_transparent.png", "clothing_transparent.png", "clothing_transparent.png"},
    use_texture_alpha = true,
    static_save = true,
	},
  pos = nil,
  timer = 0,
  on_activate = function(self)
    local opos = assert(self.object:get_pos())
    self.pos = vector.round(opos)
    local pos = vector.offset(opos, 0, -y_change, 0)
    local node = core.get_node(pos)
    print("DEBUG: node is "..node.name)
    local meta = core.get_meta(pos)
    local old_handle = meta:get_int("entity_handle")
    if old_handle == 0 then
      old_handle = nil
    end
    local new_handle, errmsg = ch_core.register_entity(self, old_handle)
    if new_handle ~= nil then
      if old_handle == nil or new_handle ~= old_handle then
        meta:set_int("entity_handle", new_handle)
      end
      update_entity(pos)
    else
      core.log("error", "clothing:mannequin_entity registration failed: "..(errmsg or "nil"))
    end
  end,
  on_blast = function(self, damage)
    local drops = {}
    local node = minetest.get_node(self.pos)
    if node.name == "clothing:mannequin_stand" then
      drop_armor(self.pos)
      self.object:remove()
    end
    return false, false, drops
  end,
  on_deactivate = ch_core.unregister_entity,
})

minetest.register_abm({
  nodenames = {"clothing:mannequin_stand"},
  interval = 15,
  chance = 1,
  action = function(pos, node, active_object_count, active_object_count_wider)
    update_entity(pos)
  end
})

if minetest.get_modpath("basic_materials") then
  minetest.register_craft({
    output = "clothing:mannequin_stand",
    recipe = {
      {"dye:orange", "basic_materials:plastic_sheet", "dye:white"},
      {"basic_materials:plastic_strip", "basic_materials:plastic_sheet", "basic_materials:plastic_strip"},
      {"basic_materials:plastic_strip", "basic_materials:plastic_sheet", "basic_materials:plastic_strip"},
    }
  })
end

minetest.register_lbm({
  label = "Mannequin stand update",
  name = "clothing:mannequin_stand_update_v1",
  nodenames = {"clothing:mannequin_stand"},
  action = function(pos, node, dtime_s)
    minetest.get_meta(pos):set_string("formspec", mannequin_stand_formspec)
  end,
})
