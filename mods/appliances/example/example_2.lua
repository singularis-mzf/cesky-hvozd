-- Example 2
--
-- Punch powered machine with recipe like input

local S = clothing.translator;

clothing.example_2 = appliances.appliance:new(
    {
      node_name_inactive = "example:example_2",
      node_name_active = "example:example_2_active",
      
      node_description = S("Example machine"),
      node_help = S("Powered by punching."),
      
      input_stack = "input",
      input_stack_size = 9,
      input_stack_width = 3,
      use_stack = "input",
      use_stack_size = 0,
      have_usage = false,
    }
  );

local example_2 = clothing.example_2;

example_2:power_data_register({
    ["punch_power"] = {
            run_speed = 1,
          },
  })

--------------
-- Formspec --
--------------

-- have to be redefined
function example_2:get_formspec(meta, production_percent, consumption_percent)
  local progress = "image[5.1,1;4,1.5;appliances_production_progress_bar.png^[transformR270]]";
  if production_percent then
    progress = "image[5.1,1;4,1.5;appliances_production_progress_bar.png^[lowpart:" ..
            (production_percent) ..
            ":appliances_production_progress_bar_full.png^[transformR270]]";
  end
  
  local formspec =  "formspec_version[3]" .. "size[12.75,9.5]" ..
                    "background[-1.25,-1.25;15,11;appliances_appliance_formspec.png]" ..
                    progress..
                    "list[current_player;main;1.5,4;8,4;]" ..
                    "list[context;input;1,0;3,3;]" ..
                    "list[context;output;9.75,0.75;2,2;]" ..
                    "listring[current_player;main]" ..
                    "listring[context;input]" ..
                    "listring[current_player;main]" ..
                    "listring[context;output]" ..
                    "listring[current_player;main]";
  return formspec;
end

--------------------
-- Node callbacks --
--------------------

----------
-- Node --
----------

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
        {-0.5,0.25,-0.5,0.5,0.4375,0.5},
        {-0.375,-0.5,-0.375,-0.25,0.25,-0.25},
        {0.25,-0.5,-0.375,0.375,0.25,-0.25},
        {-0.375,0.4375,-0.375,0.0625,0.5,0.375},
        {0.25,0.4375,-0.375,0.3125,0.5,0.0},
        {0.1875,0.4375,-0.0625,0.25,0.5,0.125},
        {0.3125,0.4375,-0.0625,0.375,0.5,0.125},
        {0.25,0.4375,0.125,0.3125,0.5,0.1875},
        {-0.375,-0.5,0.25,-0.25,0.25,0.375},
        {0.25,-0.5,0.25,0.375,0.25,0.375},
      },
    },
    sunlight_propagates = true,
  }
local inactive_node = {
    tiles = {
      "default_wood.png",
      "default_junglewood.png",
      "wool_white.png",
      "clothing_example_2_needle.png"
    },
    mesh = "clothing_example_2.obj",
  }
local active_node = {
    tiles = {
      "default_wood.png",
      "default_junglewood.png",
      "wool_white.png",
      "clothing_example_2_needle.png"
    },
    use_texture_alpha = "clip",
    mesh = "clothing_example_2.obj",
  }

example_2:register_nodes(node_def, inactive_node, active_node)

-------------------------
-- Recipe Registration --
-------------------------

appliances.register_craft_type("example_example_2", {
    description = S("Sewing"),
    icon = "clothing_bone_needle.png",
    width = 3,
    height = 3,
  })
  
local input1 = "example:input_item_1";
local input2 = "example:input_item_2";
example_2:recipe_register_input(
  "",
  {
    inputs = {input1, input1, input1,
              input1, input2, input1,
              "", "", "",
             },
    outputs = {{"example:output2","example:output1"}},
    production_time = 30,
    consumption_step_size = 1,
  });
example_2:recipe_register_input(
  "",
  {
    inputs = {input1, input2, input1,
              input1, input1, input1,
              input1, input1, input1,
             },
    outputs = {{"example:output3","example:output1"}},
    production_time = 60,
    consumption_step_size = 1,
  });
example_2:recipe_register_input(
  "",
  {
    inputs = {input1, input1, input1,
              input1, input2, input1,
              input1, "", input1,
             },
    outputs = {{"example:output4","example:output1"}},
    production_time = 60,
    consumption_step_size = 1,
  });
example_2:recipe_register_input(
  "",
  {
    inputs = {input1, input1, input2,
              input1, input1, "",
              input1, input1, "",
             },
    outputs = {{"example:output5","example:output1"}},
    production_time = 30,
    consumption_step_size = 1,
  });

minetest.register_on_mods_loaded(
  function ()
    example_2:register_recipes("example_example_2", "")
  end)

