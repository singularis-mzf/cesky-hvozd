--[[ smooth5x5.lua
   Terrain smoothing library for a voxel game.
   Generated with GLM 5.2

   Public interface:
       smooth_5x5(x, z, input, options) -> changes_table | nil, err
--]]

local M = {}

----------------------------------------------------------------------------
-- 1. Raw shape table (mirrored from the assignment, rotation 0)
----------------------------------------------------------------------------

local RAW_SHAPES = {
    [""] = {
        [7] = 0.5, [8] = 0.5, [9] = 0.5,
        [4] = 0.5, [5] = 0.5, [6] = 0.5,
        [1] = 0.5, [2] = 0.5, [3] = 0.5,
    },
    ["slab/"] = {
        [7] = 0, [8] = 0, [9] = 0,
        [4] = 0, [5] = 0, [6] = 0,
        [1] = 0, [2] = 0, [3] = 0,
    },
    ["slope/"] = {
        [7] = 0.5,  [8] = 0.5,  [9] = 0.5,
        [4] = 0,    [5] = 0,    [6] = 0,
        [1] = -0.5, [2] = -0.5, [3] = -0.5,
    },
    ["slope/_half"] = {
        [7] = 0,    [8] = 0,    [9] = 0,
        [4] = -0.25,[5] = -0.25,[6] = -0.25,
        [1] = -0.5, [2] = -0.5, [3] = -0.5,
    },
    ["slope/_half_raised"] = {
        [7] = 0.5,  [8] = 0.5,  [9] = 0.5,
        [4] = 0.25, [5] = 0.25, [6] = 0.25,
        [1] = 0,    [2] = 0,    [3] = 0,
    },
    ["slope/_inner"] = {
        [7] = 0.5, [8] = 0.5, [9] = 0.5,
        [4] = 0.5, [5] = 0,   [6] = 0,
        [1] = 0.5, [2] = 0,   [3] = -0.5,
    },
    ["slope/_outer"] = {
        [7] = 0.5,  [8] = 0,    [9] = -0.5,
        [4] = 0,    [5] = 0,    [6] = -0.5,
        [1] = -0.5, [2] = -0.5, [3] = -0.5,
    },
    ["slope/_cut"] = {
        [7] = 0.5, [8] = 0.25,  [9] = 0,
        [4] = 0.25,[5] = 0,     [6] = -0.25,
        [1] = 0,   [2] = -0.25, [3] = -0.5,
    },
    ["slope/_inner_cut"] = {
        [7] = 1.5, [8] = 1,   [9] = 0.5,
        [4] = 1,   [5] = 0.5, [6] = 0,
        [1] = 0.5, [2] = 0,   [3] = -0.5,
    },
    ["slope/_inner_half"] = {
        [7] = 0, [8] = 0,     [9] = 0,
        [4] = 0, [5] = -0.25, [6] = -0.25,
        [1] = 0, [2] = -0.25, [3] = -0.5,
    },
    ["slope/_inner_half_raised"] = {
        [7] = 0.5, [8] = 0.5,  [9] = 0.5,
        [4] = 0.5, [5] = 0.25, [6] = 0.25,
        [1] = 0.5, [2] = 0.25, [3] = 0,
    },
    ["slope/_inner_cut_half_raised"] = {
        [7] = 1,   [8] = 0.75, [9] = 0.5,
        [4] = 0.75,[5] = 0.5,  [6] = 0.25,
        [1] = 0.5, [2] = 0.25, [3] = 0,
    },
    ["slope/_outer_half"] = {
        [7] = 0,    [8] = -0.25, [9] = -0.5,
        [4] = -0.25,[5] = -0.25, [6] = -0.5,
        [1] = -0.5, [2] = -0.5,  [3] = -0.5,
    },
}

