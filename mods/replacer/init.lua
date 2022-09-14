
          
--[[
    Replacement tool for creative building (Mod for MineTest)
    Copyright (C) 2013 Sokomine

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]

-- Version 3.0

-- Changelog: 
-- 02.09.2021 * Added a history of stored patterns (not saved over server restart)
--            * Added a menu to select a history entry. It is accessable via AUX1 + left click.
--            * Removed deprecated functions get/set_metadata(..) and renamed metadata to pattern
-- 29.09.2021 * AUX1 key works now same as SNEAK key for storing new pattern (=easier when flying)
--            * The description of the tool now shows which pattern is stored
--            * The description of the stored pattern is more human readable
-- 09.12.2017 * Got rid of outdated minetest.env
--            * Fixed error in protection function.
--            * Fixed minor bugs.
--            * Added blacklist
-- 02.10.2014 * Some more improvements for inspect-tool. Added craft-guide.
-- 01.10.2014 * Added inspect-tool.
-- 12.01.2013 * If digging the node was unsuccessful, then the replacement will now fail
--              (instead of destroying the old node with its metadata; i.e. chests with content)
-- 20.11.2013 * if the server version is new enough, minetest.is_protected is used
--              in order to check if the replacement is allowed
-- 24.04.2013 * param1 and param2 are now stored
--            * hold sneak + right click to store new pattern
--            * right click: place one of the itmes 
--            * receipe changed
--            * inventory image added

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")    
-- adds a function to check ownership of a node; taken from VanessaEs homedecor mod
dofile(minetest.get_modpath("replacer").."/check_owner.lua");

replacer = {
	blacklist = {},
};

local max_charge = 50000
local power_usage = 200

-- playing with tnt and creative building are usually contradictory
-- (except when doing large-scale landscaping in singleplayer)
replacer.blacklist[ "tnt:boom"] = true;
replacer.blacklist[ "tnt:gunpowder"] = true;
replacer.blacklist[ "tnt:gunpowder_burning"] = true;
replacer.blacklist[ "tnt:tnt"] = true;

-- prevent accidental replacement of your protector
replacer.blacklist[ "protector:protect"] = true;
replacer.blacklist[ "protector:protect2"] = true;

-- adds a tool for inspecting nodes and entities
-- dofile(minetest.get_modpath("replacer").."/inspect.lua");

-- adds a formspec with a history function (accessible with AUX1 + left click)
dofile(minetest.get_modpath("replacer").."/fs_history.lua");

-- adds support for the circular saw from moreblocks and similar nodes
-- and allows to replace the *material* while keeping shape - or vice versa
dofile(minetest.get_modpath("replacer").."/mode_of_replacement.lua");

local function replacer_on_place(itemstack, placer, pointed_thing)
	if not placer or not pointed_thing then
		return itemstack
	end
	local player_name = placer:get_player_name()
	local meta = minetest.deserialize(itemstack:get_metadata())
	local charge = meta and meta.charge
	if not player_name or not charge or charge < power_usage then
		return itemstack
	end
	local player_keys = placer:get_player_control()

	if not player_keys.sneak and not player_keys.aux1 then
		itemstack = replacer.replace(itemstack, placer, pointed_thing, 0) or itemstack
	elseif pointed_thing.type ~= "node" then
		ch_core.systemovy_kanal(player_name, "Elektrický nahrazovač: CHYBA: Není vybrán žádný blok.")
		return nil
	else
		local pos = minetest.get_pointed_thing_position(pointed_thing, false) -- node under
		local node = minetest.get_node_or_nil(pos)
		local pattern
		if node and node.name then
			pattern = node.name.." "..node.param1.." "..node.param2
		else
			pattern = "default:dirt 0 0"
		end
		itemstack = replacer.set_to(player_name, pattern, placer, itemstack) or itemstack -- nothing consumed but data changed
	end

	if not minetest.is_creative_enabled(player_name) then
		meta.charge = charge - power_usage
		technic.set_RE_wear(itemstack, meta.charge, max_charge)
		itemstack:set_metadata(minetest.serialize(meta))
	end
	return itemstack
end

local function replacer_on_use(itemstack, user, pointed_thing)
	if not user or not pointed_thing then
		return itemstack
	end
	local player_name = user:get_player_name()
	local meta = minetest.deserialize(itemstack:get_metadata())
	local charge = meta and meta.charge
	if not player_name or not charge or charge < power_usage then
		return itemstack
	end
	local pos = minetest.get_pointed_thing_position(pointed_thing, false)
	minetest.sound_play("mining_drill", {
		pos = pos,
		gain = 1.0,
		max_hear_distance = 10,
	})
	itemstack = replacer.replace(itemstack, user, pointed_thing, false) or itemstack
	if not minetest.is_creative_enabled(player_name) then
		meta.charge = charge - power_usage
		technic.set_RE_wear(itemstack, meta.charge, max_charge)
		itemstack:set_metadata(minetest.serialize(meta))
	end
	return itemstack
end

technic.register_power_tool("replacer:replacer", max_charge)

minetest.register_tool( "replacer:replacer",
{
    description = "elektrický nahrazovač",
    _ch_help = "Vyvrtá blok a současně ho na místě nahradí jiným, dříve zapamatovaným.\nLevý klik vyvrtá blok a nahradí zapamatovaným, pravý klik umístí zapamatovaný blok,\nShift + pravý klik si zapamatuje blok, Aux1 + levý klik vyvolá ovládací panel nahrazovače.\nElektrický nástroj — před použitím nutno nabít.",
    groups = {}, 
    inventory_image = "replacer_replacer.png",
    wield_image = "",
    wield_scale = {x=1,y=1,z=1},
    stack_max = 1, -- it has to store information - thus only one can be stacked
    liquids_pointable = true, -- it is ok to painit in/with water
--[[
    -- the tool_capabilities are of nearly no intrest here
    tool_capabilities = {
        full_punch_interval = 1.0,
        max_drop_level=0,
        groupcaps={
            -- For example:
            fleshy={times={[2]=0.80, [3]=0.40}, maxwear=0.05, maxlevel=1},
            snappy={times={[2]=0.80, [3]=0.40}, maxwear=0.05, maxlevel=1},
            choppy={times={[3]=0.90}, maxwear=0.05, maxlevel=0}
        }
    },
--]]
    node_placement_prediction = nil,
    on_place = replacer_on_place,
    on_use = replacer_on_use,
	-- technic:
	wear_represents = "technic_RE_charge",
	on_refill = technic.refill_RE_charge,
})


replacer.replace = function( itemstack, user, pointed_thing, mode )

       if( user == nil or pointed_thing == nil) then
          return nil;
       end
       local name = user:get_player_name();
 
       if( pointed_thing.type ~= "node" ) then
          minetest.chat_send_player( name, "  Chyba: Žádný blok.");
          return nil;
       end

       local pos  = minetest.get_pointed_thing_position( pointed_thing, mode );
       local node = minetest.get_node_or_nil( pos );
       
       if( node == nil ) then

          minetest.chat_send_player( name, "Chyba: Cílový blok ještě není načtený. Počkejte prosím, než se server vzpamatuje.");
          return nil;
       end


       local meta = itemstack:get_meta()
       local pattern = meta:get_string("pattern")

       -- make sure it is defined
       if(not(pattern) or pattern == "") then
          pattern = "default:dirt 0 0";
       end

       local keys=user:get_player_control();
       if( keys["aux1"]) then
           minetest.show_formspec(name, "replacer:menu", replacer.get_formspec(name, pattern, user))
           return nil
       end

       -- regain information about nodename, param1 and param2
       local daten = pattern:split( " " );
       -- the old format stored only the node name
       if( #daten < 3 ) then
          daten[2] = 0;
          daten[3] = 0;
       end

       -- if someone else owns that node then we can not change it
       if( replacer_homedecor_node_is_owned(pos, user)) then

          return nil;
       end

       local daten = replacer.get_new_node_data(node, daten, name)
       -- nothing to replace
       if(not(daten)) then
          return
       end

       if( node.name and node.name ~= "" and replacer.blacklist[ node.name ]) then
          minetest.chat_send_player( name, "Nahrazování bloků typu '"..( node.name or "?" )..
		"' není na tomto serveru dovoleno. Nahrazení selhalo.");
          return nil;
       end

       if( replacer.blacklist[ daten[1] ]) then
          minetest.chat_send_player( name, "Umísťování bloků typu '"..( daten[1] or "?" )..
		"' nahrazovačem není na tomto serveru dovoleno. Nahrazení selhalo.");
          return nil;
       end

       -- do not replace if there is nothing to be done
       if( node.name == daten[1] ) then

          -- the node itshelf remains the same, but the orientation was changed
          if( node.param1 ~= daten[2] or node.param2 ~= daten[3] ) then
             minetest.add_node( pos, { name = node.name, param1 = daten[2], param2 = daten[3] } );
          end

          return nil;
       end

       -- in survival mode, the player has to provide the node he wants to place
       if( not(minetest.settings:get_bool("creative_mode") )
	  and not( minetest.check_player_privs( name, {creative=true}))) then
 
          -- players usually don't carry dirt_with_grass around; it's safe to assume normal dirt here
          -- fortunately, dirt and dirt_with_grass does not make use of rotation
          if( daten[1] == "default:dirt_with_grass" ) then
             daten[1] = "default:dirt";
             pattern = "default:dirt 0 0";
          end

          -- does the player carry at least one of the desired nodes with him?
          if( not( user:get_inventory():contains_item("main", daten[1]))) then
 

             minetest.chat_send_player( name, "Již nemáte žádné další '"..( daten[1] or "?" ).."'. Nahrazení selhalo.");
             return nil;
          end


          -- give the player the item by simulating digging if possible
          if(   node.name ~= "air" 
            and node.name ~= "ignore") then

             minetest.node_dig( pos, node, user );

             local digged_node = minetest.get_node_or_nil( pos );
             if( not( digged_node ) 
                or digged_node.name == node.name ) then

                -- some nodes - like liquids - cannot be digged. but they are buildable_to and
                -- thus can be replaced
                local node_def = minetest.registered_nodes[node.name]
                if(not(node_def) or not(node_def.buildable_to)) then
                   minetest.chat_send_player( name, "Nahrazení '"..( node.name or "air" ).."' s '"..( pattern or "?" ).."' selhalo. Nemohu odstranit původní blok.");
                   return nil;
                end
             end
            
          end

          -- consume the item
          user:get_inventory():remove_item("main", daten[1].." 1");
       end
       minetest.add_node( pos, { name =  daten[1], param1 = daten[2], param2 = daten[3] } );
       return nil; -- no item shall be removed from inventory
    end


--[[
minetest.register_craft({
        output = 'replacer:replacer',
        recipe = {
                { 'default:chest', '',              '' },
                { '',              'default:stick', '' },
                { '',              '',              'default:chest' },
        }
})
]]

minetest.register_craft({
	output = "replacer:replacer",
	recipe = {
		{"default:mese", "", "moreores:mithril_ingot"},
		{"", "technic:mining_drill", ""},
		{"moreores:mithril_ingot", "", "default:mese"},
	},
})

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
