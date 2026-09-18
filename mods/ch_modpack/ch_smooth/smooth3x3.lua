-- smooth3x3.lua
-- 3x3 terrain smoothing library
-- Generated with GLM 5.2
--
-- Public API:  smooth_3x3(x, z, input, options) -> output_table | nil, errmsg
--
-- All elevation arithmetic is performed in integer "quarter" units (real
-- elevation * 4) so that every comparison and sum is exact on Lua 5.1 doubles.

local M = {}

-- Test/internal access (not part of the public API contract).
M._POINTS = { 1, 2, 3, 4, 6, 7, 8, 9 }
M._PERM = { [1] = 7, [2] = 4, [3] = 1, [4] = 8, [6] = 2, [7] = 9, [8] = 6, [9] = 3 }
M._rotate_once = function(base)
    local r = {}
    for _, old in ipairs(M._POINTS) do
        r[M._PERM[old]] = base[old]
    end
    return r
end
M._ROT = nil   -- assigned below
M._SHAPES = nil
M._PATTERNS = nil
M._SHAPE_INDEX = nil
M._SHAPE_DEFS = nil
M._FROZEN = nil
M._SLOT_OFFSET = nil
M._GROUP_TEMPLATES = nil
M._build_groups = nil
M._gen_candidates = nil
M._validate = nil
M._compute_full_cost = nil

------------------------------------------------------------------------------
-- Point layout and rotation permutation
------------------------------------------------------------------------------

-- The eight border points of a node (point 5 is the node center, unused).
local POINTS = { 1, 2, 3, 4, 6, 7, 8, 9 }

-- One clockwise rotation step in (x, z) space: (dx, dz) -> (dz, -dx).
-- Maps an old point index to the new point index it moves to.
--   7->9, 8->6, 9->3, 4->8, 6->2, 1->7, 2->4, 3->1
local PERM = M._PERM

local function rotate_once(base)
    return M._rotate_once(base)
end
M._rotate_once_local = rotate_once

------------------------------------------------------------------------------
-- Shape definitions (elevations in quarter units, rotation 0)
------------------------------------------------------------------------------

local SHAPE_DEFS = {
    { name = "",                             [7] = 2,  [8] = 2,  [9] = 2,  [4] = 2,  [6] = 2,  [1] = 2,  [2] = 2,  [3] = 2 },
    { name = "slab/",                        [7] = 0,  [8] = 0,  [9] = 0,  [4] = 0,  [6] = 0,  [1] = 0,  [2] = 0,  [3] = 0 },
    { name = "slope/",                       [7] = 2,  [8] = 2,  [9] = 2,  [4] = 0,  [6] = 0,  [1] = -2, [2] = -2, [3] = -2 },
    { name = "slope/_half",                  [7] = 0,  [8] = 0,  [9] = 0,  [4] = -1, [6] = -1, [1] = -2, [2] = -2, [3] = -2 },
    { name = "slope/_half_raised",           [7] = 2,  [8] = 2,  [9] = 2,  [4] = 1,  [6] = 1,  [1] = 0,  [2] = 0,  [3] = 0 },
    { name = "slope/_inner",                 [7] = 2,  [8] = 2,  [9] = 2,  [4] = 2,  [6] = 0,  [1] = 2,  [2] = 0,  [3] = -2 },
    { name = "slope/_outer",                 [7] = 2,  [8] = 0,  [9] = -2, [4] = 0,  [6] = -2, [1] = -2, [2] = -2, [3] = -2 },
    { name = "slope/_cut",                   [7] = 2,  [8] = 1,  [9] = 0,  [4] = 1,  [6] = -1, [1] = 0,  [2] = -1, [3] = -2 },
    { name = "slope/_inner_cut",             [7] = 6,  [8] = 4,  [9] = 2,  [4] = 4,  [6] = 0,  [1] = 2,  [2] = 0,  [3] = -2 },
    { name = "slope/_inner_half",           [7] = 0,  [8] = 0,  [9] = 0,  [4] = 0,  [6] = -1, [1] = 0,  [2] = -1, [3] = -2 },
    { name = "slope/_inner_half_raised",     [7] = 2,  [8] = 2,  [9] = 2,  [4] = 2,  [6] = 1,  [1] = 2,  [2] = 1,  [3] = 0 },
    { name = "slope/_inner_cut_half_raised", [7] = 4,  [8] = 3,  [9] = 2,  [4] = 3,  [6] = 1,  [1] = 2,  [2] = 1,  [3] = 0 },
    { name = "slope/_outer_half",           [7] = 0,  [8] = -1, [9] = -2, [4] = -1, [6] = -2, [1] = -2, [2] = -2, [3] = -2 },
}

