ch_base.open_mod(minetest.get_current_modname())
-- [Mod] Simple Arcs [pkarcs]
-- by PEAK
-- 06-05-2017


--[[

	This mod adds arc-nodes to Minetest as well as arcs for inner and outer
	corners, based on the default stone and wood materials.

	To make arcs from nodes of your mod, put "pkarcs?" into your depends.txt,
	and call this function in your init.lua:

if minetest.get_modpath("pkarcs") then
	pkarcs.register_node("your_mod:your_nodename")
end

	works with Minetest 0.4.16

--]]


pkarcs = {}

-- convert integer coordinates to nodebox coordinates

local function nb(n)
	return n/16-1/2
end

local arc_nodebox = {
	type = "fixed",
	fixed = {
		{ nb(0),  nb(0),  nb(0),     nb(1),  nb(16), nb(16) },
		{ nb(1),  nb(4),  nb(0),     nb(2),  nb(16), nb(16) },
		{ nb(2),  nb(7),  nb(0),     nb(3),  nb(16), nb(16) },
		{ nb(3),  nb(8),  nb(0),     nb(4),  nb(16), nb(16) },
		{ nb(4),  nb(10), nb(0),     nb(5),  nb(16), nb(16) },
		{ nb(5),  nb(11), nb(0),     nb(6),  nb(16), nb(16) },
		{ nb(6),  nb(12), nb(0),     nb(8),  nb(16), nb(16) },
		{ nb(8),  nb(13), nb(0),     nb(9),  nb(16), nb(16) },
		{ nb(9),  nb(14), nb(0),     nb(12), nb(16), nb(16) },
		{ nb(12), nb(15), nb(0),     nb(16), nb(16), nb(16) },
	}
}

local outer_arc_nodebox = {
	type = "fixed",
	fixed = {
		{ nb(0),  nb(0),  nb(16),     nb(1),  nb(16), nb(16-1)  },
		{ nb(0),  nb(4),  nb(16),     nb(2),  nb(16), nb(16-2)  },
		{ nb(0),  nb(7),  nb(16),     nb(3),  nb(16), nb(16-3)  },
		{ nb(0),  nb(8),  nb(16),     nb(4),  nb(16), nb(16-4)  },
		{ nb(0),  nb(10), nb(16),     nb(5),  nb(16), nb(16-5)  },
		{ nb(0),  nb(11), nb(16),     nb(6),  nb(16), nb(16-6)  },
		{ nb(0),  nb(12), nb(16),     nb(8),  nb(16), nb(16-8)  },
		{ nb(0),  nb(13), nb(16),     nb(9),  nb(16), nb(16-9)  },
		{ nb(0),  nb(14), nb(16),     nb(12), nb(16), nb(16-12) },
		{ nb(0),  nb(15), nb(16),     nb(16), nb(16), nb(16-16) },
	}
}

local inner_arc_nodebox = {
	type = "fixed",
	fixed = {
		{ nb(0),  nb(0),  nb(16),     nb(1),  nb(16), nb(0)    },
		{ nb(0),  nb(0),  nb(16),     nb(16), nb(16), nb(16-1) },

		{ nb(0),  nb(4),  nb(16),     nb(2),  nb(16), nb(0)    },
		{ nb(0),  nb(4),  nb(16),     nb(16), nb(16), nb(16-2) },

		{ nb(0),  nb(7),  nb(16),     nb(3),  nb(16), nb(0)    },
		{ nb(0),  nb(7),  nb(16),     nb(16), nb(16), nb(16-3) },

		{ nb(0),  nb(8),  nb(16),     nb(4),  nb(16), nb(0)    },
		{ nb(0),  nb(8),  nb(16),     nb(16), nb(16), nb(16-4) },

		{ nb(0),  nb(10), nb(16),     nb(5),  nb(16), nb(0)    },
		{ nb(0),  nb(10), nb(16),     nb(16), nb(16), nb(16-5) },

		{ nb(0),  nb(11), nb(16),     nb(6),  nb(16), nb(0)    },
		{ nb(0),  nb(11), nb(16),     nb(16), nb(16), nb(16-6) },

		{ nb(0),  nb(12), nb(16),     nb(8),  nb(16), nb(0)    },
		{ nb(0),  nb(12), nb(16),     nb(16), nb(16), nb(16-8) },

		{ nb(0),  nb(13), nb(16),     nb(9),  nb(16), nb(0)    },
		{ nb(0),  nb(13), nb(16),     nb(16), nb(16), nb(16-9) },

		{ nb(0),  nb(14), nb(16),     nb(12), nb(16), nb(0)     },
		{ nb(0),  nb(14), nb(16),     nb(16), nb(16), nb(16-12) },

		{ nb(0),  nb(15), nb(16),     nb(16), nb(16), nb(16-16) },
	}
}

