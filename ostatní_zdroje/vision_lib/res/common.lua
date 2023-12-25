
visionLib.Common={}

local function merge(t1, t2)
    for k, v in pairs(t2) do
        if (type(v) == "table") and (type(t1[k] or false) == "table") then
            merge(t1[k], t2[k])
        else
            t1[k] = v
        end
    end
    return t1
end

function visionLib.Common.SmartOverrideItem(name,redef)
	if minetest.registered_items[name] then
		minetest.register_item(":"..name, merge(visionLib.Table.Clone(minetest.registered_items[name]), redef))
	else
		minetest.register_craftitem(":"..name, redef)
	end
end

function visionLib.Common.GetAdjacents(p)
	return {
		["y"]={x=p.x,y=p.y+1,z=p.z},
		["Y"]={x=p.x,y=p.y-1,z=p.z},
		["x"]={x=p.x+1,y=p.y,z=p.z},
		["X"]={x=p.x-1,y=p.y,z=p.z},
		["z"]={x=p.x,y=p.y,z=p.z+1},
		["Z"]={x=p.x,y=p.y,z=p.z-1}
	}
end

function visionLib.Common.IncreasingRarity(m)
	local t={}
	for i=1,m do
		for ii=1,m-(i-1) do
			table.insert(t, i)
		end
	end
	return t
end

function visionLib.Common.DecreasingRarity(m)
	local t={}
	for i=1,m do
		for ii=1,i do
			table.insert(t, i)
		end
	end
	return t
end

visionLib.Common.HexDigits={
	"0", "1", "2", "3", 
	"4", "5", "6", "7", 
	"8", "9", "A", "B",
	"C", "D", "E", "F"
}

function visionLib.Common.RandomHex(l, d)
	local t=""
	for i=1,l do
		t=t..visionLib.Common.HexDigits[math.random(1,d or 16)]
	end
	return t
end

visionLib.Common.vowels={
	"a",  "e",  "i",  "o",  "u",
}

visionLib.Common.consonants = {
	"b",  "c",  "d",  "f",  "g",  "h",  "j",  "k",  "l",  "m",  "n",  "p",  "qu",  "r",  "s",  "t",  "v",  "w",  "x",  "y",  "z",
	"ch", "th", "ph", "sh", "vh", "zh", "gh"
}

visionLib.Common.syllableStructs={
	"V", "VC", "CVC", "CV", 
}

function visionLib.Common.RandomSyllable(l)
	local s=visionLib.Common.syllableStructs[l or math.random(1,#visionLib.Common.syllableStructs)]
	local t=""
	
	for i=1,#s do
		local l=s:sub(i,i)
		if l=="V" then
			t=t..visionLib.Common.vowels[math.random(1,#visionLib.Common.vowels)]
		elseif l=="C" then
			t=t..visionLib.Common.consonants[math.random(1,#visionLib.Common.consonants)]
		end
	end
	
	return t
end

visionLib.Common.usedWords={}

function visionLib.Common.RandomWord(l, m)
	local t=""
	while t=="" or visionLib.Common.usedWords[t] do
		local r=visionLib.Common.IncreasingRarity(9)[math.random(1,#visionLib.Common.IncreasingRarity(9))]
		
		if m and r > m then
			r=m
		end

		for i = 1, l or r do
			t=t..visionLib.Common.RandomSyllable()
		end
		
		if #t==1 then
			t=t..visionLib.Common.RandomSyllable()
		end
	end
	return t
end

function visionLib.Common.TitleFormat(t)
	local k=string.split(t, " ")
	local T=""
	for _,v in ipairs(k) do
		if _==#k then
			T=T..visionLib.Common.ParagraphFormat(v)
		else
			T=T..visionLib.Common.ParagraphFormat(v).." "
		end
	end
	return T
end

visionLib.Common.Capitals={
	a="A",
	b="B",
	c="C",
	d="D",
	e="E",
	f="F",
	g="G",
	h="H",
	i="I",
	j="J",
	k="K",
	l="L",
	m="M",
	n="N",
	o="O",
	p="P",
	q="Q",
	r="R",
	s="S",
	t="T",
	u="U",
	v="V",
	w="W",
	x="X",
	y="Y",
	z="Z",
}

function visionLib.Common.ParagraphFormat(t)
	local k=""
	if visionLib.Common.Capitals[t:sub(1,1)] then
		k=t:sub(2,#t)
		k=visionLib.Common.Capitals[t:sub(1,1)]..k
	else
		k=t
	end
	return k
end

