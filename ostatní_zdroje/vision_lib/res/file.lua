

function visionLib.File.Exists(f)
	local F=io.open(f)
	local n= F~=nil
	if n then F:close() end
	return n
end

function visionLib.File.Create(f)
	local F=io.open(f, "w")
	F:write("\n")
	F:close()
end

function visionLib.File.Write(f, t)
	local F=io.open(f, "w")
	F:write(t)
	F:close()
end

function visionLib.File.Add(f, t)
	local F=io.open(f, "a")
	F:write(t)
	F:close()
end

function visionLib.File.Read(f)
	local F=io.open(f, "r")
	local n=F:read("*a")
	F:close()
	return n
end

function visionLib.File.mkDir(path)
  if not io.open(path) then
    if minetest.mkdir then
      minetest.mkdir(path)
    else
      os.execute('mkdir "'..path..'"')
    end
    return true
  end
end