local groups_to_inherit = {
	"cracky",
	"crumbly",
	"flamable",
	"oddly_breakable_by_hand",
	"snappy",
}

local function process_groups(groups)
	local result = {}
	for _, group in ipairs(groups_to_inherit) do
		if groups[group] ~= nil then
			result[group] = groups[group]
		end
	end
	return result
end

-- define nodes

function pkarcs.register_all(nodename, desc, tile, sound, group, craftmaterial)
	local tile_collection
	if type(tile) == "string" then
		tile_collection[1] = tile
	else
		tile_collection = table.copy(tile)
	end

	local def = {
		description = desc..": oblouk",
		paramtype = "light",
		paramtype2 = "facedir",
		tiles = tile_collection,
		drawtype = "nodebox",
		node_box = arc_nodebox,
		groups = group,
		sounds = sound,

		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end

			local p1 = pointed_thing.under
			local p0 = pointed_thing.above
			local param2 = 0

			local placer_pos = placer:get_pos()
			if placer_pos then
				local dir = {
					x = p1.x - placer_pos.x,
					y = p1.y - placer_pos.y,
					z = p1.z - placer_pos.z
				}
				param2 = minetest.dir_to_facedir(dir)
			end

			if p0.y-1 == p1.y then
				param2 = param2 + 20
				if param2 == 21 then
					param2 = 23
				elseif param2 == 23 then
					param2 = 21
				end
			end

			local NROT = 4 -- Number of possible "rotations" (4 Up down left right)
			local rot = param2 % NROT
			local wall = math.floor(param2/NROT)
			if rot >=3 then
				rot = 0
			else
				rot = rot +1
			end
			param2 = wall*NROT+rot

			return minetest.item_place(itemstack, placer, pointed_thing, param2)
		end,
	}
	minetest.register_node(":pkarcs:"..nodename.."_arc", def)

	minetest.register_craft({
		output = "pkarcs:"..nodename.."_arc".." 5",
		recipe = {
			{ craftmaterial, craftmaterial, craftmaterial },
			{ craftmaterial, "",            ""            },
			{ craftmaterial, "",            ""            }
		}
	})

	def = table.copy(def)
	def.description = desc..": blok s obloukem"
	local new_box = {}
	for i, aabb in ipairs(def.node_box.fixed) do
		new_box[i] = { aabb[1], aabb[2] - 1, aabb[3] - 0.005, aabb[4], aabb[5], aabb[6] + 0.005 }
	end
	def.node_box = {type = "fixed", fixed = new_box}
	def.selection_box = def.node_box
	def.collision_box = def.node_box
	def.drop = {
		items = {
			{items = {craftmaterial}},
			{items = {"pkarcs:"..nodename.."_arc"}}
		},
	}
	minetest.register_node(":pkarcs:"..nodename.."_with_arc", def)

	minetest.register_craft({
		output = "pkarcs:"..nodename.."_with_arc",
		recipe = {
			{ craftmaterial, ""},
			{ "pkarcs:"..nodename.."_arc", "" },
		}
	})

	minetest.register_node(":pkarcs:"..nodename.."_outer_arc", {
		description = desc..": vnější oblouk",
		paramtype = "light",
		paramtype2 = "facedir",
		tiles = tile_collection,
		drawtype = "nodebox",
		node_box = outer_arc_nodebox,
		groups = group,
		sounds = sound,

		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end

			local p1 = pointed_thing.under
			local p0 = pointed_thing.above
			local param2 = 0

			local placer_pos = placer:get_pos()
			if placer_pos then
				local dir = {
					x = p1.x - placer_pos.x,
					y = p1.y - placer_pos.y,
					z = p1.z - placer_pos.z
				}
				param2 = minetest.dir_to_facedir(dir)
			end

			if p0.y-1 == p1.y then
				param2 = param2 + 20
				if param2 == 21 then
					param2 = 23
				elseif param2 == 23 then
					param2 = 21
				end
			end

			local NROT = 4 -- Number of possible "rotations" (4 Up down left right)
			local rot = param2 % NROT
			local wall = math.floor(param2/NROT)
			if rot >=3 then
				rot = 0
			else
				rot = rot +1
			end
			param2 = wall*NROT+rot

			return minetest.item_place(itemstack, placer, pointed_thing, param2)
		end,

	})

	minetest.register_craft({
		output = "pkarcs:"..nodename.."_outer_arc".." 5",
		recipe = {
			{ "default:torch", craftmaterial, craftmaterial },
			{ craftmaterial,   "",            ""            },
			{ craftmaterial,   "",            ""            }
		}
	})

	minetest.register_node(":pkarcs:"..nodename.."_inner_arc", {
		description = desc..": vnitřní oblouk",
		paramtype = "light",
		paramtype2 = "facedir",
		tiles = tile_collection,
		drawtype = "nodebox",
		node_box = inner_arc_nodebox,
		groups = group,
		sounds = sound,

		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end

			local p1 = pointed_thing.under
			local p0 = pointed_thing.above
			local param2 = 0

			local placer_pos = placer:get_pos()
			if placer_pos then
				local dir = {
					x = p1.x - placer_pos.x,
					y = p1.y - placer_pos.y,
					z = p1.z - placer_pos.z
				}
				param2 = minetest.dir_to_facedir(dir)
			end

			if p0.y-1 == p1.y then
				param2 = param2 + 20
				if param2 == 21 then
					param2 = 23
				elseif param2 == 23 then
					param2 = 21
				end
			end

			local NROT = 4 -- Number of possible "rotations" (4 Up down left right)
			local rot = param2 % NROT
			local wall = math.floor(param2/NROT)
			if rot >=3 then
				rot = 0
			else
				rot = rot +1
			end
			param2 = wall*NROT+rot

			return minetest.item_place(itemstack, placer, pointed_thing, param2)
		end,

	})

	minetest.register_craft({
		output = "pkarcs:"..nodename.."_inner_arc".." 5",
		recipe = {
			{ "",            craftmaterial,   craftmaterial },
			{ craftmaterial, "default:torch", ""            },
			{ craftmaterial, "",              ""            }
		}
	})

