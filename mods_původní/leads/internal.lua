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


--- Internal functions and overrides.
-- @module internal


leads.interaction_blockers = {};


local function _default_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
    return minetest.item_place_node(itemstack, clicker, pointed_thing);
end;

--- Adds a right-click handler to knottable nodes.
-- @param name [string] The name of the node.
-- @param def  [table]  The node definition.
-- @local
function leads._after_register_node(name, def)
    if leads.is_knottable(name) then
        local old_on_rightclick = def.on_rightclick or _default_on_rightclick;
        local function on_rightclick(pos, node, clicker, itemstack, pointed_thing, ...)
            if leads.knot(clicker, pos) then
                return nil;
            end;
            return old_on_rightclick(pos, node, clicker, itemstack, pointed_thing, ...);
        end;
        minetest.override_item(name, {on_rightclick = on_rightclick});
    end;
end;


local old_is_protected = minetest.is_protected;
function minetest.is_protected(pos, name)
    if leads.interaction_blockers[name] then
        return true;
    end;
    return old_is_protected(pos, name);
end;


for name, def in pairs(minetest.registered_nodes) do
    leads._after_register_node(name, def);
end;

local old_register_node = minetest.register_node;
function minetest.register_node(name, def)
    old_register_node(name, def);
    leads._after_register_node(name, def);
end;