-- ROT[shape_index][rotation][point] -> quarter elevation
local ROT = {}
for si, def in ipairs(SHAPE_DEFS) do
    ROT[si] = {}
    ROT[si][0] = {}
    for _, p in ipairs(POINTS) do ROT[si][0][p] = def[p] end
    for r = 1, 3 do
        ROT[si][r] = rotate_once(ROT[si][r - 1])
    end
end

local SHAPE_INDEX = {}
for si, def in ipairs(SHAPE_DEFS) do SHAPE_INDEX[def.name] = si end

-- Deduplicated elevation patterns. Two (shape, rotation) pairs that produce
-- identical elevation tables collapse to a single canonical representative
-- (the first encountered, in shape-then-rotation order). This is the allowed
-- shape-list-specific optimization: redundant candidates never affect the
-- objective or constraints, only the (shape, rotation) reported, which we
-- reconcile against the input at output time.
local PATTERNS = {}
do
    local seen = {}
    for si, def in ipairs(SHAPE_DEFS) do
        for r = 0, 3 do
            local elev = ROT[si][r]
            local key = {}
            for _, p in ipairs(POINTS) do key[#key + 1] = elev[p] .. "," end
            key = table.concat(key)
            if not seen[key] then
                local e = { shape = def.name, rotation = r, elev = {} }
                for _, p in ipairs(POINTS) do e.elev[p] = elev[p] end
                seen[key] = e
                PATTERNS[#PATTERNS + 1] = e
            end
        end
    end
end

------------------------------------------------------------------------------
-- Slot layout (9 nodes of the 3x3 area) and frozen border points
------------------------------------------------------------------------------

-- Search / slot order: center, then the 4 edge nodes, then the 4 corner nodes.
-- SLOT_OFFSET[slot] = {rx, rz} relative to the central node (x, z).
local SLOT_OFFSET = {
    [1] = { 0, 0 },   -- center
    [2] = { 0, 1 },   -- edge +z
    [3] = { 0, -1 },  -- edge -z
    [4] = { -1, 0 },  -- edge -x
    [5] = { 1, 0 },   -- edge +x
    [6] = { -1, 1 },  -- corner -x,+z
    [7] = { 1, 1 },   -- corner +x,+z
    [8] = { -1, -1 }, -- corner -x,-z
    [9] = { 1, -1 },  -- corner +x,-z
}

-- Frozen border points per slot: border points that lie on the geometric
-- border of the 3x3 area and must keep their original absolute elevation.
local FROZEN = {
    [1] = {},
    [2] = { 7, 8, 9 },
    [3] = { 1, 2, 3 },
    [4] = { 1, 4, 7 },
    [5] = { 3, 6, 9 },
    [6] = { 7, 8, 9, 4, 1 },
    [7] = { 7, 8, 9, 6, 3 },
    [8] = { 1, 2, 3, 4, 7 },
    [9] = { 1, 2, 3, 6, 9 },
}

------------------------------------------------------------------------------
-- Border point group templates (16 total)
--   12 edge-midpoint pairs (6 horizontal, 6 vertical) -> 2 members each
--   4  interior corner-vertex groups              -> 2..4 members
-- Members are referenced as {slot, point}. Undefined members are filtered
-- out per call; groups with fewer than 2 defined members are dropped.
------------------------------------------------------------------------------

local GROUP_TEMPLATES = {
    -- horizontal edge-midpoint pairs: left node point 6, right node point 4
    { { 8, 6 }, { 3, 4 } },
    { { 3, 6 }, { 9, 4 } },
    { { 4, 6 }, { 1, 4 } },
    { { 1, 6 }, { 5, 4 } },
    { { 6, 6 }, { 2, 4 } },
    { { 2, 6 }, { 7, 4 } },
    -- vertical edge-midpoint pairs: lower node point 8, upper node point 2
    { { 8, 8 }, { 4, 2 } },
    { { 4, 8 }, { 6, 2 } },
    { { 3, 8 }, { 1, 2 } },
    { { 1, 8 }, { 2, 2 } },
    { { 9, 8 }, { 5, 2 } },
    { { 5, 8 }, { 7, 2 } },
    -- interior corner-vertex groups (4 nodes each)
    { { 8, 9 }, { 3, 7 }, { 4, 3 }, { 1, 1 } }, -- (cx-0.5, cz-0.5)
    { { 3, 9 }, { 9, 7 }, { 1, 3 }, { 5, 1 } }, -- (cx+0.5, cz-0.5)
    { { 4, 9 }, { 1, 7 }, { 6, 3 }, { 2, 1 } }, -- (cx-0.5, cz+0.5)
    { { 1, 9 }, { 5, 7 }, { 2, 3 }, { 7, 1 } }, -- (cx+0.5, cz+0.5)
}

------------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------------

local function is_int(v)
    return type(v) == "number"
        and v == v                       -- not NaN
        and v ~= math.huge
        and v ~= -math.huge
        and v == math.floor(v)
end

local function abs_q_equal(a, b)
    for _, p in ipairs(POINTS) do
        if a[p] ~= b[p] then return false end
    end
    return true
end

local debug_print = nil -- set per call when options.debug

------------------------------------------------------------------------------
-- Validation + area collection
------------------------------------------------------------------------------

local function validate(x, z, input, options)
    if type(input) ~= "table" then
        return nil, "input must be a table"
    end
    if not is_int(x) or not is_int(z) then
        return nil, "x and z must be integers"
    end
    if options ~= nil and type(options) ~= "table" then
        return nil, "options must be a table or nil"
    end

    -- central node existence / fixed check (deterministic first error)
    local crow = input[x]
    local cnode = crow and crow[z]
    if type(cnode) ~= "table" then
        return nil, "central node (" .. x .. ", " .. z .. ") is missing"
    end
    if cnode.fixed then
        return nil, "central node must not be fixed"
    end

    -- validate all 9 in-area nodes in fixed slot order
    local area = {}
    for slot = 1, 9 do
        local rx, rz = SLOT_OFFSET[slot][1], SLOT_OFFSET[slot][2]
        local nx, nz = x + rx, z + rz
        local r2 = input[nx]
        local node = r2 and r2[nz]
        local info = { slot = slot, rx = rx, rz = rz, x = nx, z = nz, defined = false }

        if node == nil then
            -- undefined/unknown node: allowed, contributes nothing
        elseif type(node) ~= "table" then
            return nil, "node (" .. nx .. ", " .. nz .. ") must be a table"
        else
            if not is_int(node.y) then
                return nil, "node (" .. nx .. ", " .. nz .. "): y must be an integer"
            end
            if type(node.shape) ~= "string" or not SHAPE_INDEX[node.shape] then
                return nil, "node (" .. nx .. ", " .. nz .. "): invalid shape '" .. tostring(node.shape) .. "'"
            end
            if not is_int(node.rotation) or node.rotation < 0 or node.rotation > 3 then
                return nil, "node (" .. nx .. ", " .. nz .. "): rotation must be 0, 1, 2 or 3"
            end
            local si = SHAPE_INDEX[node.shape]
            local elev = ROT[si][node.rotation]
            local abs_q = {}
            for _, p in ipairs(POINTS) do abs_q[p] = 4 * node.y + elev[p] end
            info.defined = true
            info.fixed = (node.fixed == true)
            info.y0 = node.y
            info.shape = node.shape
            info.rotation = node.rotation
            info.abs_q = abs_q
        end
        area[slot] = info
    end
    return area
end

------------------------------------------------------------------------------
-- Candidate generation
------------------------------------------------------------------------------

local function gen_candidates(slot, info)
    if not info.defined then return nil end

    -- Fixed node: exactly one candidate, the original configuration.
    if info.fixed then
        return { { shape = info.shape, rotation = info.rotation, y = info.y0, abs_q = info.abs_q } }
    end

    local frozen = FROZEN[slot]
    local cands = {}

    if #frozen == 0 then
        -- Center node: every pattern x every y in [y0-2, y0+2].
        for pi, pat in ipairs(PATTERNS) do
            for y = info.y0 - 2, info.y0 + 2 do
                local abs_q = {}
                for _, p in ipairs(POINTS) do abs_q[p] = 4 * y + pat.elev[p] end
                cands[#cands + 1] = { shape = pat.shape, rotation = pat.rotation, y = y, abs_q = abs_q, pi = pi }
            end
        end
    else
        -- Constrained node: a pattern admits at most one y, determined by
        -- the frozen points (which must all agree and yield an integer y
        -- within the +/-2 delta bound).
        for pi, pat in ipairs(PATTERNS) do
            local yq = nil
            local ok = true
            for _, p in ipairs(frozen) do
                local need = info.abs_q[p] - pat.elev[p] -- == 4*y
                if yq == nil then
                    yq = need
                elseif yq ~= need then
                    ok = false
                    break
                end
            end
            if ok and yq % 4 == 0 then
                local y = yq / 4
                if y == math.floor(y) and math.abs(y - info.y0) <= 2 then
                    local abs_q = {}
                    for _, p in ipairs(POINTS) do abs_q[p] = 4 * y + pat.elev[p] end
                    cands[#cands + 1] = { shape = pat.shape, rotation = pat.rotation, y = y, abs_q = abs_q, pi = pi }
                end
            end
        end
    end
    return cands
end

------------------------------------------------------------------------------
-- Group instantiation
------------------------------------------------------------------------------

local function build_groups(area)
    local groups = {}
    for _, tmpl in ipairs(GROUP_TEMPLATES) do
        local members = {}
        local sum_orig = 0
        for _, m in ipairs(tmpl) do
            local info = area[m[1]]
            if info.defined then
                members[#members + 1] = { slot = m[1], point = m[2] }
                sum_orig = sum_orig + info.abs_q[m[2]]
            end
        end
        if #members >= 2 then
            groups[#groups + 1] = {
                members = members,
                size = #members,
                sum_orig = sum_orig,
                min = 0, max = 0, sum = 0, count = 0,
            }
        end
    end
    return groups
end

local function build_slot_groups(groups)
    local s2g = {}
    for slot = 1, 9 do s2g[slot] = {} end
    for gidx, g in ipairs(groups) do
        for midx, m in ipairs(g.members) do
            local list = s2g[m.slot]
            list[#list + 1] = { gidx = gidx, point = m.point }
        end
    end
    return s2g
end

------------------------------------------------------------------------------
-- Full cost of a complete assignment (used for the initial incumbent)
------------------------------------------------------------------------------

local function compute_full_cost(groups, abs_q_slot)
    local P, S = 0, 0
    for _, g in ipairs(groups) do
        local mn, mx, sum = nil, nil, 0
        for _, m in ipairs(g.members) do
            local v = abs_q_slot[m.slot][m.point]
            if mn == nil then
                mn, mx = v, v
            else
                if v < mn then mn = v end
                if v > mx then mx = v end
            end
            sum = sum + v
        end
        P = P + (mx - mn)
        S = S + 12 * math.abs(g.sum_orig - sum) / g.size
    end
    return P, S
end

------------------------------------------------------------------------------
-- Search constants
------------------------------------------------------------------------------

local CAP = 4000000 -- safety valve on expansions

------------------------------------------------------------------------------
-- Main entry point
------------------------------------------------------------------------------

function M.smooth_3x3(x, z, input, options)
    debug_print = (type(options) == "table" and options.debug) and print or nil

    local area, err = validate(x, z, input, options)
    if not area then
        return nil, err
    end

    -- Candidates per slot.
    local candidates = {}
    local order = {} -- defined slots in search order
    for slot = 1, 9 do
        local cands = gen_candidates(slot, area[slot])
        candidates[slot] = cands
        if cands then
            order[#order + 1] = slot
        end
    end

    -- Locate the candidate index that reproduces each slot's original abs_q
    -- (the canonical representative of the original pattern). Guaranteed to
    -- exist because the original configuration is always feasible.
    local orig_ci = {}
    for slot = 1, 9 do
        local cands = candidates[slot]
        if cands then
            local oq = area[slot].abs_q
            for ci, c in ipairs(cands) do
                if abs_q_equal(c.abs_q, oq) then
                    orig_ci[slot] = ci
                    break
                end
            end
            -- Fallback (should not happen): first candidate.
            if not orig_ci[slot] then orig_ci[slot] = 1 end
        end
    end

    local groups = build_groups(area)
    local s2g = build_slot_groups(groups)

    -- Per-group secondary term: 12 * |sum_orig - sum| / size  (integer).
    local function term(g)
        return 12 * math.abs(g.sum_orig - g.sum) / g.size
    end

    -- Initial incumbent: the original assignment.
    local orig_abs_q = {}
    for slot = 1, 9 do
        if candidates[slot] then orig_abs_q[slot] = area[slot].abs_q end
    end
    local best_P, best_S = compute_full_cost(groups, orig_abs_q)
    local best_save = {}
    for slot = 1, 9 do best_save[slot] = orig_ci[slot] end

    if debug_print then
        debug_print("[smooth] area slots defined: " .. #order)
        for slot = 1, 9 do
            local c = candidates[slot]
            if c then
                debug_print(string.format("  slot %d (%+d,%+d) defined cands=%d fixed=%s",
                    slot, SLOT_OFFSET[slot][1], SLOT_OFFSET[slot][2], #c,
                    tostring(area[slot].fixed)))
            else
                debug_print(string.format("  slot %d (%+d,%+d) undefined",
                    slot, SLOT_OFFSET[slot][1], SLOT_OFFSET[slot][2]))
            end
        end
        debug_print(string.format("[smooth] groups=%d  initial P=%d S=%d", #groups, best_P, best_S))
    end

    -- Search state.
    local cur_P, cur_S = 0, 0
    local chosen = {}
    local expansions = 0
    local stopped = false

    local function search(depth)
        if stopped then return end
        if depth > #order then
            -- Complete assignment: cur_P/cur_S are exact.
            if cur_P < best_P or (cur_P == best_P and cur_S < best_S) then
                best_P = cur_P
                best_S = cur_S
                for slot = 1, 9 do best_save[slot] = chosen[slot] end
            end
            return
        end
        -- Admissible lower-bound prune (lexicographic).
        if cur_P > best_P or (cur_P == best_P and cur_S >= best_S) then
            return
        end
        if expansions > CAP then
            stopped = true
            return
        end

        local slot = order[depth]
        local cands = candidates[slot]
        local list = s2g[slot]

        for ci = 1, #cands do
            local cand = cands[ci]
            local saved = {}

            -- assign: update every group this slot participates in
            for i = 1, #list do
                local e = list[i]
                local g = groups[e.gidx]
                local oldP = (g.count >= 2 and g.max - g.min or 0)
                local oldS = (g.count == g.size and term(g) or 0)
                saved[i] = { gidx = e.gidx, min = g.min, max = g.max, sum = g.sum, count = g.count, oldP = oldP, oldS = oldS }
                cur_P = cur_P - oldP
                cur_S = cur_S - oldS
                local v = cand.abs_q[e.point]
                if g.count == 0 then
                    g.min, g.max = v, v
                else
                    if v < g.min then g.min = v end
                    if v > g.max then g.max = v end
                end
                g.sum = g.sum + v
                g.count = g.count + 1
                local newP = (g.count >= 2 and g.max - g.min or 0)
                local newS = (g.count == g.size and term(g) or 0)
                cur_P = cur_P + newP
                cur_S = cur_S + newS
            end

            expansions = expansions + 1
            chosen[slot] = ci
            search(depth + 1)

            -- undo
            for i = #list, 1, -1 do
                local s = saved[i]
                local g = groups[s.gidx]
                local cur_newP = (g.count >= 2 and g.max - g.min or 0)
                local cur_newS = (g.count == g.size and term(g) or 0)
                cur_P = cur_P - cur_newP
                cur_S = cur_S - cur_newS
                g.min = s.min
                g.max = s.max
                g.sum = s.sum
                g.count = s.count
                cur_P = cur_P + s.oldP
                cur_S = cur_S + s.oldS
            end

            if stopped then return end
        end
    end

    search(1)

    if debug_print then
        debug_print(string.format("[smooth] expansions=%d  final P=%d S=%d  stopped=%s",
            expansions, best_P, best_S, tostring(stopped)))
    end

    -- Build output: only slots whose abs_q actually changed.
    local out = {}
    for slot = 1, 9 do
        local info = area[slot]
        if info.defined and not info.fixed then
            local cand = candidates[slot][best_save[slot]]
            if not abs_q_equal(cand.abs_q, info.abs_q) then
                out[#out + 1] = {
                    x = info.x,
                    z = info.z,
                    y = cand.y,
                    shape = cand.shape,
                    rotation = cand.rotation,
                }
            end
        end
    end

    -- Deterministic output order: sort by (x, z).
    table.sort(out, function(a, b)
        if a.x ~= b.x then return a.x < b.x end
        return a.z < b.z
    end)

    if debug_print then
        debug_print(string.format("[smooth] output changes=%d", #out))
        for _, o in ipairs(out) do
            debug_print(string.format("  change x=%d z=%d y=%d shape=%q rotation=%d",
                o.x, o.z, o.y, o.shape, o.rotation))
        end
    end

    debug_print = nil
    return out
end

--[[ Expose internals for tests (not part of the public API).
M._ROT = ROT
M._SHAPES = SHAPE_DEFS
M._SHAPE_DEFS = SHAPE_DEFS
M._PATTERNS = PATTERNS
M._SHAPE_INDEX = SHAPE_INDEX
M._FROZEN = FROZEN
M._SLOT_OFFSET = SLOT_OFFSET
M._GROUP_TEMPLATES = GROUP_TEMPLATES
M._build_groups = build_groups
M._gen_candidates = gen_candidates
M._validate = validate
M._compute_full_cost = compute_full_cost
]]

return M.smooth_3x3
