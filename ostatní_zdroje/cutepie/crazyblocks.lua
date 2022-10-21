local crazy_blocks = {
	{"cute_pinknblue","Cutepie Pink n Blue"},
	{"cute_greenx","Cutepie Green X"},
	{"cute_greennorange","Cutepie Green n Orange"},
	{"cute_bluex","Cutepie Blue X"},
	{"cute_pink","Cutepie Pink"},
	{"cute_blue","Cutepie Blue"},
	{"cute_orange","Cutepie Orange"},
	{"cute_green","Cutepie Green"}
	}

for i in ipairs(crazy_blocks) do
	local itm = crazy_blocks[i][1]
	local des = crazy_blocks[i][2]

minetest.register_node("cutepie:"..itm, {
	description = des,
	drawtype = "normal",
	paramtype = "light",
	tiles = {itm..".png"},
	paramtype = "light",
	groups = {cracky = 2},

})
end
