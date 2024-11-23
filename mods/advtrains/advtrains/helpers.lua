--advtrains by orwell96, see readme.txt

local dir_trans_tbl={
	[0]={x=0, z=1, y=0},
	[1]={x=1, z=2, y=0},
	[2]={x=1, z=1, y=0},
	[3]={x=2, z=1, y=0},
	[4]={x=1, z=0, y=0},
	[5]={x=2, z=-1, y=0},
	[6]={x=1, z=-1, y=0},
	[7]={x=1, z=-2, y=0},
	[8]={x=0, z=-1, y=0},
	[9]={x=-1, z=-2, y=0},
	[10]={x=-1, z=-1, y=0},
	[11]={x=-2, z=-1, y=0},
	[12]={x=-1, z=0, y=0},
	[13]={x=-2, z=1, y=0},
	[14]={x=-1, z=1, y=0},
	[15]={x=-1, z=2, y=0},
}

local dir_angle_tbl={}
for d,v in pairs(dir_trans_tbl) do
	local uvec = vector.normalize(v)
	dir_angle_tbl[d] = math.atan2(-uvec.x, uvec.z)
end


function advtrains.dir_to_angle(dir)
	return dir_angle_tbl[dir] or error("advtrains: in helpers.lua/dir_to_angle() given dir="..(dir or "nil"))
end

function advtrains.dirCoordSet(coord, dir)
	return vector.add(coord, advtrains.dirToCoord(dir))
end
advtrains.pos_add_dir = advtrains.dirCoordSet

function advtrains.pos_add_angle(pos, ang)
	-- 0 is +Z -> meaning of sin/cos swapped
	return vector.add(pos, {x = -math.sin(ang), y = 0, z = math.cos(ang)})
end

function advtrains.dirToCoord(dir)
	return dir_trans_tbl[dir] or error("advtrains: in helpers.lua/dir_to_vector() given dir="..(dir or "nil"))
end
advtrains.dir_to_vector = advtrains.dirToCoord

function advtrains.maxN(list, expectstart)
	local n=expectstart or 0
	while list[n] do
		n=n+1
	end
	return n-1
end

function advtrains.minN(list, expectstart)
	local n=expectstart or 0
	while list[n] do
		n=n-1
	end
	return n+1
end

function atround(number)
	return math.floor(number+0.5)
end
atfloor = math.floor


function advtrains.round_vector_floor_y(vec)
	return {x=math.floor(vec.x+0.5), y=math.floor(vec.y), z=math.floor(vec.z+0.5)}
end

function advtrains.yawToDirection(yaw, conn1, conn2)
	if not conn1 or not conn2 then
		error("given nil to yawToDirection: conn1="..(conn1 or "nil").." conn2="..(conn1 or "nil"))
	end
	local yaw1 = advtrains.dir_to_angle(conn1)
	local yaw2 = advtrains.dir_to_angle(conn2)
	local adiff1 = advtrains.minAngleDiffRad(yaw, yaw1)
	local adiff2 = advtrains.minAngleDiffRad(yaw, yaw2)
	
	if math.abs(adiff2)<math.abs(adiff1) then
		return conn2
	else
		return conn1
	end
end

function advtrains.yawToAnyDir(yaw)
	local min_conn, min_diff=0, 10
	for conn, vec in pairs(advtrains.dir_trans_tbl) do
		local yaw1 = advtrains.dir_to_angle(conn)
		local diff = math.abs(advtrains.minAngleDiffRad(yaw, yaw1))
		if diff < min_diff then
			min_conn = conn
			min_diff = diff
		end
	end
	return min_conn
end
function advtrains.yawToClosestConn(yaw, conns)
	local min_connid, min_diff=1, 10
	for connid, conn in ipairs(conns) do
		local yaw1 = advtrains.dir_to_angle(conn.c)
		local diff = math.abs(advtrains.minAngleDiffRad(yaw, yaw1))
		if diff < min_diff then
			min_connid = connid
			min_diff = diff
		end
	end
	return min_connid
end

local pi, pi2 = math.pi, 2*math.pi
function advtrains.minAngleDiffRad(r1, r2)
	while r1>pi2 do
		r1=r1-pi2
	end
	while r1<0 do
		r1=r1+pi2
	end
	while r2>pi2 do
		r2=r2-pi2
	end
	while r1<0 do
		r2=r2+pi2
	end
	local try1=r2-r1
	local try2=r2+pi2-r1
	local try3=r2-pi2-r1
	
	local minabs = math.min(math.abs(try1), math.abs(try2), math.abs(try3))
	if minabs==math.abs(try1) then
		return try1
	end
	if minabs==math.abs(try2) then
		return try2
	end
	if minabs==math.abs(try3) then
		return try3
	end
