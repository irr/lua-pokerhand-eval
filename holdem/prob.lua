local ipairs = ipairs
local pairs = pairs
local print = print
local table = table
local unpack = unpack

module('holdem.prob')

function comb(a, r)
    if r > #a then
        return {}
    end
    if r == 0 then
        return {}
    end
    if r == 1 then
        local return_table = {}
        for i = 1, #a do
            table.insert(return_table, {a[i]})
        end
        return return_table
    else
        local return_table = {}
        local t = {}
        for i = 2, #a do
            table.insert(t, a[i])
        end
        for i, val in pairs(comb(t, r - 1)) do
            local curr_result = {}
            table.insert(curr_result, a[1]);
            for j, curr_val in pairs(val) do
                table.insert(curr_result, curr_val)
            end
            table.insert(return_table, curr_result)
        end
        for i, val in pairs(comb(t, r)) do
            table.insert(return_table, val)
        end
        return return_table
    end
end

function dump(c)
    for k, v in ipairs(c) do 
        print(unpack(v)) 
    end
end
 
local function find(a, tbl)
	for _, a_ in ipairs(tbl) do 
        if a_ == a then 
            return true 
        end
    end
end

function union(a, b)
	a = {unpack(a)}
	for _, b_ in ipairs(b) do
		if not find(b_, a) then 
            table.insert(a, b_) 
        end
	end
	return a
end

function intersection(a, b)
	local ret = {}
	for _, b_ in ipairs(b) do
		if find(b_, a) then 
            table.insert(ret, b_) 
        end
	end
	return ret
end

function difference(a, b)
	local ret = {}
	for _,a_ in ipairs(a) do
		if not find(a_, b) then 
            table.insert(ret, a_) 
        end
	end
	return ret
end

function symmetric(a, b)
	return difference(union(a, b), intersection(a, b))
end