-- Deterministic shape ordering (the order listed in the assignment).
local SHAPE_ORDER = {
    "",
    "slab/",
    "slope/",
    "slope/_half",
    "slope/_half_raised",
    "slope/_inner",
    "slope/_outer",
    "slope/_cut",
    "slope/_inner_cut",
    "slope/_inner_half",
    "slope/_inner_half_raised",
    "slope/_inner_cut_half_raised",
    "slope/_outer_half",
}

local SHAPE_INDEX = {}
for i, s in ipairs(SHAPE_ORDER) do SHAPE_INDEX[s] = i - 1 end -- 0-based

local NUM_SHAPES = #SHAPE_ORDER          -- 13
local NUM_GEOMS  = NUM_SHAPES * 4        -- 52

-- point position offsets (in half-units relative to node center)
local PDX = {[1]=-1,[2]=0,[3]=1,[4]=-1,[5]=0,[6]=1,[7]=-1,[8]=0,[9]=1}
local PDZ = {[1]=-1,[2]=-1,[3]=-1,[4]=0,[5]=0,[6]=0,[7]=1,[8]=1,[9]=1}

-- one clockwise step: old position -> new position
local CW = {
    [7] = 9, [8] = 6, [9] = 3,
    [4] = 8, [5] = 5, [6] = 2,
    [1] = 7, [2] = 4, [3] = 1,
}

local BORDER_POINTS = {1,2,3,4,6,7,8,9}

----------------------------------------------------------------------------
-- 2. Precomputation at module load
----------------------------------------------------------------------------

local function qround(v)
    -- v is a multiple of 0.25; convert to integer quarter units
    local q = v * 4
    local r = math.floor(q + 0.5)
    return r
end

-- SHAPES_Q[shape][point] -> integer quarter offset
local SHAPES_Q = {}
for s, rel in pairs(RAW_SHAPES) do
    local t = {}
    for p = 1, 9 do
        local v = rel[p]
        assert(v ~= nil, "shape " .. s .. " missing point " .. p)
        -- load-time self-test: must be exact multiple of 0.25
        local q = v * 4
        assert(math.abs(q - math.floor(q + 0.5)) < 1e-9,
               "shape " .. s .. " point " .. p .. " not multiple of 0.25")
        t[p] = qround(v)
    end
    SHAPES_Q[s] = t
end

-- GEOM_RELQ[geom_id][point] -> integer quarter offset (already rotated)
-- geom_id = shape_index * 4 + rotation   (0-based, 0..51)
local GEOM_RELQ = {}
local GEOM_SHAPE = {}
local GEOM_ROT   = {}

for si = 0, NUM_SHAPES - 1 do
    local sname = SHAPE_ORDER[si + 1]
    local base = SHAPES_Q[sname]
    local rot_tables = {}
    for rot = 0, 3 do
        if rot == 0 then
            rot_tables[0] = base
        else
            local prev = rot_tables[rot - 1]
            local cur = {}
            for old = 1, 9 do
                local np = CW[old]
                cur[np] = prev[old]
            end
            rot_tables[rot] = cur
        end
        local gid = si * 4 + rot
        GEOM_RELQ[gid] = rot_tables[rot]
        GEOM_SHAPE[gid] = sname
        GEOM_ROT[gid]   = rot
    end
end

-- lookup: (shape, rotation) -> geom_id
local function geom_id_of(shape, rot)
    local si = SHAPE_INDEX[shape]
    if si == nil then return nil end
    return si * 4 + rot
end

----------------------------------------------------------------------------
-- 3. Small helpers
----------------------------------------------------------------------------

local function is_int(v)
    return type(v) == "number" and math.floor(v) == v
end

local function dbg(options, fmt, ...)
    if options and options.debug then
        print(string.format(fmt, ...))
    end
end

-- deterministic 32-bit key for (x,z) used only for debug/tie hashing
local function pack16(v)
    return bit.band(v + 32768, 0xffff)
end
local function key32(x, z)
    return bit.bor(bit.lshift(pack16(x), 16), pack16(z))
end

local function lex_less(a, b)
    -- true if tuple a is lexicographically less than tuple b
    for i = 1, #a do
        if a[i] ~= b[i] then return a[i] < b[i] end
    end
    return false
