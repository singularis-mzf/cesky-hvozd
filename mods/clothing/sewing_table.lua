-- Sewing table

local S = clothing.translator;

clothing.sewing_table = appliances.appliance:new(
    {
      node_name_inactive = "clothing:sewing_table",
      node_name_active = "clothing:sewing_table_active",
      
      node_description = S("Sewing table"),
      node_help = S("Sewing clothes from fabric and yarn.").."\n"..
                  S("Powered by punching."),
      
      input_stack = "input",
      input_stack_size = 9,
      input_stack_width = 3,
      use_stack = "input",
      use_stack_size = 0,
      have_usage = false,
    }
  );

local sewing_table = clothing.sewing_table;

sewing_table:power_data_register(
  {
    ["punch_power"] = {
        run_speed = 1,
      },
  })

--------------
-- Formspec --
--------------

function sewing_table:get_formspec(meta, production_percent, consumption_percent)
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
      "clothing_sewing_table_needle.png"
    },
    mesh = "clothing_sewing_table.obj",
  }
local active_node = {
    tiles = {
      "default_wood.png",
      "default_junglewood.png",
      "wool_white.png",
      "clothing_sewing_table_needle.png"
    },
    use_texture_alpha = "clip",
    mesh = "clothing_sewing_table.obj",
  }

sewing_table:register_nodes(node_def, inactive_node, active_node)

-------------------------
-- Recipe Registration --
-------------------------

appliances.register_craft_type("clothing_sewing", {
    description = S("Sewing"),
    icon = "clothing_bone_needle.png",
    width = 3,
    height = 3,
  })

