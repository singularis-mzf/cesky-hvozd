
visionLib.CTM={}
visionLib.RegisteredCtmHandlers={}

function visionLib.CTM.NewCtmHandler(node, nodes, rules)
	visionLib.RegisteredCtmHandlers[node]={nodes=nodes,rules=rules}
end

function visionLib.CTM.HandleNode(p)
	local n=minetest.get_node(p).name
	
	if visionLib.RegisteredCtmHandlers[n] then
		local handler=visionLib.RegisteredCtmHandlers[n]
		
		local places={}
		
		local fposes=visionLib.Common.GetAdjacents(p)
		for _,v in pairs(fposes) do
			local t=minetest.get_node(v).name
			
			if handler.nodes[t] then
				places[_]=1
			end
		end
		
		if visionLib.Table.Len(places) and visionLib.Table.Len(places)~=0 then
			for _,v in pairs(handler.rules) do
				local tt=0
				for x,n in pairs(v.keys) do
					if places[n] then
						tt=tt+1
					end
				end
				
				if tt==visionLib.Table.Len(v.keys) then
					minetest.set_node(p, {name=v.result})
					for k,l in pairs(fposes) do
						visionLib.CTM.HandleNode(l)
					end
				end
			end
		end
	end
	
	return n
end

--[[
visionLib.CTM.NewCtmHandler("default:glass",
{
	["default:tree"]=1,
},
{
	{result="default:tree", keys={"x", "X", "z", "Z"}}
})
]]


