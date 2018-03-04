local m = {}
m.interval = 5
m.name = "mem"

local function percent(num, denum)
	if denum == 0 then
		return "NaN."
	else
		local per = tostring(math.ceil(100- num / denum * 100)) .. "%"
		return string.rep(" ", 4-#per) .. per
	end
end

function m.update()
	local file = io.open("/proc/meminfo")
	local data = file:read("*a")
	file:close()
	local table = {}
	for line in data:gmatch("[^\n]+") do
		local k,v = line:match("([%w%(%)]+):%s*(%d+)")
		table[k] = tonumber(v)
	end
	m.status = "RAM:"..percent(table.MemAvailable,table.MemTotal)..
		" SWAP:"..percent(table.SwapFree,table.SwapTotal)
end

function m.click() end

return m