for color, data in pairs(clothing.colors) do
	local fabric, yarn, yarn2, def

	fabric = "clothing:fabric_"..color
	if data.key1 and data.key1 ~= data.key2 then
		yarn = "clothing:yarn_spool_"..data.key1;
		yarn2 = "clothing:yarn_spool_"..data.key2;
	else
		yarn = "clothing:yarn_spool_"..color
	end
	def = {consumption_step_size = 1}

	-- hat
	def.outputs = {{"clothing:hat_"..color,"clothing:yarn_spool_empty"}}
	def.inputs = {
		fabric, fabric, fabric,
		fabric, yarn, fabric,
		"", "", "",
	}
	def.production_time = 30
	sewing_table:recipe_register_input("", table.copy(def))
	if yarn2 then
		def.inputs = {
			fabric, fabric, fabric,
			fabric, yarn2, fabric,
			"", "", "",
		}
		sewing_table:recipe_register_input("", table.copy(def))
	end

	-- shirt
	def.outputs = {{"clothing:shirt_"..color,"clothing:yarn_spool_empty"}}
	def.inputs = {
		fabric, "clothing:undershirt_"..color, fabric,
		fabric, yarn, fabric,
		"", "", "",
	}
	def.production_time = 60
	sewing_table:recipe_register_input("", table.copy(def))
	if yarn2 then
		def.inputs = {
			fabric, "clothing:undershirt_"..color, fabric,
			fabric, yarn2, fabric,
			"", "", "",
		}
		sewing_table:recipe_register_input("", table.copy(def))
	end

	-- pants
	def.outputs = {{"clothing:pants_"..color,"clothing:yarn_spool_empty"}}
	def.inputs = {
		fabric, fabric, fabric,
		fabric, yarn, fabric,
		fabric, "", fabric,
	}
	def.production_time = 60
	sewing_table:recipe_register_input("", table.copy(def))
	if yarn2 then
		def.inputs = {
			fabric, fabric, fabric,
			fabric, yarn2, fabric,
			fabric, "", fabric,
		}
		sewing_table:recipe_register_input("", table.copy(def))
	end

	-- cape
	def.outputs = {{"clothing:cape_"..color,"clothing:yarn_spool_empty"}}
	def.inputs = {
		fabric, fabric, yarn,
		fabric, fabric, "",
		fabric, fabric, "",
	}
	def.production_time = 30
	sewing_table:recipe_register_input("", table.copy(def))
	if yarn2 then
		def.inputs = {
			fabric, fabric, yarn2,
			fabric, fabric, "",
			fabric, fabric, "",
		}
		sewing_table:recipe_register_input("", table.copy(def))
	end

	-- hood mask
	def.outputs = {{"clothing:hood_mask_"..color,"clothing:yarn_spool_empty"}}
	def.inputs = {
		fabric, fabric, fabric,
		"", fabric, "",
		fabric, yarn, fabric,
	}
	def.production_time = 45
	sewing_table:recipe_register_input("", table.copy(def))
	if yarn2 then
		def.inputs = {
			fabric, fabric, fabric,
			"", fabric, "",
			fabric, yarn2, fabric,
		}
		sewing_table:recipe_register_input("", table.copy(def))
	end

	-- glove left
	def.outputs = {{"clothing:glove_left_"..color,"clothing:yarn_spool_empty"}}
	def.inputs = {
		fabric, yarn, "",
		"", "", "",
		"", "", "",
	}
	def.production_time = 30
	sewing_table:recipe_register_input("", table.copy(def))
	if yarn2 then
		def.inputs = {
			fabric, yarn2, "",
			"", "", "",
			"", "", "",
		}
		sewing_table:recipe_register_input("", table.copy(def))
	end

	-- glove right
	def.outputs = {{"clothing:glove_right_"..color,"clothing:yarn_spool_empty"}}
	def.inputs = {
		fabric, yarn, "",
		"", "", "",
		"", "", "",
	}
	-- def.production_time = 30 -- the same as glove left
	sewing_table:recipe_register_input("", table.copy(def))
	if yarn2 then
		def.inputs = {
			fabric, yarn2, "",
			"", "", "",
			"", "", "",
		}
		sewing_table:recipe_register_input("", table.copy(def))
	end

	-- shortshirt
	def.outputs = {{"clothing:shortshirt_"..color,"clothing:yarn_spool_empty"}}
	def.inputs = {
		fabric, yarn, fabric,
		fabric, fabric, fabric,
		fabric, fabric, fabric,
	}
	def.production_time = 45
	sewing_table:recipe_register_input("", table.copy(def))
	if yarn2 then
		def.inputs = {
			fabric, yarn2, fabric,
			fabric, fabric, fabric,
			fabric, fabric, fabric,
		}
		sewing_table:recipe_register_input("", table.copy(def))
	end

	-- shorts
	def.outputs = {{"clothing:shorts_"..color,"clothing:yarn_spool_empty"}}
	def.inputs = {
		"", yarn, "",
		fabric, fabric, fabric,
		fabric, "", fabric,
	}
	def.production_time = 45
	sewing_table:recipe_register_input("", table.copy(def))
	if yarn2 then
		def.inputs = {
			"", yarn2, "",
			fabric, fabric, fabric,
			fabric, "", fabric,
		}
		sewing_table:recipe_register_input("", table.copy(def))
	end

	-- shoes
	if not yarn2 then
		def.outputs = {{"clothing:shoes_"..color,"clothing:yarn_spool_empty 2"}}
		def.inputs = {
			yarn, "", yarn,
			fabric, "", fabric,
			fabric, "", fabric,
		}
		def.production_time = 60
		sewing_table:recipe_register_input("", table.copy(def))
	end

  for picture, pic_data in pairs(clothing.pictures) do
    local inputs = {};
    local cloth_index = 2;
    local spools = 0;
    
    for r_i, r_v in pairs(pic_data.recipe) do
      if (r_v=="CLOTH") then
        cloth_index = r_i;
      elseif (r_v~="") then
        if (clothing.basic_colors[r_v]==nil) then
          minetest.log("error", "Use of undefined yarn color "..r_v..".");
        end
        inputs[r_i] = "clothing:yarn_spool_"..r_v;
        spools = spools + 1;
      else
        inputs[r_i] = "";
      end
    end
    
    spools = ItemStack("clothing:yarn_spool_empty "..spools):to_string();
    
    inputs[cloth_index] = "clothing:shirt_"..color;
    sewing_table:recipe_register_input(
      "",
      {
        inputs = table.copy(inputs),
        outputs = {{"clothing:shirt_"..color.."_picture_"..picture,spools}},
        production_time = pic_data.production_time,
        consumption_step_size = 1,
      });
    
    inputs[2] = "clothing:cape_"..color;
    sewing_table:recipe_register_input(
      "",
      {
        inputs = table.copy(inputs),
        outputs = {{"clothing:cape_"..color.."_picture_"..picture,spools}},
        production_time = pic_data.production_time,
        consumption_step_size = 1,
      });
  end
end

sewing_table:register_recipes("clothing_sewing", "")

