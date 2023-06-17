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


--- Public API functions.
-- @module api


local S = leads.S;


leads.custom_leashable_entities =
{
    ['boats:boat']  = true;
};

leads.custom_knottable_nodes =
{
    ['ferns:fern_trunk']                    = true;
    ['ethereal:bamboo']                     = true;
    ['advtrains:signal_off']                = true;
    ['advtrains:signal_on']                 = true;
    ['advtrains:retrosignal_off']           = true;
    ['advtrains:retrosignal_on']            = true;
    ['nodes_nature:mahal']                  = true;
    ['hades_furniture:binding_rusty_bars']  = true;
};

leads.sounds =
{
    attach  = {name = 'leads_attach',  gain = 0.5,  pitch = 0.75};
    remove  = {name = 'leads_remove',  gain = 0.5,  pitch = 0.75};
    stretch = {name = 'leads_stretch', gain = 0.25, pitch = 1.25, duration = 2.5};
    snap    = {name = 'leads_break',   gain = 0.75};
};


--- Creates a lead between two objects.
-- @param  leader   [ObjectRef]     The leader object.
-- @param  follower [ObjectRef]     The follower object.
-- @param  item     [string]        The lead item, or nil.
-- @return          [ObjectRef|nil] The lead object, or nil on failure.
-- @return          [string|nil]    A string describing the error, or nil on success.
function leads.connect_objects(leader, follower, item)
    if leads.util.is_same_object(leader, follower) then
        return nil, S'You cannot leash something to itself.';
    end;

    local item_def = minetest.registered_items[item];
    if not item_def then
        return nil, S'Invalid lead item.';
    end;

    local l_pos = leader:get_pos();
    local f_pos = follower:get_pos();

    if leads.settings.debug then
        minetest.debug(debug.traceback(('[Leads] Connecting L:%s to F:%s.'):format(leads.util.describe_object(leader), leads.util.describe_object(follower))));
    end;

    local centre = (l_pos + f_pos) / 2;

    local object = minetest.add_entity(centre, 'leads:lead');
    if not object then
        return nil, S'Failed to create lead.';
    end;

    local entity = object:get_luaentity();
    entity.leader     = leader;
    entity.follower   = follower;
    entity.item       = item;
    entity.max_length = item_def._leads_length or leads.settings.lead_length;
    entity:update_visuals();
    entity:update_objref_ids();
    entity:notify_connector_added(leader,   true);
    entity:notify_connector_added(follower, false);
    minetest.sound_play(leads.sounds.attach, {pos = centre}, true);
    return object;
end;


--- Checks if the object can be attached to a lead.
-- @param object [ObjectRef] The object to check.
-- @return       [boolean]   true if the object can be attached to a lead.
function leads.is_leashable(object)
    -- Player:
    if minetest.is_player(object) then
        return leads.settings.allow_leash_players;
    end;

    -- All entities allowed in settings:
    if leads.settings.allow_leash_all then
        return true;
    end;

    -- Get entity:
    local entity = object:get_luaentity();
    if not entity then
        return false;
    end;

    -- Custom leashable:
    local leashable = entity._leads_leashable or leads.custom_leashable_entities[entity.name];
    if leashable ~= nil then
        return leashable;
    end;

    -- Animals:
    return leads.util.is_animal(object);
end;