end

----------------------------------------------------------------------------
-- 4. Input validation
----------------------------------------------------------------------------

local function validate(x, z, input, options)
    if type(input) ~= "table" then
        return nil, "input must be a table"
    end
    if not is_int(x) or not is_int(z) then
        return nil, "x and z must be integers"
    end
    if options ~= nil and type(options) ~= "table" then
        return nil, "options must be nil or a table"
    end
    if options ~= nil and options.debug ~= nil and type(options.debug) ~= "boolean" then
        return nil, "options.debug must be a boolean"
    end
    -- spike_bias: optional non-negative number (default 1) controlling how
    -- strongly the optimizer prefers "ridges" (a single low outlier in a
    -- border-point group) over "spikes" (a single high outlier) when the
    -- total mismatch cannot be reduced.  0 disables the preference.
    if options ~= nil and options.spike_bias ~= nil
       and type(options.spike_bias) ~= "number" then
        return nil, "options.spike_bias must be a number"
    end
    if options ~= nil and type(options.spike_bias) == "number"
       and options.spike_bias < 0 then
        return nil, "options.spike_bias must be >= 0"
    end

    -- central node
    local row = input[x]
    if type(row) ~= "table" then
        return nil, "central node row missing"
    end
    local cnode = row[z]
    if type(cnode) ~= "table" then
        return nil, "central node missing"
    end
    if cnode.fixed == true then
        return nil, "central node must not be fixed"
    end

    -- validate every defined node inside the 5x5 area
    for dx = -2, 2 do
        local nx = x + dx
        local r = input[nx]
        if type(r) == "table" then
            for dz = -2, 2 do
                local nz = z + dz
                local n = r[nz]
                if n ~= nil then
                    if type(n) ~= "table" then
                        return nil, string.format("node at (%d,%d) must be a table", nx, nz)
                    end
                    if not is_int(n.y) then
                        return nil, string.format("node at (%d,%d) has non-integer y", nx, nz)
                    end
                    if type(n.shape) ~= "string" or SHAPE_INDEX[n.shape] == nil then
                        return nil, string.format("node at (%d,%d) has invalid shape", nx, nz)
                    end
                    local rot = n.rotation
                    if not is_int(rot) or rot < 0 or rot > 3 then
                        return nil, string.format("node at (%d,%d) has invalid rotation", nx, nz)
                    end
                    if n.fixed ~= nil and type(n.fixed) ~= "boolean" then
                        return nil, string.format("node at (%d,%d) has invalid fixed flag", nx, nz)
                    end
                end
            end
        end
    end

    return true
end

----------------------------------------------------------------------------
-- 5. Normalization
----------------------------------------------------------------------------

-- point position key
local function poskey(hx, hz)
    return hx * 100003 + hz  -- unique integer (hx,hz small range here)
end

