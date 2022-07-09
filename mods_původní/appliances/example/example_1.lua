-- Example 1
--
-- Basic punch powered machine

local S = minetest.get_translator("translator_name");

clothing.example1_machine = appliances.appliance:new(
    {
      -- registered node names
      node_name_inactive = "example:example_1_machine",
      node_name_active = "example:example_1_machine_active",
      
      -- short description and first line of description
      node_description = S("Example 1 machine"),
      -- other lines of descriptions
      node_help = S(".").."\n"..
                  S("Powered by punching."),
    }
  );

local example_1_machine = clothing.example_1_machine;

example_1:power_data_register({
    ["punch_power"] = {
            run_speed = 1,
          },
  })

--------------
-- Formspec --
--------------

-- posible redefinition of formspec for example_1_machine
--[[
function example_1_machine:get_formspec(meta, production_percent, consumption_percent)
  local progress = "image[3.6,0.5;5.5,1.5;laboratory_progress_bar.png^[transformR270]".."]";
  if production_percent then
    progress = "image[3.6,0.5;5.5,1.5;laboratory_progress_bar.png^[lowpart:" ..
            (production_percent) ..
            ":laboratory_progress_bar_full.png^[transformR270]".."]";
  end
  
  local formspec =  "formspec_version[3]" .. "size[12.75,8.5]" ..
                    "background[-1.25,-1.25;15,10;laboratory_machine_formspec.png]" ..
                    progress..
                    "list[current_player;main;1.5,3;8,4;]" ..
                    "list[context;input;2,0.25;1,1;]" ..
                    "list[context;use_in;2,1.5;1,1;]" ..
                    "list[context;output;9.75,0.25;2,2;]" ..
                    "listring[current_player;main]" ..
                    "listring[context;input]" ..
                    "listring[current_player;main]" ..
                    "listring[context;output]" ..
                    "listring[current_player;main]";
  return formspec;
end
--]]

--------------------
-- Node callbacks --
--------------------


----------
-- Node --
----------

