local ifthenelse = ch_core.ifthenelse

local function ipairs_reverse_in(t, i)
	if i > 1 then
		return i - 1, t[i - 1]
	end
end

local function ipairs_reverse(t)
	return ipairs_reverse_in, t, #t + 1
end

local function keys(t)
	return next, t, next(t)
end

local function ivalues(t)
	local i, n = 0, #t
	return function(tab)
		if i < n then
			i = i + 1
			return tab[i]
		end
	end, t, t
end

local function values(t)
	local k
	return function(tab)
		k = next(tab, k)
		if k ~= nil then
			return tab[k]
		end
	end, t, t
end

local function count(t)
	local i, k = 0, next(t)
	while k ~= nil do
		i = i + 1
		k = next(t, k)
	end
	return i
end

-- [ ] TODO: pairs_order_by_key(t, lt), ipairs_order_by_value(t, lt)