end


-- Takes 2 connections (0...AT_CMAX) as argument
-- Returns the angle median of those 2 positions from the pov
-- of standing on the cdir1 side and looking towards cdir2
-- cdir1 - >NODE> - cdir2
function advtrains.conn_angle_median(cdir1, cdir2)
	local ang1 = advtrains.dir_to_angle(advtrains.oppd(cdir1))
	local ang2 = advtrains.dir_to_angle(cdir2)
	return ang1 + advtrains.minAngleDiffRad(ang1, ang2)/2
end

function advtrains.merge_tables(a, ...)
	local new={}
	for _,t in ipairs({a,...}) do
		for k,v in pairs(t) do new[k]=v end
	end
	return new
end
function advtrains.save_keys(tbl, keys)
	local new={}
	for _,key in ipairs(keys) do
		new[key] = tbl[key]
	end
	return new
end

function advtrains.get_real_index_position(path, index)
	if not path or not index then return end
	
	local first_pos=path[math.floor(index)]
	local second_pos=path[math.floor(index)+1]
	
	if not first_pos or not second_pos then return nil end
	
	local factor=index-math.floor(index)
	local actual_pos={x=first_pos.x-(first_pos.x-second_pos.x)*factor, y=first_pos.y-(first_pos.y-second_pos.y)*factor, z=first_pos.z-(first_pos.z-second_pos.z)*factor,}
	return actual_pos
end
function advtrains.pos_median(pos1, pos2)
	return {x=pos1.x-(pos1.x-pos2.x)*0.5, y=pos1.y-(pos1.y-pos2.y)*0.5, z=pos1.z-(pos1.z-pos2.z)*0.5}
end
function advtrains.abs_ceil(i)
	return math.ceil(math.abs(i))*math.sign(i)
end

function advtrains.serialize_inventory(inv)
	local ser={}
	local liszts=inv:get_lists()
	for lisztname, liszt in pairs(liszts) do
		ser[lisztname]={}
		for idx, item in ipairs(liszt) do
			local istring=item:to_string()
			if istring~="" then
				ser[lisztname][idx]=istring
			end
		end
	end
	return minetest.serialize(ser)
end
function advtrains.deserialize_inventory(sers, inv)
	local ser=minetest.deserialize(sers)
	if ser then
		inv:set_lists(ser)
		return true
	end
	return false
end

--is_protected wrapper that checks for protection_bypass privilege
function advtrains.is_protected(pos, name)
	if not name then
		error("advtrains.is_protected() called without name parameter!")
	end
	if minetest.check_player_privs(name, {protection_bypass=true}) then
		--player can bypass protection
		return false
	end
	return minetest.is_protected(pos, name)
end

function advtrains.is_creative(name)
	if not name then
		error("advtrains.is_creative() called without name parameter!")
	end
	if minetest.check_player_privs(name, {creative=true}) then
		return true
	end
	return minetest.settings:get_bool("creative_mode")
end

function advtrains.is_damage_enabled(name)
	if not name then
		error("advtrains.is_damage_enabled() called without name parameter!")
	end
	if minetest.check_player_privs(name, "train_admin") then
		return false
	end
	return minetest.settings:get_bool("enable_damage")
end

function advtrains.ms_to_kmh(speed)
	return speed * 3.6
end

-- 4 possible inputs:
-- integer: just do that modulo calculation
-- table with c set: rotate c
-- table with tables: rotate each
-- table with integers: rotate each (probably no use case)
function advtrains.rotate_conn_by(conn, rotate)
	if tonumber(conn) then
		return (conn+rotate)%AT_CMAX
	elseif conn.c then
		return { c = (conn.c+rotate)%AT_CMAX, y = conn.y}
	end
	local tmp={}
	for connid, data in ipairs(conn) do
		tmp[connid]=advtrains.rotate_conn_by(data, rotate)
	end
	return tmp
end


function advtrains.oppd(dir)
	return advtrains.rotate_conn_by(dir, AT_CMAX/2)