--- Checks if the node can have lead knots tied to it.
-- @param name [string]  The name of a node.
-- @return     [boolean] true if the node is knottable.
function leads.is_knottable(name)
    local def = minetest.registered_nodes[name];
    if not def then
        return false;
    end;

    -- Custom knottable:
    if def._leads_knottable or leads.custom_knottable_nodes[name] then
        return true;
    end;

    -- Fence:
    if def.drawtype == 'fencelike' or minetest.get_item_group(name, 'fence') > 0 then
        return true;
    end;

    -- Mese post:
    if name:match('.*:mese_post_.*') then
        return true;
    end;

    -- Lord of the Test fences:
    -- (These aren't in group:fence due to a bug.)
    if name:match('^lottblocks:fence_.*') then
        return true;
    end;

    return false;
end;


--- Finds a lead connected to the specified leader.
-- If there are multiple matching leads, one is chosen arbitrarily.
-- @param leader [ObjectRef]     The player or entity to find leads connected to.
-- @return       [ObjectRef|nil] The lead, if any.
function leads.find_lead_by_leader(leader)
    for lead in leads.find_connected_leads(leader, true, false) do
        return lead;
    end;
    return nil;
end;


--- Finds leads connected to the specified object.
-- @param connector       [ObjectRef] The player or entity to find leads connected to.
-- @param accept_leader   [boolean]   Find leads where the specified object is the leader.
-- @param accept_follower [boolean]   Find leads where the specified object is the follower.
-- @return                [function]  An iterator of (lead: ObjectRef, is_leader: boolean).
function leads.find_connected_leads(connector, accept_leader, accept_follower)
    local function _iter()
        local objects = minetest.get_objects_inside_radius(connector:get_pos(), 24);
        for __, lead in ipairs(objects) do
            local entity = lead:get_luaentity();
            if entity and entity.name == 'leads:lead' then
                if accept_leader and entity.leader and leads.util.is_same_object(entity.leader, connector) then
                    coroutine.yield(lead, true);
                elseif accept_follower and entity.follower and leads.util.is_same_object(entity.follower, connector) then
                    coroutine.yield(lead, false);
                end;
            end;
        end;
    end;

    return coroutine.wrap(_iter);
end;


--- Ties the leader's lead to a post.
-- @param leader [ObjectRef]     The leader whose lead to tie.
-- @param pos    [vector]        Where to tie the knot.
-- @return       [ObjectRef|nil] The knot object, or nil on failure.
function leads.knot(leader, pos)
    -- Find a lead attached to the player:
    local lead = leads.find_lead_by_leader(leader);
    if not lead then
        return nil;
    end;

    -- Create a knot:
    local knot = leads.add_knot(pos);
    if not knot then
        return nil;
    end;

    -- Play sound:
    minetest.sound_play(leads.sounds.attach, {pos = pos}, true);

    -- Attach the lead to the knot:
    lead:get_luaentity():set_leader(knot);
    return knot;
end;


--- Adds a knot on a fence post, or finds an existing one.
-- @param pos [vector]        Where to tie the knot.
-- @return    [ObjectRef|nil] A new or existing knot, or nil if creating the knot failed.
function leads.add_knot(pos)
    pos = pos:round();

    for __, object in ipairs(minetest.get_objects_in_area(pos, pos)) do
        local entity = object:get_luaentity();
        if entity and entity.name == 'leads:knot' then
            return object;
        end;
    end;

    return minetest.add_entity(pos, 'leads:knot');
end;


--- Checks if the specified object is immobile, and cannot be moved with a lead.
-- @param object [ObjectRef|nil] The object to check.
-- @return       [boolean]       true if the object is immobile.
function leads.is_immobile(object)
    local entity = object and object:get_luaentity();
    return entity and entity._leads_immobile or false;
end;


--- The `on_use` handler for lead items.
-- @param itemstack     [ItemStack]     The player's held item.
-- @param user          [ObjectRef]     The player using the lead.
-- @param pointed_thing [PointedThing]  The pointed-thing.
-- @return              [ItemStack|nil] The leftover itemstack, or nil for no change.
function leads.on_lead_use(itemstack, user, pointed_thing)
    local function _message(message)
        if leads.settings.chat_messages then
            minetest.chat_send_player(user:get_player_name(), message);
        end;
    end;

    if pointed_thing.under then
        -- Clicking on a node:
        local node = minetest.get_node(pointed_thing.under);
        if leads.is_knottable(node.name) then
            -- Knot existing lead:
            if leads.knot(user, pointed_thing.under) then
                return nil;
            -- Create new lead with knot:
            else
                local knot = leads.add_knot(pointed_thing.under);
                if not knot then
                    return nil;
                end;
                leads.connect_objects(user, knot, itemstack:get_name());
            end;
        end;

    else
        -- Clicking on an object:
        local object = pointed_thing.ref;
        if not object then
            return nil;
        end;

        -- The player right-clicked on a knot — try knotting their lead before making a new one:
        local entity = object:get_luaentity();
        if entity and entity.name == 'leads:knot' then
            if leads.knot(user, object:get_pos()) then
                return nil;
            end;
        end;

        -- Make sure the object is leashable:
        if not leads.is_leashable(object) then
            _message(S'You cannot leash this.');
            return nil;
        end;

        -- Hold Aux1 to leash an animal to another animal:
        if user:get_player_control().aux1 then
            local lead = leads.find_lead_by_leader(user);
            if lead and lead:get_luaentity():set_leader(object) then
                return;
            end;
        end;

        -- Create the lead:
        local lead, message = leads.connect_objects(user, pointed_thing.ref, itemstack:get_name());
        if not lead then
            _message(message);
            return nil;
        end;
    end;

    -- Consume the lead item:
    if not (minetest.is_player(user) and minetest.is_creative_enabled(user:get_player_name())) then
        itemstack:take_item(1);
    end;
    return itemstack;
end;
