--[[
    Leads — Adds leads for transporting animals to Minetest.
    Copyright © 2023, Silver Sandstone <@SilverSandstone@craftodon.social>

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    DEALINGS IN THE SOFTWARE.
]]


--- Generic utility functions.
-- @module util


leads.util = {};

leads.util.rng = PseudoRandom(0x4C656164);


--- Checks if the object is an animal.
-- @param object [ObjectRef] The object to check.
-- @return       [boolean]   true if the object is an animal.
function leads.util.is_animal(object)
    local entity = object:get_luaentity();
    if not entity then
        return false;
    end;

    -- Explicitly marked as an animal:
    if entity._leads_is_animal then
        return true;
    end;

    -- Mobs (Redo) and Repixture:
    if entity.health then
        return true;
    end;

    -- Creatura and Exile:
    if entity.hp and (entity.max_health or entity.max_hp) then
        return true;
    end;

    return false;
end;


--- Tiles a texture to the specified size.
-- @param texture    [string]  The texture to tile.
-- @param src_width  [integer] The input texture's width.
-- @param src_height [integer] The input texture's height.
-- @param out_width  [integer] The resulting texture's width.
-- @param out_height [integer] The resulting texture's height.
-- @return           [string]  A texture string.
function leads.util.tile_texture(texture, src_width, src_height, out_width, out_height)
    texture = leads.util.escape_texture(('(%s)^[resize:%dx%d'):format(texture, src_width, src_height));
    local parts = {'[combine:', out_width, 'x', out_height};
    local y = 0;
    while y < out_height do
        local x = 0;
        while x < out_width do
            table.insert(parts, (':%d,0=%s'):format(x, texture));
            x = x + src_width;
        end;
        y = y + src_height;
    end;
    return table.concat(parts, '');
end;


--- Escapes a texture for use with [combine.
-- @param texture [string] A texture string.
-- @return        [string] An escaped texture string.
function leads.util.escape_texture(texture)
    return string.gsub(texture, '[\\^:]', function(char) return '\\' .. char; end);
end;


--- Serialises the identity (not the state) of an object reference.
-- @param obj [ObjectRef] The object to serialise.
-- @return    [table|nil] A table identifying the object, or nil if the reference is invalid.
function leads.util.serialise_objref(obj)
    if not obj then
        return nil;
    end;

    local result = {pos = obj:get_pos()};
    if minetest.is_player(obj) then
        result.player_name = obj:get_player_name();
    else
        local entity = obj:get_luaentity();
        if not entity then
            return nil;
        end;
        result.name = entity.name;
    end;

    return result;
end;


--- Deserialises an object ID previously returned from `serialise_objref()`, trying to identify the original object.
-- @param id [table|nil] A table identifying an object.
-- @return   [ObjectRef] An object matching the ID, or nil if no such object was found.
function leads.util.deserialise_objref(id)
    if not id then
        return nil;
    end;

    if id.player_name then
        return minetest.get_player_by_name(id.player_name);
    end;

    if not id.pos then
        return nil;
    end;
    local pos = vector.new(id.pos);

    -- Minetest doesn't provide any way to persistently identify Lua entities,
    -- so the best we can do is look for an entity with the correct name near
    -- the saved position.
    local range = 3;
    local range_min = pos:offset(-range, -range, -range);
    local range_max = pos:offset( range,  range,  range);
    local objects = minetest.get_objects_in_area(range_min, range_max);
    local best_object = nil;
    local best_distance = math.huge;
    for __, object in ipairs(objects) do
        local entity = object:get_luaentity();
        if entity and (id.name == nil or entity.name == id.name) then
            local distance = object:get_pos():distance(pos);
            if distance <= 0.0 then
                return object;
            elseif distance < best_distance then
                best_distance = distance;
                best_object = object;
            end;
        end;
    end;

    return best_object;
end;


--- Checks if two objrefs refer to the same object, which may be a player or entity.
-- @param obj1 [ObjectRef|nil] The first object to compare.
-- @param obj2 [ObjectRef|nil] The second object to compare.
-- @return     [boolean]       true if obj1 and obj2 reference the same object.
function leads.util.is_same_object(obj1, obj2)
    if not (obj1 and obj2) then
        return false;
    end;

    local obj1_is_player = minetest.is_player(obj1);
    local obj2_is_player = minetest.is_player(obj2);
    if obj1_is_player ~= obj2_is_player then
        return false;
    end;

    if obj1_is_player then
        return obj1:get_player_name() == obj2:get_player_name();
    else
        return obj1:get_luaentity() == obj2:get_luaentity();
    end;
end;


--- Returns the relative attachment position for the specified object.
-- @param object [ObjectRef|nil] The player or entity to check.
-- @return       [vector]        The attachment offset as a vector relative to the object's origin.
function leads.util.get_attach_offset(object)
    local properties = object and object:get_properties();
    if not properties then
        return vector.zero();
    end;
    local hitbox = (properties.physical and properties.collisionbox) or (properties.pointable and properties.selectionbox) or {};
    local bottom = hitbox[2] or 0;
    local top    = hitbox[5] or 0;
    return vector.new(0, (bottom + top) / 2, 0);
end;


--- Finds the first item available for crafting.
-- @param ... [string]     Any number of prefixed node/item IDs.
-- @return    [string|nil] One of the specified IDs, or nil.
function leads.util.first_available_item(...)
    for __, name in ipairs{...} do
        if name == '' or string.match(name, '^group:.*') or minetest.registered_items[name] then
            return name;
        end;
    end;
    return nil;
end;


--- Returns a string describing an object, for debugging.
-- @param object [ObjectRef] An object reference.
-- @return       [string]    A string describing the object.
function leads.util.describe_object(object)
    if minetest.is_player(object) then
        return ('[Player %q]'):format(object:get_player_name());
    end;

    local entity = object:get_luaentity();
    if entity then
        return ('[LuaEntity %q]'):format(entity.name);
    end;

    return '[Unknown object]';
end;


--- Prevents the player from interacting for some time.
-- @param name [string] The name of the player.
-- @param time [number] How long to block interactions, in seconds.
function leads.util.block_player_interaction(name, time)
    local function _callback()
        leads.interaction_blockers[name] = nil;
    end;

    local old_timer = leads.interaction_blockers[name];
    if old_timer then
        old_timer:cancel();
    end;

    leads.interaction_blockers[name] = minetest.after(time, _callback);
end;