end
--conn_to_match like rotate_conn_by
--other_conns have to be a table of conn tables!
function advtrains.conn_matches_to(conn, other_conns)
	if tonumber(conn) then
		for connid, data in ipairs(other_conns) do
			if advtrains.oppd(conn) == data.c then return connid end
		end
		return false
	elseif conn.c then
		for connid, data in ipairs(other_conns) do
			local cmp = advtrains.oppd(conn)
			if cmp.c == data.c and (cmp.y or 0) == (data.y or 0) then return connid end
		end
		return false
	end
	local tmp={}
	for connid, data in ipairs(conn) do
		local backmatch = advtrains.conn_matches_to(data, other_conns)
		if backmatch then return backmatch, connid end --returns <connid of other rail> <connid of this rail>
	end
	return false
end

-- Going from the rail at pos (does not need to be rounded) along connection with id conn_idx, if there is a matching rail, return it and the matching connid
-- returns: <adjacent pos>, <conn index of adjacent>, <my conn index>, <railheight of adjacent>
-- parameter this_conns_p is connection table of this rail and is optional, is determined by get_rail_info_at if not provided.
function advtrains.get_adjacent_rail(this_posnr, this_conns_p, conn_idx, drives_on)
	local this_pos = advtrains.round_vector_floor_y(this_posnr)
	local this_conns = this_conns_p
	if not this_conns then
		_, this_conns = advtrains.get_rail_info_at(this_pos)
	end
	if not conn_idx then
		for coni, _ in ipairs(this_conns) do
			local adj_pos, adj_conn_idx, _, nry, nco = advtrains.get_adjacent_rail(this_pos, this_conns, coni)
			if adj_pos then return adj_pos,adj_conn_idx,coni,nry, nco end
		end
		return nil
	end
	
	local conn = this_conns[conn_idx]
	local conn_y = conn.y or 0
	local adj_pos = advtrains.dirCoordSet(this_pos, conn.c);
	
	while conn_y>=1 do
		conn_y = conn_y - 1
		adj_pos.y = adj_pos.y + 1
	end
	
	local nextnode_ok, nextconns, nextrail_y=advtrains.get_rail_info_at(adj_pos, drives_on)
	if not nextnode_ok then
		adj_pos.y = adj_pos.y - 1
		conn_y = conn_y + 1
		nextnode_ok, nextconns, nextrail_y=advtrains.get_rail_info_at(adj_pos, drives_on)
		if not nextnode_ok then
			return nil
		end
	end
	local adj_connid = advtrains.conn_matches_to({c=conn.c, y=conn_y}, nextconns)
	if adj_connid then
		return adj_pos, adj_connid, conn_idx, nextrail_y, nextconns
	end
	return nil
end

-- when a train enters a rail on connid 'conn', which connid will it go out?
-- nconns: number of connections in connection table:
-- 2 = straight rail; 3 = turnout, 4 = crossing, 5 = three-way turnout (5th entry is a stub)
-- returns: connid_out
local connlku={[2]={2,1}, [3]={2,1,1}, [4]={2,1,4,3}, [5]={2,1,1,1}}
function advtrains.get_matching_conn(conn, nconns)
	return connlku[nconns][conn]
end

function advtrains.random_id()
	local idst=""
	for i=0,5 do
		idst=idst..(math.random(0,9))
	end
	return idst
end
-- Shorthand for pos_to_string and round_vector_floor_y
function advtrains.roundfloorpts(pos)
	return minetest.pos_to_string(advtrains.round_vector_floor_y(pos))
end

