
visionLib.Schem={}

function visionLib.Schem.GetConnected(pos, acceptable)
	local iPos=visionLib.Table.Clone(pos)
	local stc = {[pos.x.." "..pos.y.." "..pos.z]=visionLib.Table.Clone(pos)}
	local l2={iPos}
	local con=1
	while con > 0 do
		con=0
		for _,v in pairs(l2) do
			local npos = visionLib.Table.Clone(v)
			npos.x=npos.x+1
			if acceptable[minetest.get_node(npos).name] and not stc[npos.x.." "..npos.y.." "..npos.z] then
				stc[npos.x.." "..npos.y.." "..npos.z]=visionLib.Table.Clone(npos)
				table.insert(l2, visionLib.Table.Clone(npos))
				con=con+1
			end
			local npos = visionLib.Table.Clone(v)
			npos.x=npos.x-1
			if acceptable[minetest.get_node(npos).name] and not stc[npos.x.." "..npos.y.." "..npos.z] then
				stc[npos.x.." "..npos.y.." "..npos.z]=visionLib.Table.Clone(npos)
				table.insert(l2, visionLib.Table.Clone(npos))
				con=con+1
			end
			local npos = visionLib.Table.Clone(v)
			npos.z=npos.z+1
			if acceptable[minetest.get_node(npos).name] and not stc[npos.x.." "..npos.y.." "..npos.z] then
				stc[npos.x.." "..npos.y.." "..npos.z]=visionLib.Table.Clone(npos)
				table.insert(l2, visionLib.Table.Clone(npos))
				con=con+1
			end
			local npos = visionLib.Table.Clone(v)
			npos.z=npos.z-1
			if acceptable[minetest.get_node(npos).name] and not stc[npos.x.." "..npos.y.." "..npos.z] then
				stc[npos.x.." "..npos.y.." "..npos.z]=visionLib.Table.Clone(npos)
				table.insert(l2, visionLib.Table.Clone(npos))
				con=con+1
			end
			local npos = visionLib.Table.Clone(v)
			npos.y=npos.y+1
			if acceptable[minetest.get_node(npos).name] and not stc[npos.x.." "..npos.y.." "..npos.z] then
				stc[npos.x.." "..npos.y.." "..npos.z]=visionLib.Table.Clone(npos)
				table.insert(l2, visionLib.Table.Clone(npos))
				con=con+1
			end
			local npos = visionLib.Table.Clone(v)
			npos.y=npos.y-1
			if acceptable[minetest.get_node(npos).name] and not stc[npos.x.." "..npos.y.." "..npos.z] then
				stc[npos.x.." "..npos.y.." "..npos.z]=visionLib.Table.Clone(npos)
				table.insert(l2, visionLib.Table.Clone(npos))
				con=con+1
			end
		end
	end
	
	for k,v in pairs(stc) do
		stc[k].name=minetest.get_node(v).name
	end
	
	return stc
end