-- Determine the set of outward border points required to be preserved
-- for an outer-ring node at relative offset (dx, dz).
local function border_required_points(dx, dz)
    local pts = {}
    if dx == -2 then for _,p in ipairs({7,4,1}) do pts[#pts+1]=p end end
    if dx ==  2 then for _,p in ipairs({9,6,3}) do pts[#pts+1]=p end end
    if dz == -2 then for _,p in ipairs({1,2,3}) do pts[#pts+1]=p end end
    if dz ==  2 then for _,p in ipairs({7,8,9}) do pts[#pts+1]=p end end
    -- de-duplicate (corner points appear in two edges)
    local seen = {}
    local out = {}
    for _, p in ipairs(pts) do
        if not seen[p] then seen[p] = true out[#out+1] = p end
    end
    return out
end

local function normalize(x, z, input)
    local grid = {}           -- grid[nx][nz] = node
    local nodes = {}          -- flat list
    local n_fixed = 0
    local n_defined = 0
    local n_undef = 0

    for dx = -2, 2 do
        local nx = x + dx
        local r = input[nx]
        grid[nx] = {}
        for dz = -2, 2 do
            local nz = z + dz
            local inNode = r and r[nz]
            if type(inNode) == "table" then
                local fixed = (inNode.fixed == true)
                local orig_geom = geom_id_of(inNode.shape, inNode.rotation)
                local orig_yq = math.floor(inNode.y) * 4
                local ring = math.max(math.abs(dx), math.abs(dz))
                local breq = {}
                if ring == 2 then
                    breq = border_required_points(dx, dz)
                end
                local node = {
                    x = nx, z = nz, dx = dx, dz = dz,
                    fixed = fixed,
                    ring = ring,
                    orig_yq = orig_yq,
                    orig_geom = orig_geom,
                    yq = orig_yq,
                    geom = orig_geom,
                    border_req = breq,
                    border_req_q = {},  -- p -> required absolute quarter elevation
                    pts = {},           -- [p] = { group=gid|nil, absq=int }
                    hkey = key32(nx, nz),
                }
                for _, p in ipairs(breq) do
                    node.border_req_q[p] = orig_yq + GEOM_RELQ[orig_geom][p]
                end
                grid[nx][nz] = node
                nodes[#nodes + 1] = node
                n_defined = n_defined + 1
                if fixed then n_fixed = n_fixed + 1 end
            else
                n_undef = n_undef + 1
            end
        end
    end

    -- build interior border-point groups
    -- map poskey -> { hx=, hz=, entries={{node,p},...} }
    local gmap = {}
    local gkeys = {}
    for _, node in ipairs(nodes) do
        for _, p in ipairs(BORDER_POINTS) do
            local hx = 2 * node.x + PDX[p]
            local hz = 2 * node.z + PDZ[p]
            local k = poskey(hx, hz)
            local g = gmap[k]
            if g == nil then
                g = { hx = hx, hz = hz, entries = {} }
                gmap[k] = g
                gkeys[#gkeys + 1] = k
            end
            g.entries[#g.entries + 1] = { node = node, p = p }
        end
    end

    -- assign group ids to positions with >=2 entries, sorted by (hz, hx)
    local groups = {}
    for _, k in ipairs(gkeys) do
        local g = gmap[k]
        if #g.entries >= 2 then
            groups[#groups + 1] = g
        end
    end
    table.sort(groups, function(a, b)
        if a.hz ~= b.hz then return a.hz < b.hz end
        return a.hx < b.hx
    end)

    -- assign gid and link nodes
    -- group_stats[gid] = { n, sum_h, sum_h2, sum_h3 }.
    -- sum_h3 (sum of absq^3) is maintained so that the group's third central
    -- moment ("skew") can be computed exactly and incrementally.  skew is used
    -- as a tie-breaker preferring ridges (one low outlier) over spikes (one
    -- high outlier) at equal mismatch.
    local group_stats = {}
    for gid, g in ipairs(groups) do
        g.gid = gid
        local n, sum_h, sum_h2, sum_h3 = 0, 0, 0, 0
        for _, e in ipairs(g.entries) do
            local node = e.node
            local p = e.p
            local absq = node.yq + GEOM_RELQ[node.geom][p]
            node.pts[p] = { group = gid, absq = absq }
            n = n + 1
            sum_h = sum_h + absq
            sum_h2 = sum_h2 + absq * absq
            sum_h3 = sum_h3 + absq * absq * absq
        end
        group_stats[gid] = { n = n, sum_h = sum_h, sum_h2 = sum_h2, sum_h3 = sum_h3 }
    end
    -- fill center points (p=5) for all nodes (no group)
    for _, node in ipairs(nodes) do
        node.pts[5] = { group = nil, absq = node.yq + GEOM_RELQ[node.geom][5] }
    end

    return {
        x = x, z = z,
        grid = grid,
        nodes = nodes,
        groups = groups,
        group_stats = group_stats,
        n_defined = n_defined,
        n_fixed = n_fixed,
        n_undef = n_undef,
    }
end

----------------------------------------------------------------------------
-- 6. Group mismatch helpers
----------------------------------------------------------------------------

local function group_mismatch(stats)
    return stats.n * stats.sum_h2 - stats.sum_h * stats.sum_h
end

-- Group skew (third central moment, scaled by n^2 so it stays an integer):
--   skew = n^2 * sum(h^3) - 3*n * sum(h^2) * sum(h) + 2 * sum(h)^3
-- Positive => the group has a high "spike" outlier; negative => a low
-- "ridge" outlier.  The optimizer minimizes total skew as a tie-breaker at
-- equal mismatch, so ridges are preferred over spikes.
local function group_skew(stats)
    local n = stats.n
    return n * n * stats.sum_h3
           - 3 * n * stats.sum_h2 * stats.sum_h
           + 2 * stats.sum_h * stats.sum_h * stats.sum_h
end

local function total_mismatch(state)
    local s = 0
    for gid = 1, #state.groups do
        s = s + group_mismatch(state.group_stats[gid])
    end
    return s
end

local function total_skew(state)
    local s = 0
    for gid = 1, #state.groups do
        s = s + group_skew(state.group_stats[gid])
    end
    return s
end

----------------------------------------------------------------------------
-- 7. Center residual
----------------------------------------------------------------------------

local function neighbor_centers(state, node)
    -- defined 4-neighbors' current center absq
    local sum, n = 0, 0
    local g = state.grid
    local function try(nx, nz)
        local row = g[nx]
        local nd = row and row[nz]
        if nd then
            sum = sum + nd.pts[5].absq
            n = n + 1
        end
    end
    try(node.x - 1, node.z)
    try(node.x + 1, node.z)
    try(node.x, node.z - 1)
    try(node.x, node.z + 1)
    if n == 0 then return nil end
    return math.floor(sum / n + 0.5)
end

local function center_resid_of(state, node, center_absq_override)
    local target = neighbor_centers(state, node)
    if target == nil then return 0 end
    local c = center_absq_override or node.pts[5].absq
    local d = c - target
    return d * d
end

-- residual for node i plus its defined neighbors (targets may depend on i)
local function affected_center_residual(state, node, new_center)
    local res = center_resid_of(state, node, new_center)
    local g = state.grid
    local function add(nx, nz)
        local row = g[nx]
        local nd = row and row[nz]
        if nd then res = res + center_resid_of(state, nd) end
    end
    add(node.x - 1, node.z)
    add(node.x + 1, node.z)
    add(node.x, node.z - 1)
    add(node.x, node.z + 1)
    return res
end

local function total_center_residual(state)
    local s = 0
    for _, node in ipairs(state.nodes) do
        s = s + center_resid_of(state, node)
    end
    return s
end

----------------------------------------------------------------------------
-- 8. Change penalty
----------------------------------------------------------------------------

local function node_change_penalty(node)
    local changed = (node.yq ~= node.orig_yq or node.geom ~= node.orig_geom)
    local shape_rot_changed = (node.geom ~= node.orig_geom)
    local p = 0
    if changed then p = p + 1000 end
    if shape_rot_changed then p = p + 10 end
    p = p + math.floor(math.abs(node.yq - node.orig_yq) / 4)
    return p
end

local function total_change_penalty(state)
    local s = 0
    for _, node in ipairs(state.nodes) do
        if not node.fixed then
            s = s + node_change_penalty(node)
        end
    end
    return s
end

local function total_movement(state)
    local s = 0
    for _, node in ipairs(state.nodes) do
        if not node.fixed then
            s = s + math.abs(node.yq - node.orig_yq)
        end
    end
    return s
end

-- full lexicographic energy tuple.
-- Component order (lexicographic, most significant first):
--   1. total interior mismatch   (never make the terrain rougher)
--   2. total skew * spike_bias    (prefer ridges over spikes at equal mismatch;
--                                  spike_bias==0 disables this term entirely)
--   3. change penalty            (stability / minimal node changes)
--   4. total base-y movement
--   5. center-point residual      (low-weight smoothness)
-- spike_bias is stored on the state by optimize(); default is 1.
local function energy_tuple(state)
    return {
        total_mismatch(state),
        total_skew(state) * (state.spike_bias or 1),
        total_change_penalty(state),
        total_movement(state),
        total_center_residual(state),
    }
end

----------------------------------------------------------------------------
-- 9. Candidate generation
----------------------------------------------------------------------------

local function gen_candidates(node)
    -- returns list of { yq = , geom = } (deterministic order)
    local cands = {}
    if node.fixed then
        cands[1] = { yq = node.orig_yq, geom = node.orig_geom }
        return cands
    end

    local lo = node.orig_yq - 20
    local hi = node.orig_yq + 20

    if #node.border_req > 0 then
        -- outer-ring non-fixed node: border equalities must hold
        local breq = node.border_req
        local breqq = node.border_req_q
        for gid = 0, NUM_GEOMS - 1 do
            local rel = GEOM_RELQ[gid]
            -- implied yq from first required point
            local p0 = breq[1]
            local yq = breqq[p0] - rel[p0]
            if yq % 4 == 0 and yq >= lo and yq <= hi then
                local ok = true
                for j = 2, #breq do
                    local p = breq[j]
                    if yq + rel[p] ~= breqq[p] then ok = false break end
                end
                if ok then
                    cands[#cands + 1] = { yq = yq, geom = gid }
                end
            end
        end
        -- original is always present (added naturally above); guarantee fallback
        if #cands == 0 then
            cands[1] = { yq = node.orig_yq, geom = node.orig_geom }
        end
    else
        -- interior non-fixed node
        for yq = lo, hi, 4 do
            for gid = 0, NUM_GEOMS - 1 do
                cands[#cands + 1] = { yq = yq, geom = gid }
            end
        end
    end
    return cands
end

----------------------------------------------------------------------------
-- 10. Candidate delta evaluation (without applying)
----------------------------------------------------------------------------

-- Compute the delta tuple (relative to current state) of switching `node`
-- to candidate (yq_new, geom_new). Returns { dM, dSkew, dC, dMov, dCenter }.
-- dSkew is the change in total skew (third central moment of group border
-- point elevations) scaled by the spike bias.  At equal mismatch a move
-- that lowers the total skew turns a high "spike" outlier into a low
-- "ridge" outlier and is preferred; see group_skew / energy_tuple.
local function eval_candidate(state, node, yq_new, geom_new)
    local rel_new = GEOM_RELQ[geom_new]
    local bias = state.spike_bias or 1

    -- 1. group mismatch and skew delta
    local dM = 0
    local dSkew = 0
    for _, p in ipairs(BORDER_POINTS) do
        local pt = node.pts[p]
        if pt and pt.group then
            local gid = pt.group
            local st = state.group_stats[gid]
            local old_absq = pt.absq
            local new_absq = yq_new + rel_new[p]
            if old_absq ~= new_absq then
                local n = st.n
                local s, s2, s3 = st.sum_h, st.sum_h2, st.sum_h3
                local old_m = n * s2 - s * s
                local old_sk = n * n * s3 - 3 * n * s2 * s + 2 * s * s * s
                local ns  = s  - old_absq + new_absq
                local ns2 = s2 - old_absq * old_absq + new_absq * new_absq
                local ns3 = s3 - old_absq * old_absq * old_absq
                              + new_absq * new_absq * new_absq
                local new_m  = n * ns2 - ns * ns
                local new_sk = n * n * ns3 - 3 * n * ns2 * ns + 2 * ns * ns * ns
                dM = dM + (new_m - old_m)
                dSkew = dSkew + (new_sk - old_sk) * bias
            end
        end
    end

    -- 2. change penalty delta (only this node)
    local old_pen = node_change_penalty(node)
    local yq_old, geom_old = node.yq, node.geom
    node.yq, node.geom = yq_new, geom_new
    local new_pen = node_change_penalty(node)
    node.yq, node.geom = yq_old, geom_old
    local dC = new_pen - old_pen

    -- 3. movement delta
    local dMov = math.abs(yq_new - node.orig_yq) - math.abs(yq_old - node.orig_yq)

    -- 4. center residual delta
    local old_res = affected_center_residual(state, node, nil)
    local new_center = yq_new + rel_new[5]
    local new_res = affected_center_residual(state, node, new_center)
    -- affected_center_residual uses neighbor centers which are unchanged;
    -- but for the node itself we pass new_center; for neighbors, their
    -- target recomputation uses node.pts[5].absq which is still old.
    -- Recompute neighbors' residual with the new center by temporarily
    -- swapping node.pts[5].absq.
    local saved = node.pts[5].absq
    node.pts[5].absq = new_center
    local new_res2 = center_resid_of(state, node, new_center)
    local function neigh_res(nx, nz)
        local row = state.grid[nx]
        local nd = row and row[nz]
        if nd then return center_resid_of(state, nd) end
        return 0
    end
    new_res2 = new_res2
        + neigh_res(node.x - 1, node.z)
        + neigh_res(node.x + 1, node.z)
        + neigh_res(node.x, node.z - 1)
        + neigh_res(node.x, node.z + 1)
    node.pts[5].absq = saved
    local dCenter = new_res2 - old_res

    return { dM, dSkew, dC, dMov, dCenter }
end

-- Apply a candidate to the state (updates group stats and node fields,
-- including the sum_h3 used for the skew tie-breaker).
local function apply_candidate(state, node, yq_new, geom_new)
    local rel_new = GEOM_RELQ[geom_new]
    for _, p in ipairs(BORDER_POINTS) do
        local pt = node.pts[p]
        local new_absq = yq_new + rel_new[p]
        if pt then
            if pt.group then
                local st = state.group_stats[pt.group]
                local old_absq = pt.absq
                st.sum_h = st.sum_h - old_absq + new_absq
                st.sum_h2 = st.sum_h2 - old_absq * old_absq + new_absq * new_absq
                st.sum_h3 = st.sum_h3 - old_absq * old_absq * old_absq
                              + new_absq * new_absq * new_absq
            end
            pt.absq = new_absq
        end
    end
    node.pts[5].absq = yq_new + rel_new[5]
    node.yq = yq_new
    node.geom = geom_new
end

----------------------------------------------------------------------------
-- 11. Visitation order
----------------------------------------------------------------------------

local VISIT_ORDER = {}
do
    -- center first
    VISIT_ORDER[1] = {0, 0}
    -- ring 1 clockwise from NW
    local ring1 = {
        {-1, 1}, {0, 1}, {1, 1}, {1, 0}, {1, -1}, {0, -1}, {-1, -1}, {-1, 0},
    }
    -- ring 2 clockwise from NW corner
    local ring2 = {
        {-2, 2}, {-1, 2}, {0, 2}, {1, 2}, {2, 2},
        {2, 1}, {2, 0}, {2, -1}, {2, -2},
        {1, -2}, {0, -2}, {-1, -2}, {-2, -2},
        {-2, -1}, {-2, 0}, {-2, 1},
    }
    local idx = 1
    for _, v in ipairs(ring1) do idx = idx + 1; VISIT_ORDER[idx] = v end
    for _, v in ipairs(ring2) do idx = idx + 1; VISIT_ORDER[idx] = v end
end

----------------------------------------------------------------------------
-- 12. Coordinate descent search
----------------------------------------------------------------------------

local MAX_PASSES = 8

local function optimize(state, options)
    -- spike_bias controls the ridge-over-spike tie-breaker (see energy_tuple).
    -- nil -> 1 (default preference), 0 disables.  Stored on the state so that
    -- energy_tuple and eval_candidate share one consistent value.
    state.spike_bias = options and options.spike_bias or 1
    local init_energy = energy_tuple(state)

    dbg(options, "[smooth] defined=%d fixed=%d undef=%d groups=%d",
        state.n_defined, state.n_fixed, state.n_undef, #state.groups)
    dbg(options, "[smooth] init energy M=%d Skew=%d C=%d Mov=%d Center=%d",
        init_energy[1], init_energy[2], init_energy[3], init_energy[4],
        init_energy[5])

    for pass = 1, MAX_PASSES do
        local improved_in_pass = 0
        for _, off in ipairs(VISIT_ORDER) do
            local dx, dz = off[1], off[2]
            local nx, nz = state.x + dx, state.z + dz
            local row = state.grid[nx]
            local node = row and row[nz]
            if node and not node.fixed then
                local cands = gen_candidates(node)
                local best_delta = nil
                local best_cand = nil
                for _, c in ipairs(cands) do
                    -- skip the candidate identical to current (no-op)
                    if c.yq ~= node.yq or c.geom ~= node.geom then
                        local d = eval_candidate(state, node, c.yq, c.geom)
                        -- strict improvement: delta must be lexicographically < 0
                        if lex_less(d, {0, 0, 0, 0, 0}) then
                            if best_delta == nil or lex_less(d, best_delta) then
                                best_delta = d
                                best_cand = c
                            end
                        end
                    end
                end
                if best_cand then
                    apply_candidate(state, node, best_cand.yq, best_cand.geom)
                    improved_in_pass = improved_in_pass + 1
                end
            end
        end
        dbg(options, "[smooth] pass %d improvements=%d", pass, improved_in_pass)
        if improved_in_pass == 0 then break end
    end

    local final_energy = energy_tuple(state)
    dbg(options, "[smooth] final energy M=%d Skew=%d C=%d Mov=%d Center=%d",
        final_energy[1], final_energy[2], final_energy[3], final_energy[4],
        final_energy[5])
end

----------------------------------------------------------------------------
-- 13. Output construction
----------------------------------------------------------------------------

local function build_output(state)
    -- deterministic order by (x, z)
    local list = {}
    for _, node in ipairs(state.nodes) do
        if not node.fixed then
            local changed = (node.yq ~= node.orig_yq) or (node.geom ~= node.orig_geom)
            if changed then
                list[#list + 1] = node
            end
        end
    end
    table.sort(list, function(a, b)
        if a.x ~= b.x then return a.x < b.x end
        return a.z < b.z
    end)
    local out = {}
    local seen = {}
    for _, node in ipairs(list) do
        local k = node.x .. "," .. node.z
        if not seen[k] then
            seen[k] = true
            out[#out + 1] = {
                x = node.x,
                z = node.z,
                y = node.yq / 4,
                shape = GEOM_SHAPE[node.geom],
                rotation = GEOM_ROT[node.geom],
            }
        end
    end
    return out
end

----------------------------------------------------------------------------
-- 14. Public function
----------------------------------------------------------------------------

function M.smooth_5x5(x, z, input, options)
    local ok, err = validate(x, z, input, options)
    if not ok then
        dbg(options, "[smooth] validation failed: %s", err)
        return nil, err
    end
    options = options or {}
    local state = normalize(x, z, input)
    optimize(state, options)
    local out = build_output(state)
    dbg(options, "[smooth] changed nodes: %d", #out)
    return out
end

--[[ expose internals for testing
M._internal = {
    RAW_SHAPES = RAW_SHAPES,
    SHAPES_Q = SHAPES_Q,
    GEOM_RELQ = GEOM_RELQ,
    GEOM_SHAPE = GEOM_SHAPE,
    GEOM_ROT = GEOM_ROT,
    SHAPE_INDEX = SHAPE_INDEX,
    SHAPE_ORDER = SHAPE_ORDER,
    NUM_GEOMS = NUM_GEOMS,
    CW = CW,
    PDX = PDX, PDZ = PDZ,
    geom_id_of = geom_id_of,
    validate = validate,
    normalize = normalize,
    gen_candidates = gen_candidates,
}
]]

return assert(M.smooth_5x5)
-- return M
