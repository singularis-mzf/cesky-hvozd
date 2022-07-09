-- Dye machine
      
selection_box_machine = {
  type = "fixed",
  fixed = {
    {-0.125,-0.5,-0.4375,0.125,0.1875,-0.375},
    {-0.25,-0.5,-0.375,0.25,-0.4375,0.375},
    {-0.25,-0.4375,-0.375,-0.125,0.1875,-0.3125},
    {0.125,-0.4375,-0.375,0.25,0.1875,-0.3125},
    {-0.3125,-0.5,-0.3125,-0.25,0.1875,-0.25},
    {0.25,-0.5,-0.3125,0.3125,0.1875,-0.25},
    {-0.375,-0.5,-0.25,-0.25,-0.4375,0.25},
    {0.25,-0.5,-0.25,0.375,-0.4375,0.25},
    {-0.375,-0.4375,-0.25,-0.3125,0.1875,-0.125},
    {0.3125,-0.4375,-0.25,0.375,0.1875,-0.125},
    {-0.4375,-0.5,-0.125,-0.375,0.1875,0.125},
    {0.375,-0.5,-0.125,0.4375,0.1875,0.125},
    {-0.375,-0.4375,0.125,-0.3125,0.1875,0.25},
    {0.3125,-0.4375,0.125,0.375,0.1875,0.25},
    {-0.3125,-0.5,0.25,-0.25,0.1875,0.3125},
    {0.25,-0.5,0.25,0.3125,0.1875,0.3125},
    {-0.25,-0.4375,0.3125,-0.125,0.1875,0.375},
    {0.125,-0.4375,0.3125,0.25,0.1875,0.375},
    {-0.125,-0.5,0.375,0.125,0.1875,0.4375},
  },
}
selection_box_fill = {
  type = "fixed",
  fixed = {
    {-0.125,-0.5,-0.4375,0.125,0.1875,-0.375},
    {-0.25,-0.5,-0.375,0.25,-0.4375,0.375},
    {-0.25,-0.4375,-0.375,-0.125,0.1875,-0.3125},
    {0.125,-0.4375,-0.375,0.25,0.1875,-0.3125},
    {-0.3125,-0.5,-0.3125,-0.25,0.1875,-0.25},
    {0.25,-0.5,-0.3125,0.3125,0.1875,-0.25},
    {-0.375,-0.5,-0.25,-0.25,-0.4375,0.25},
    {0.25,-0.5,-0.25,0.375,-0.4375,0.25},
    {-0.375,-0.4375,-0.25,-0.3125,0.1875,-0.125},
    {0.3125,-0.4375,-0.25,0.375,0.1875,-0.125},
    {-0.4375,-0.5,-0.125,-0.375,0.1875,0.125},
    {0.375,-0.5,-0.125,0.4375,0.1875,0.125},
    {-0.375,-0.4375,0.125,-0.3125,0.1875,0.25},
    {0.3125,-0.4375,0.125,0.375,0.1875,0.25},
    {-0.3125,-0.5,0.25,-0.25,0.1875,0.3125},
    {0.25,-0.5,0.25,0.3125,0.1875,0.3125},
    {-0.25,-0.4375,0.3125,-0.125,0.1875,0.375},
    {0.125,-0.4375,0.3125,0.25,0.1875,0.375},
    {-0.125,-0.5,0.375,0.125,0.1875,0.4375},
    -- fill
    {-0.125,-0.4375,-0.375,0.125,0.0625,0.375},
    {-0.25,-0.4375,-0.3125,-0.125,0.0625,0.3125},
    {0.125,-0.4375,-0.3125,0.25,0.0625,0.3125},
    {-0.3125,-0.4375,-0.25,-0.25,0.0625,0.25},
    {0.25,-0.4375,-0.25,0.3125,0.0625,0.25},
    {-0.375,-0.4375,-0.125,-0.3125,0.0625,0.125},
    {0.3125,-0.4375,-0.125,0.375,0.0625,0.125},
  },
}

local S = clothing.translator;

local node_desc = S("Empty dye machine");
minetest.register_node("clothing:dye_machine_empty", {
    description = node_desc.."\n"..
                  S("Fill with water and dye.").."\n"..
                  S("Need time to colorize wool, fabric or yarn."),
    short_description = node_desc,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky = 2,},
    legacy_facedir_simple = true,
    is_ground_content = false,
    sounds = default.node_sound_wood_defaults(),
    drawtype = "mesh",
    -- selection box {x=0, y=0, z=0}
    selection_box = selection_box_machine,
    sunlight_propagates = true,
    tiles = {
      "default_wood.png",
    },
    mesh = "clothing_dye_machine.obj",
    
    on_punch = function(pos, node, puncher, pointed_thing)
        if (puncher) then
          local wielded_item = puncher:get_wielded_item();
          local wielded_name = wielded_item:get_name();
          
          if ((wielded_name=="bucket:bucket_water") or
              (wielded_name=="bucket:bucket_river_water")) then
            node.name = "clothing:dye_machine_water";
            minetest.set_node(pos, node);
            puncher:set_wielded_item("bucket:bucket_empty");
          end
        end
      end,
  })