-- insert an element into a table if it does not yet exist there
-- equalfunc is a function to compare equality, defaults to ==
-- returns true if the element was inserted
function advtrains.insert_once(tab, elem, equalfunc)
	for _,e in pairs(tab) do
		if equalfunc and equalfunc(elem, e) or e==elem then return false end
	end
	tab[#tab+1] = elem
	return true
end

local hext = { [0]="0",[1]="1",[2]="2",[3]="3",[4]="4",[5]="5",[6]="6",[7]="7",[8]="8",[9]="9",[10]="A",[11]="B",[12]="C",[13]="D",[14]="E",[15]="F"}
local dect = { ["0"]=0,["1"]=1,["2"]=2,["3"]=3,["4"]=4,["5"]=5,["6"]=6,["7"]=7,["8"]=8,["9"]=9,["A"]=10,["B"]=11,["C"]=12,["D"]=13,["E"]=14,["F"]=15}

local f = atfloor

local function hex(i)
	local x=i+32768
	local c4 = x % 16
	x = f(x / 16)
	local c3 = x % 16
	x = f(x / 16)
	local c2 = x % 16
	x = f(x / 16)
	local c1 = x % 16
	return (hext[c1]) .. (hext[c2]) .. (hext[c3]) .. (hext[c4])
end

local function c(s,i) return dect[string.sub(s,i,i)] end

local function dec(s)
	return (c(s,1)*4096 + c(s,2)*256 + c(s,3)*16 + c(s,4))-32768
end
-- Takes a position vector and outputs a encoded value suitable as table index
-- This is essentially a hexadecimal representation of the position (+32768)
-- Order (YYY)YXXXXZZZZ
function advtrains.encode_pos(pos)
	return hex(pos.y) .. hex(pos.x) .. hex(pos.z)
end

-- decodes a position encoded with encode_pos
function advtrains.decode_pos(pts)
	if not pts or not #pts==6 then return nil end
	local stry = string.sub(pts, 1,4)
	local strx = string.sub(pts, 5,8)
	local strz = string.sub(pts, 9,12)
	return vector.new(dec(strx), dec(stry), dec(strz))
end

--[[ Benchmarking code
local tdt = {}
local tlt = {}
local tet = {}

for i=1,1000000 do
	tdt[i] = vector.new(math.random(-65536, 65535), math.random(-65536, 65535), math.random(-65536, 65535))
	if i%1000 == 0 then
		tlt[#tlt+1] = tdt[i]
	end
end

local t1=os.clock()
for i=1,1000000 do
	local pe = advtrains.encode_pos(tdt[i])
	local pb = advtrains.decode_pos(pe)
	tet[pe] = i
end
for i,v in ipairs(tlt) do
	local lk = tet[advtrains.encode_pos(v)]
end
atdebug("endec",os.clock()-t1,"s")

tet = {}

t1=os.clock()
for i=1,1000000 do
	local pe = minetest.pos_to_string(tdt[i])
	local pb = minetest.string_to_pos(pe)
	tet[pe] = i
end
for i,v in ipairs(tlt) do
	local lk = tet[minetest.pos_to_string(v)]
end
atdebug("pts",os.clock()-t1,"s")

--Results:
--2018-11-29 16:57:08: ACTION[Main]: [advtrains]endec 1.786451 s 
--2018-11-29 16:57:10: ACTION[Main]: [advtrains]pts 2.566377 s 
]]


-- Function to check whether a position is near (within range of) any player
function advtrains.position_in_range(pos, range)
	if not pos then
		return true
	end
	for _,p in pairs(minetest.get_connected_players()) do
		if vector.distance(p:get_pos(),pos)<=range then
			return true
		end
	end
	return false
end

local active_node_range = tonumber(minetest.settings:get("active_block_range"))*16 + 16
-- Function to check whether node at position(pos) is "loaded"/"active"
-- That is, whether it is within the active_block_range to a player
if minetest.is_block_active then -- define function differently whether minetest.is_block_active is available or not
	advtrains.is_node_loaded = minetest.is_block_active
else
	function advtrains.is_node_loaded(pos)
		if advtrains.position_in_range(pos, active_node_range) then
			return true
		end
	end
end

local variants = {
	{"0", 0},
	{"30", 0},
	{"45", 0},
	{"60", 0},
	{"0", 1},
	{"30", 1},
	{"45", 1},
	{"60", 1},
	{"0", 2},
	{"30", 2},
	{"45", 2},
	{"60", 2},
	{"0", 3},
	{"30", 3},
	{"45", 3},
	{"60", 3},
	{"0", 0},
	{"30", 0},
	{"45", 0},
	{"60", 0},
}

function advtrains.after_place_signal(pos, placer, itemstack, pointed_thing)
	if not minetest.is_player(placer) then return end
	local name = itemstack:get_name()
	if not name:match("_0$") then return end
	local rn = minetest.registered_nodes
	local prefix = name:sub(1, -2)
	if not (rn[prefix.."30"] and rn[prefix.."45"] and rn[prefix.."60"]) then return end
	local variant = math.floor(placer:get_look_horizontal() * -8 / math.pi + 16.5)
	local n = variants[variant + 1]
	if n == nil then return end
	local node = minetest.get_node(pos)
	if node.name ~= name then return end
	node.name = prefix..n[1]
	node.param2 = n[2]
	minetest.swap_node(pos, node)
end
