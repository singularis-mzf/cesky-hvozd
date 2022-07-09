
-- Chargable tool

local S = appliances.translator

appliances.tool = {};
local tool = appliances.tool;

function tool:new(def)
  def = def or {};
  for key, value in pairs(self) do
    if (type(value)~="function") and (def[key]==nil) then
      if (type(value)=="table") then
        def[key] = table.copy(value);
      else
        def[key] = value;
      end
    end
  end
  setmetatable(def, {__index = self});
  return def;
end

tool.tool_name_break = nil

tool.max_stored_energy = 100000
tool.meta_energy = "energy"

tool.have_use = true
tool.have_place = false

tool.no_energy_msg = S("No energy! Please, use charger.")

tool.energy_per_use = 100

tool.battery_data = {}

tool.sounds = nil

tool.meta_delay = "delay"
tool.delay_per_use = 0
tool.delay_per_place = 0

local function disable_supply_data(supplies_data, supply_data)
  if (supply_data~=nil) then
    if (supply_data.disable~=nil) then
      for _,key in pairs(supply_data.disable) do
        supplies_data[key] = nil;
      end
      supply_data.disable = nil;
    end
  end
end
local function disable_supplies_data(supplies_data)
  for supply_name,supply_data in pairs(supplies_data) do
    if appliances.all_extensions[supply_name] then
      disable_supply_data(supplies_data, supply_data);
    else
      supplies_data[supply_name] = nil
    end
  end
  return supplies_data;
end

function tool:battery_data_register(battery_data)
  self.battery_data = disable_supplies_data(battery_data);
end

function tool:get_energy(itemstack, meta)
  return meta:get_int(self.meta_energy)
end
function tool:set_energy(itemstack, meta, energy)
  meta:set_int(self.meta_energy, energy)
end

function tool:update_wear(itemstack, meta)
  if self.max_stored_energy then
    local have_energy = self:get_energy(itemstack, meta)
    local wear = 0
    if (have_energy>0) then
      wear = 65534-math.floor((have_energy/self.max_stored_energy)*65534)
      wear = math.min(wear, 65534)
      wear = math.max(wear, 1)
    end
    itemstack:set_wear(wear)
  end
end

function tool:use_energy(itemstack, meta, need_energy)
  if self.max_stored_energy then
    local have_energy = self:get_energy(itemstack, meta)
    self:set_energy(itemstack, meta, math.max(have_energy-need_energy, 0))
    self:update_wear(itemstack, meta)
    if (have_energy>=need_energy) then
      return true
    end
    return false
  end
  return true
end

function tool:get_delay(_itemstack, meta)
  return (meta:get_int(self.meta_delay)>minetest.get_gametime())
end
function tool:set_delay(_itemstack, meta, delay)
  meta:set_int(self.meta_delay, minetest.get_gametime()+delay)
end

function tool:cb_play_sound(user, itemstack, meta, sound_key)
  local sound = self.sounds[sound_key]
  if sound then
    if sound.update_sound then
      sound = sound.update_sound(self, user, itemstack, meta, sound_key, sound)
      --print("sound "..dump(sound))
    end
    local param = sound.sound_param;
    param = table.copy(param);
    param.object = user
    minetest.sound_play(sound.sound, param, true);
  end
end
function tool:play_sound(user, itemstack, meta, sound_key)
  if self.sounds then
    self:cb_play_sound(user, itemstack, meta, sound_key);
  end
end

function tool:on_place(itemstack, user, pointed_thing)
  if tool.have_place then
    local meta = itemstack:get_meta()
    if self:get_delay(itemstack, meta) then
      return nil
    end
    local need_energy = self:cb_get_need_place_energy(itemstack, meta, user, pointed_thing)
    if (need_energy~=nil) then
      local have_energy = self:use_energy(itemstack, meta, need_energy)
      
      if have_energy then
        if self.delay_per_place then
          self:set_delay(itemstack, meta, self.delay_per_place)
        end
        local play_sound
        itemstack, play_sound = self:cb_do_place(itemstack, meta, user, pointed_thing)
        if play_sound then
          self:play_sound(user, itemstack, meta, "onplace")
        end
        return itemstack
      else
        local player_name = nil
        if user then
          player_name = user:get_player_name()
        end
        if player_name then
          minetest.chat_send_player(player_name, self.no_energy_msg)
        end
      end
    end
  end
  return nil
