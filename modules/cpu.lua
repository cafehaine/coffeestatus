local c = {}

c.name = "cpu"
c.interval = 10

local levels = {" ","▁","▂","▃","▄","▅","▆","▇","█"}
local temp = io.popen("nproc --all")
local cores = tonumber(temp:read("*a"))
temp:close()

function c.update()
	local file = io.popen("ps -A -o psr,pcpu --no-headers")
	local data = file:read("*a")
	local loads = {}
	for i = 1, cores do
		loads[i] = 0
	end
	
	for line in data:gmatch("[^\n]+") do
		local index, load = line:match("%s*(%d+)%s*([%d%.]+)")
		loads[index] = loads[tonumber(index)+1] + tonumber(load)
	end
	
	local mean = 0
	for i = 1, cores do
		mean = mean + loads[i]
		loads[i] = levels[math.ceil(loads[i] / 100 * (#levels - 1)) + 1]
	end
	mean = math.ceil(mean / cores)
	c.status = "CPU: "..table.concat(loads).." 90%"
end

function c.click() end

return c
