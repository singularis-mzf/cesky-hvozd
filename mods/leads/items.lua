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


--- Item definitions.
-- @module items


local S = leads.S;


minetest.register_craftitem('leads:lead',
{
    description      = S'Lead';
    inventory_image  = 'leads_lead_inv.png';
    on_use           = leads.on_lead_use;
    on_secondary_use = leads.on_lead_use;
    on_place         = leads.on_lead_use;
    _leads_length    = leads.settings.lead_length;
});


local rope = leads.util.first_available_item('farming:string', 'mcl_mobitems:string', 'rp_default:rope', 'hades_farming:cotton', 'nodes_nature:chalin') or 'group:string';
local glue = leads.util.first_available_item('mesecons_materials:glue', 'mcl_mobitems:slimeball', 'mobs_mc:slimeball', 'rp_default:fiber')              or rope;
minetest.register_craft(
{
    output = 'leads:lead';
    recipe =
    {
        {rope, rope, ''},
        {rope, glue, ''},
        {'',   '',   rope},
    };
});
