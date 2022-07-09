-- Spinning machine

local S = clothing.translator;

clothing.spinning_machine = appliances.appliance:new(
    {
      node_name_inactive = "clothing:spinning_machine",
      node_name_active = "clothing:spinning_machine_active",
      
      node_description = S("Spinning machine"),
      node_help = S("Fill yarn empty spool by yarn.").."\n"..
                  S("Powered by punching."),
      
      sounds = {
        running = {
          sound = "clothing_spinning_machine_running",
          sound_param = {max_hear_distance = 8, gain = 1},
          repeat_timer = 0,
        },
      },
    }
  );

local spinning_machine = clothing.spinning_machine;

spinning_machine:power_data_register(
  {
    ["punch_power"] = {
        run_speed = 1,
      },
  })

--------------
-- Formspec --
--------------

--------------------
-- Node callbacks --
--------------------

----------
-- Node --
----------

local node_def = {
    paramtype = "light",
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
local inactive_node = {
    tiles = {
      "default_wood.png",
      "default_junglewood.png",
      "wool_white.png",
      "default_junglewood.png"
    },
    mesh = "clothing_spinning_machine.obj",
  }
local active_node = {
    tiles = {
      "default_wood.png",
      "default_junglewood.png",
      "wool_white.png",
      {
        image = "clothing_spinning_machine_wheel_active.png",
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
    mesh = "clothing_spinning_machine_active.obj",
  }

spinning_machine:register_nodes(node_def, inactive_node, active_node)

-------------------------
-- Recipe Registration --
-------------------------

appliances.register_craft_type("clothing_spinning", {
    description = S("Spinning"),
    icon = "clothing_recipe_spinning.png",
    width = 1,
    height = 1,
  })
appliances.register_craft_type("clothing_spinning_use", {
    description = S("Use for spinning"),
    icon = "clothing_recipe_spinning.png",
    width = 1,
    height = 1,
  })
  
spinning_machine:recipe_register_usage(
  "clothing:yarn_spool_empty",
  {
    outputs = {""},
    consumption_time = 30,
    production_step_size = 1,
  });

if minetest.registered_items["farming:hemp_fibre"] then
  spinning_machine:recipe_register_input(
    "farming:hemp_fibre",
    {
      inputs = 1,
      outputs = {"clothing:yarn_spool_white"},
      production_time = 30,
      consumption_step_size = 1,
    });
end
if clothing.have_farming then
  spinning_machine:recipe_register_input(
    "farming:cotton",
    {
      inputs = 1,
      outputs = {"clothing:yarn_spool_white"},
      production_time = 30,
      consumption_step_size = 1,
    });
end

for color, hex in pairs(clothing.colors) do
  if clothing.have_wool then
    spinning_machine:recipe_register_input(
      "wool:"..color,
      {
        inputs = 1,
        outputs = {"clothing:yarn_spool_"..color},
        production_time = 30,
        consumption_step_size = 1,
      });
  end
end

spinning_machine:register_recipes("clothing_spinning", "clothing_spinning_use")

