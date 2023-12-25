visionLib={modPath=minetest.get_modpath("vision_lib"), worldpath=minetest.get_worldpath(),
	Table={
		Clone=function(T, N)
			local t={}
			if N then
				for k,v in pairs(T) do
					if not N[k] then
						t[k]=v
					end
				end
			else
				for k,v in pairs(T) do
					t[k]=v
				end
			end
			return t
		end,
		
		HasKey=function(T,K)
			for k,v in pairs(T) do
				if k==K then return true end
			end
			return false
		end,
		
		HasValue=function(T,V)
			for k,v in pairs(T) do
				if v==V then return true end
			end
			return false
		end,
		
		Len=function(T)
			local n=0
			for k,v in pairs(T) do
			n=n+1
			end
			return n
		end,
	},
	File={},
}

function visionLib.File.LoadModule(filename, fp)
	local filepath=fp or visionLib.modPath
	filename=filename..".lua"
	dofile(filepath.."/res/"..filename)
end

visionLib.File.LoadModule("file")
visionLib.File.LoadModule("common")
visionLib.File.LoadModule("sound")
visionLib.File.LoadModule("material")
visionLib.File.LoadModule("schem")
visionLib.File.LoadModule("ctm")