minetest.register_node("clothing:dye_machine_water", {
    description = S("Dye machine filled with water"),
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky = 2,},
    legacy_facedir_simple = true,
    is_ground_content = false,
    sounds = default.node_sound_wood_defaults(),
    drop = "clothing:dye_machine_empty",
    drawtype = "mesh",
    -- selection box {x=0, y=0, z=0}
    selection_box = selection_box_fill,
    sunlight_propagates = true,
    use_texture_alpha = "clip",
    tiles = {
      "default_wood.png",
      "default_river_water.png"
    },
    mesh = "clothing_dye_machine_fill.obj",
    
    on_punch = function(pos, node, puncher, pointed_thing)
        if (puncher) then
          local wielded_item = puncher:get_wielded_item();
          local wielded_name = wielded_item:get_name();
          
          if (string.sub(wielded_name, 1, 4)=="dye:") then
            local color = string.sub(wielded_name, 5, -1);
            local data = clothing.basic_colors[color];
            if data then
              node.name = "clothing:dye_machine_"..color;
              minetest.set_node(pos, node);
              wielded_item:take_item(1);
              puncher:set_wielded_item(wielded_item);
            end
          end
        end
      end,
  })
local node_desc = S("Dye machine filled with dirty water");
minetest.register_node("clothing:dye_machine_water_dirty", {
    description = node_desc.."\n"..
                  S("Empty it by empty bucket."),
    short_description = node_desc,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky = 2,},
    legacy_facedir_simple = true,
    is_ground_content = false,
    sounds = default.node_sound_wood_defaults(),
    drawtype = "mesh",
    -- selection box {x=0, y=0, z=0}
    selection_box = selection_box_fill,
    sunlight_propagates = true,
    use_texture_alpha = "clip",
    tiles = {
      "default_wood.png",
      "clothing_dirty_water.png"
    },
    mesh = "clothing_dye_machine_fill.obj",
    
    can_dig = function() return false; end,
    
    on_punch = function(pos, node, puncher, pointed_thing)
        if (puncher) then
          local wielded_item = puncher:get_wielded_item();
          local wielded_name = wielded_item:get_name();
          
          if (wielded_name=="bucket:bucket_empty") then
            local inv = puncher:get_inventory();
            local list = puncher:get_wield_list();
            local bucket = ItemStack("clothing:bucket_dirty_water");
            node.name = "clothing:dye_machine_empty";
            minetest.set_node(pos, node);
            wielded_item:take_item(1);
            puncher:set_wielded_item(wielded_item);
            if (inv:room_for_item(list, bucket)) then
              inv:add_item(list, bucket);
            else
              minetest.item_drop(bucket, puncher, puncher:get_pos())
            end
          end
        end
      end,
    allow_metadata_inventory_move = function() return 0; end,
    allow_metadata_inventory_put = function() return 0; end,
    on_metadata_inventory_take = function(pos)
        local meta = minetest.get_meta(pos);
        meta:set_string("formspec", "");
      end,
  })

appliances.register_craft_type("clothing_dying", {
    description = S("Dying"),
    icon = "clothing_recipe_dying.png",
    width = 1,
    height = 1,
  })

