--[[
The MIT License (MIT)

Copyright (c) 2016 TenPlus1
Copyright (c) 2024 Singularis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]
local T = {name = "moretrees:cherrytree_trunk", param1 = 255}
local P = {name = "moretrees:cherrytree_leaves", param1 = 255}
local C = {name = "moretrees:cherry", param1 = 255}
-- local W = {name = "ethereal:sakura_leaves2", param1 = 255}
local _ = {name = "air", param1 = 255}

moretrees.sakura_tree = {

	size = {x=10, y=10, z=7},

	yslice_prob = {
		{ypos = 0, prob = 127},
		{ypos = 3, prob = 127},
		{ypos = 8, prob = 127},
	},

	data = {

_,_,_,_,_,_,_,_,_,_,
_,_,_,_,_,_,_,_,_,_,
_,_,_,_,_,_,_,_,_,_,
_,_,_,_,_,_,_,_,_,_,
_,_,_,_,_,_,_,_,_,_,
_,_,_,_,P,P,_,_,_,_,
_,_,_,P,P,P,P,_,_,_,
_,_,_,P,P,P,_,_,_,_,
_,_,_,_,_,_,_,_,_,_,
_,_,_,_,_,_,_,_,_,_,

_,_,_,_,_,_,_,_,_,_,
_,_,_,_,_,_,_,_,_,_,
_,_,_,_,_,_,_,_,_,_,
_,_,_,_,_,_,_,_,_,_,
_,_,_,P,P,P,P,_,_,_,
_,_,C,P,P,P,P,_,_,_,
_,_,P,P,T,P,P,P,_,_,
_,_,P,P,P,P,P,P,_,_,
_,_,P,_,P,P,P,P,_,_,
_,_,_,_,_,_,_,_,_,_,

_,_,_,_,_,_,_,_,_,_,
_,_,_,_,_,_,_,_,_,_,
_,_,_,_,_,_,_,_,_,_,
_,_,_,P,P,P,_,_,_,_,
_,_,P,P,P,P,P,P,_,_,
_,_,P,P,T,P,P,P,P,_,
_,P,P,P,P,P,P,P,P,P,
_,P,P,P,C,P,P,P,P,P,
_,P,P,P,P,P,P,P,P,_,
_,_,P,P,P,P,P,P,_,_,

_,_,_,_,T,_,_,_,_,_,
_,_,_,_,T,_,_,_,_,_,
_,_,_,_,T,_,_,_,_,_,
_,_,P,P,T,T,P,C,_,_,
_,P,P,T,T,T,T,P,P,_,
_,P,P,T,_,T,P,T,P,_,
P,P,P,T,P,T,P,P,T,P,
P,P,T,P,P,P,P,P,T,P,
P,P,T,P,P,P,P,T,P,P,
_,P,P,P,P,P,P,P,P,_,

_,_,_,_,_,_,_,_,_,_,
_,_,_,_,_,_,_,_,_,_,
_,_,_,_,_,_,_,_,_,_,
_,_,_,P,_,P,_,_,_,_,
_,_,P,P,T,P,P,P,_,_,
_,_,P,P,_,P,P,P,P,_,
_,P,P,P,P,P,P,P,P,P,
_,P,P,P,P,P,P,C,P,P,
_,P,P,P,P,P,P,P,P,_,
_,_,P,P,P,P,P,P,_,_,

_,_,_,_,_,_,_,_,_,_,
_,_,_,_,_,_,_,_,_,_,
_,_,_,_,_,_,_,_,_,_,
_,_,_,_,P,_,_,_,_,_,
_,_,_,C,P,P,_,_,_,_,
_,_,_,P,T,P,_,_,_,_,
_,_,P,P,T,P,P,C,P,_,
_,_,P,P,P,P,P,P,P,_,
_,_,P,P,P,P,_,P,P,_,
_,_,_,_,P,_,_,_,_,_,

_,_,_,_,_,_,_,_,_,_,
_,_,_,_,_,_,_,_,_,_,
_,_,_,_,_,_,_,_,_,_,
_,_,_,_,_,_,_,_,_,_,
_,_,_,_,P,_,_,_,_,_,
_,_,_,P,P,P,_,_,_,_,
_,_,_,P,P,P,_,_,_,_,
_,_,_,P,P,P,_,_,_,_,
_,_,_,_,P,_,_,_,_,_,
_,_,_,_,_,_,_,_,_,_,

	},
}