-- node parameters which are identical for inactive and active node
local node_def = {
    paramtype2 = "facedir",
    groups = {cracky = 2,},
    legacy_facedir_simple = true,
    is_ground_content = false,
    sounds = default.node_sound_wood_defaults(),
    drawtype = "mesh",
    -- selection box {x=0, y=0, z=0}
    selection_box = {
      type = "fixed",
      fixed = {
        {-0.1875,-0.5,-0.3125,0.1875,-0.4375,-0.25},
        {-0.0625,-0.5,-0.25,0.0625,-0.4375,0.3125},
        {-0.125,-0.375,-0.1875,0.125,-0.3125,0.25},
        {-0.0625,0.3125,-0.1875,0.0625,0.375,0.25},
        {-0.1875,-0.5,-0.125,-0.125,-0.3125,-0.0625},
        {0.125,-0.5,-0.125,0.1875,-0.3125,-0.0625},
        {-0.0625,-0.3125,-0.125,0.0625,0.3125,-0.0625},
        {-0.125,0.3125,-0.125,-0.0625,0.375,-0.0625},
        {0.0625,0.3125,-0.125,0.375,0.375,-0.0625},
        {-0.1875,-0.375,-0.0625,-0.125,-0.3125,0.1875},
        {0.125,-0.375,-0.0625,0.1875,-0.3125,0.1875},
        {0.1875,0.25,-0.0625,0.25,0.4375,0.0},
        {0.125,0.3125,-0.0625,0.1875,0.375,0.0},
        {0.25,0.3125,-0.0625,0.3125,0.375,0.0},
        {-0.0625,0.4375,-0.0625,0.0625,0.5,0.125},
        {-0.125,-0.3125,0.0,0.125,-0.25,0.0625},
        {-0.1875,-0.25,0.0,-0.125,-0.1875,0.0625},
        {0.125,-0.25,0.0,0.1875,-0.1875,0.0625},
        {-0.25,-0.1875,0.0,-0.1875,-0.125,0.0625},
        {0.1875,-0.1875,0.0,0.25,-0.125,0.0625},
        {-0.3125,-0.125,0.0,-0.25,0.125,0.0625},
        {0.25,-0.125,0.0,0.3125,0.125,0.0625},
        {-0.3125,0.125,0.0,-0.25,0.25,0.0625},
        {-0.25,0.125,0.0,-0.1875,0.1875,0.0625},
        {0.1875,0.125,0.0,0.25,0.1875,0.0625},
        {0.25,0.125,0.0,0.3125,0.25,0.0625},
        {-0.1875,0.1875,0.0,-0.125,0.25,0.0625},
        {0.125,0.1875,0.0,0.1875,0.25,0.0625},
        {-0.25,0.25,0.0,-0.1875,0.375,0.0625},
        {-0.125,0.25,0.0,0.125,0.3125,0.0625},
        {0.1875,0.25,0.0,0.25,0.3125,0.0625},
        {0.1875,0.3125,0.0,0.25,0.375,0.1875},
        {-0.1875,0.375,0.0,-0.125,0.4375,0.0625},
        {-0.0625,0.375,0.0,0.0625,0.4375,0.0625},
        {0.125,0.375,0.0,0.1875,0.4375,0.0625},
        {-0.125,0.4375,0.0,-0.0625,0.5,0.0625},
        {0.0625,0.4375,0.0,0.125,0.5,0.0625},
        {-0.1875,-0.5,0.125,-0.125,-0.375,0.1875},
        {0.125,-0.5,0.125,0.1875,-0.375,0.1875},
        {-0.0625,-0.3125,0.125,0.0625,0.3125,0.1875},
        {-0.125,0.3125,0.125,-0.0625,0.375,0.1875},
        {0.0625,0.3125,0.125,0.1875,0.375,0.1875},
        {0.25,0.3125,0.125,0.375,0.375,0.1875},
        -- wheel
        {-0.1875,-0.1875,0.0,-0.125,-0.125,0.0625},
        {0.125,-0.1875,0.0,0.1875,-0.125,0.0625},
        {-0.125,-0.125,0.0,-0.0625,-0.0625,0.0625},
        {0.0625,-0.125,0.0,0.125,-0.0625,0.0625},
        {-0.0625,-0.0625,0.0,0.0625,0.0625,0.0625},
        {-0.125,0.0625,0.0,-0.0625,0.125,0.0625},
        {0.0625,0.0625,0.0,0.125,0.125,0.0625},
        {-0.1875,0.125,0.0,-0.125,0.1875,0.0625},
        {0.125,0.125,0.0,0.1875,0.1875,0.0625},
      },
    },
    sunlight_propagates = true,
  }

-- node parameters specific for inactive node
local inactive_node = {
    tiles = {
      "default_wood.png",
      "default_junglewood.png",
      "wool_white.png",
      "default_junglewood.png"
    },
    mesh = "clothing_example_1_machine.obj",
  }

-- node parameters specific for active node
local active_node = {
    tiles = {
      "default_wood.png",
      "default_junglewood.png",
      "wool_white.png",
      {
        image = "clothing_example_1_machine_wheel_active.png",
        backface_culling = true,
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 0.3,
        }
      },
    },
    use_texture_alpha = "clip",
    mesh = "clothing_example_1_machine_active.obj",
  }

-- do a registration of node (callbacks are added automatically)
example_1_machine:register_nodes(node_def, inactive_node, active_node)

-------------------------
-- Recipe Registration --
-------------------------

appliances.register_craft_type("example_example_1", {
    description = S("Example");
    icon = "example_1.png";
    width = 1,
    height = 1,
  })
appliances.register_craft_type("example_example_1_use", {
    description = S("Example use");
    icon = "example_use_1.png";
    width = 1,
    height = 1,
  })

-- register usage
example_1_machine:recipe_register_usage(
  "example:usage_item",
  {
    outputs = {""}, -- will be consumed without remain
    consumption_time = 30,
    production_step_size = 1,
  });

-- register input
example_1_machine:recipe_register_input(
  "example:input_item",
  {
    inputs = 1,
    outputs = {"example:output_item"},
    production_time = 30,
    consumption_step_size = 1,
  });

-- register recipes to unified_inventory
minetest.register_on_mods_loaded(
  function ()
    example_1_machine:register_recipes("example_example_1", "example_example_1_use")
  end)