for color, data in pairs(clothing.basic_colors) do
  dye_machine_key = "dye_machine_"..color;
  
  clothing[dye_machine_key] = appliances.appliance:new(
      {
        node_name_inactive = "clothing:"..dye_machine_key,
        node_name_active = "clothing:"..dye_machine_key.."_active",
        
        node_description = S("Dye machine"),
        node_help = S("Colorize white wool, yarn, fabric.").."\n"..
                    S("Need time to colorize."),
        
        use_stack_size = 0,
        output_stack_size = 1,
        have_usage = false,
        
        sounds = {
          running = {
            sound = "clothing_dye_machine_running",
            sound_param = {max_hear_distance = 8, gain = 1},
            repeat_timer = 0,
          },
        },
      }
    );

  local dye_machine = clothing[dye_machine_key];

  dye_machine:power_data_register(
    {
      ["time_power"] = {
          run_speed = 1,
        },
    })
  
  --------------
  -- Formspec --
  --------------

  function dye_machine:get_formspec(meta, production_percent, consumption_percent)
    local progress = "image[3.6,0.9;5.5,0.95;appliances_production_progress_bar.png^[transformR270]]";
    if production_percent then
      progress = "image[3.6,0.9;5.5,0.95;appliances_production_progress_bar.png^[lowpart:" ..
              (production_percent) ..
              ":appliances_production_progress_bar_full.png^[transformR270]]";
    end
    
    local formspec =  "formspec_version[3]" .. "size[12.75,8.5]" ..
                      "background[-1.25,-1.25;15,10;appliances_appliance_formspec.png]" ..
                      progress..
                      "list[current_player;main;1.5,3;8,4;]" ..
                      "list[context;"..self.input_stack..";2,0.8;1,1;]" ..
                      "list[context;"..self.output_stack..";9.75,0.8;1,1;]" ..
                      "listring[current_player;main]" ..
                      "listring[context;"..self.input_stack.."]" ..
                      "listring[current_player;main]" ..
                      "listring[context;"..self.output_stack.."]" ..
                      "listring[current_player;main]";
    return formspec;
  end

  --------------------
  -- Node callbacks --
  --------------------
  
  function dye_machine:cb_can_dig(pos)  
    return false;
  end
  function dye_machine:cb_allow_metadata_inventory_put(pos, listname, index, stack, player)
    local player_name = nil
    if player then
      player_name = player:get_player_name()
    end
    local can_put = self:recipe_inventory_can_put(pos, listname, index, stack, player_name);
    if (can_put>0) then
      local meta = minetest.get_meta(pos);
      local inv = meta:get_inventory();
      
      if (inv:get_stack(listname, index):get_count()~=0) then
        return 0;
      end
      
      return 1;
    end
    return can_put;
  end

  function dye_machine:after_timer_step(timer_step)
    local use_input, use_usage = self:recipe_aviable_input(timer_step.inv)
    if use_input then
      self:running(timer_step.pos, timer_step.meta);
      return true
    else
      self:deactivate(timer_step.pos, timer_step.meta);
      local node = minetest.get_node(timer_step.pos);
    
      local formspec =  "formspec_version[3]" .. "size[12.75,8.5]" ..
                        "background[-1.25,-1.25;15,10;appliances_appliance_formspec.png]" ..
                        "list[current_player;main;1.5,3;8,4;]" ..
                        "list[context;"..self.output_stack..";6.0,0.8;1,1;]" ..
                        "listring[current_player;main]" ..
                        "listring[context;"..self.output_stack.."]";
      
      timer_step.meta:set_string("infotext", S("Dye machine with dirty water"));
      timer_step.meta:set_string("formspec", formspec);
      node.name = "clothing:dye_machine_water_dirty"
      minetest.swap_node(timer_step.pos, node);
      return false
    end
  end

  ----------
  -- Node --
  ----------

  local node_def = {
      paramtype = "light",
      paramtype2 = "facedir",
      groups = {cracky = 2, not_in_creative_inventory = 1},
      legacy_facedir_simple = true,
      is_ground_content = false,
      sounds = default.node_sound_wood_defaults(),
      drawtype = "mesh",
      -- selection box {x=0, y=0, z=0}
      selection_box = selection_box_fill,
      sunlight_propagates = true,
      use_texture_alpha = "clip",
    }
  local inactive_node = {
      tiles = {
        "default_wood.png",
        "clothing_dye_machine_fill.png^[multiply:#"..data.hex,
      },
      mesh = "clothing_dye_machine_fill.obj",
    }
  local active_node = {
      tiles = {
        "default_wood.png",
        "clothing_dye_machine_fill.png^[multiply:#"..data.hex,
      },
      mesh = "clothing_dye_machine_fill.obj",
    }
  
  dye_machine:register_nodes(node_def, inactive_node, active_node)

  -------------------------
  -- Recipe Registration --
  -------------------------
  
  if clothing.have_wool then
    dye_machine:recipe_register_input(
      "wool:white",
      {
        inputs = 1,
        outputs = {"wool:"..color},
        production_time = 45,
        consumption_step_size = 1,
      });
    minetest.clear_craft({
        type = "shapeless",
        --output = "wool:"..color,
        recipe = {"group:dye,color_"..color, "group:wool"},
      });
  end
  dye_machine:recipe_register_input(
    "clothing:yarn_spool_white",
    {
      inputs = 1,
      outputs = {"clothing:yarn_spool_"..color},
      production_time = 60,
      consumption_step_size = 1,
    });
  dye_machine:recipe_register_input(
    "clothing:fabric_white",
    {
      inputs = 1,
      outputs = {"clothing:fabric_"..color},
      production_time = 30,
      consumption_step_size = 1,
    });
  
  dye_machine:register_recipes("clothing_dying", "")
end