end

-- register nodes

function pkarcs.register_node(name)
	local node_def = minetest.registered_nodes[name]
	if not node_def then
		minetest.log("warning", "[pkarcs] Skipping unknown node: ".. name)
		return
	end
	local node_name = name:split(':')[2]

	if not node_def.tiles then
		node_def.tiles = table.copy(node_def.tile_images)
		node_def.tile_images = nil
	end

	pkarcs.register_all(node_name, node_def.description, node_def.tiles, node_def.sounds, process_groups(node_def.groups), name)
end


-- make arcs for all default stone and wood nodes

pkarcs.register_node("default:cobble")
pkarcs.register_node("default:mossycobble")
pkarcs.register_node("default:desert_cobble")

pkarcs.register_node("default:stone")
pkarcs.register_node("default:stonebrick")
pkarcs.register_node("default:stone_block")

pkarcs.register_node("default:desert_stone")
pkarcs.register_node("default:desert_stonebrick")
pkarcs.register_node("default:desert_stone_block")

pkarcs.register_node("default:desert_sandstone")
pkarcs.register_node("default:desert_sandstone_block")
pkarcs.register_node("default:desert_sandstone_brick")

pkarcs.register_node("default:silver_sandstone")
pkarcs.register_node("default:silver_sandstone_block")
pkarcs.register_node("default:silver_sandstone_brick")

pkarcs.register_node("default:sandstone")
pkarcs.register_node("default:sandstonebrick")
pkarcs.register_node("default:sandstone_block")

pkarcs.register_node("default:brick")

pkarcs.register_node("default:obsidian")
pkarcs.register_node("default:obsidianbrick")
pkarcs.register_node("default:obsidian_block")

pkarcs.register_node("default:wood")
pkarcs.register_node("default:junglewood")
pkarcs.register_node("default:pine_wood")
pkarcs.register_node("default:acacia_wood")
pkarcs.register_node("default:aspen_wood")

pkarcs.register_node("ch_core:plaster_blue")
pkarcs.register_node("ch_core:plaster_cyan")
pkarcs.register_node("ch_core:plaster_dark_green")
pkarcs.register_node("ch_core:plaster_dark_grey")
pkarcs.register_node("ch_core:plaster_green")
pkarcs.register_node("ch_core:plaster_grey")
pkarcs.register_node("ch_core:plaster_medium_amber_s50")
pkarcs.register_node("ch_core:plaster_orange")
pkarcs.register_node("ch_core:plaster_pink")
pkarcs.register_node("ch_core:plaster_red")
pkarcs.register_node("ch_core:plaster_white")
pkarcs.register_node("ch_core:plaster_yellow")

ch_base.close_mod(minetest.get_current_modname())