end

function tool:cb_get_need_use_energy(_itemstack, _meta, _user, _pointed_thing)
  return self.energy_per_use
end
function tool:cb_get_need_place_energy(_itemstack, _meta, _user, _pointed_thing)
  return self.energy_per_use
end

function tool:cb_on_break(itemstack, meta, user, pointed_thing)
  if self.tool_name_break then
    appliances.swap_stack(itemstack, self.tool_name_break)
  end
  return itemstack
end

function tool:cb_do_place(_itemstack, _meta, _user, _pointed_thing)
  return nil, true
end
function tool:cb_do_use(_itemstack, _meta, _user, _pointed_thing)
  return nil, true
end

function tool:cb_on_place(itemstack, placer, pointed_thing)
  return self:on_place(itemstack, placer, pointed_thing)
end
function tool:cb_on_secondary_use(itemstack, user, pointed_thing)
  return self:on_place(itemstack, user, pointed_thing)
end
function tool:cb_on_drop(itemstack, dropper, pos)
  return minetest.item_drop(itemstack, dropper, pos)
end
function tool:cb_on_use(itemstack, user, pointed_thing)
  if self.have_use then
    local meta = itemstack:get_meta()
    if self:get_delay(itemstack, meta) then
      return nil
    end
    local need_energy = self:cb_get_need_use_energy(itemstack, meta, user, pointed_thing)
    if (need_energy~=nil) then
      local have_energy = self:use_energy(itemstack, meta, need_energy)
      
      if have_energy then
        if self.delay_per_use then
          self:set_delay(itemstack, meta, self.delay_per_use)
        end
        local play_sound
        itemstack, play_sound = self:cb_do_use(itemstack, meta, user, pointed_thing)
        if play_sound then
          self:play_sound(user, itemstack, meta, "onuse")
        end
        return itemstack
      else
        local player_name = nil
        if user then
          player_name = user:get_player_name()
        end
        if player_name then
          minetest.chat_send_player(player_name, self.no_energy_msg)
        end
      end
    end
  end
  return nil
end
function tool:cb_on_after_use(itemstack, user, node, digparams)
  return nil
end

function tool:register_tool(tool_def)
  tool_def = table.copy(tool_def);
  
  -- fix data (extensions)
  self.extensions_data = {}
  for battery_name,battery_data in pairs(self.battery_data) do
    self.extensions_data[battery_name] = battery_data;
  end
  
  -- use .."" to prevent string object share
  tool_def.description = self.tool_description.."";
  if (self.tool_help) then
    if appliances.have_tt then
      tool_def._tt_help = self.tool_help.."";
    else
      tool_def.description = self.tool_description.."\n"..self.tool_help;
    end
  end
  tool_def.short_description = self.tool_description.."";
  
  tool_def.on_place = function (itemstack, placer, pointed_thing)
      return self:cb_on_place(itemstack, placer, pointed_thing);
    end
  tool_def.on_secondary_use = function (itemstack, user, pointed_thing)
      return self:cb_on_secondary_use(itemstack, user, pointed_thing);
    end
  tool_def.on_drop = function (itemstack, dropper, pos)
      return self:cb_on_drop(itemstack, dropper, pos);
    end
  tool_def.on_use = function (itemstack, user, pointed_thing)
      return self:cb_on_use(itemstack, user, pointed_thing);
    end
  tool_def.on_after_use = function (itemstack, user, node, digparams)
      return self:cb_on_after_use(itemstack, user, node, digparams);
    end
  
  self:call_update_tool_def(tool_def);
  self:cb_after_update_tool_def(tool_def);
  
  minetest.register_tool(self.tool_name, tool_def)
end

function tool:call_update_tool_def(tool_def)
  for extension_name, extension_data in pairs(self.extensions_data) do
    local extension = appliances.all_extensions[extension_name]
    if extension and extension.update_tool_def then
      extension.update_tool_def(self, extension_data, tool_def)
    end
  end
end
function tool:cb_after_update_tool_def(tool_def)
end

