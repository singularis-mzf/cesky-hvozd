-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

advtrains_attachment_offset_patch = {};

--! Tries to get the parent implementation of @p method_name
--! for the luaentity @p wagon_entity.
--!
--! The luaentity has the entity definition as metatable,
--! so the overriden method can be accessed directly.
--! This function gets the metatable of the entity definition,
--! to get the original method implementation.
--!
--! Returns nil otherwise.
local function get_parent_method(wagon_entity, method_name)
    local luaentity_prototype_metatable = getmetatable(wagon_entity);
    local luaentity_prototype = luaentity_prototype_metatable.__index;

    local original_metatable = getmetatable(luaentity_prototype);
    if not (original_metatable and original_metatable.__index) then
        minetest.debug("Could not find parent method " .. method_name .. " in table", dump(luaentity_prototype_metatable));
        return nil;
    end

    local original_prototype = original_metatable.__index;

    if original_prototype[method_name] then
        return original_prototype[method_name];
    else
        minetest.debug("Could not find parent method " .. method_name .. " in table", dump(original_metatable));
        return nil;
    end
end

--! Calls the wagon’s get_on() method,
--! and then inserts the attachment dummy in the attachment chain.
--!
--! After executing the original get_on() method,
--! it is checked whether the player is now attached to the wagon.
--! In that case, a new dummy entity is attached at that position,
--! and the player is attached to the dummy without offset.
function advtrains_attachment_offset_patch.get_on_override(self, clicker, seatno)
    local parent_get_on = get_parent_method(self, "get_on");
    if not parent_get_on then
        return;
    end

    parent_get_on(self, clicker, seatno);

    local rotation = self.seats[seatno].advtrains_attachment_offset_patch_attach_rotation;
    advtrains_attachment_offset_patch.attach_player(clicker, self.name, rotation);

    advtrains_attachment_offset_patch.cleanup_dummies(self.object);
end

--! Calls the wagon’s get_off() method,
--! and removes attached dummy entities which are left without attached player.
function advtrains_attachment_offset_patch.get_off_override(self, seatno)
    local parent_get_off = get_parent_method(self, "get_off");
    if not parent_get_off then
        return;
    end

    parent_get_off(self, seatno);

    advtrains_attachment_offset_patch.cleanup_dummies(self.object);
end

dofile(minetest.get_modpath("advtrains_attachment_offset_patch") .. "/dummy.lua");
dofile(minetest.get_modpath("advtrains_attachment_offset_patch") .. "/api.lua");
