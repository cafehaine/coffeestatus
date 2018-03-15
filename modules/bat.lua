local b = {}

b.name = "bat"
b.interval = 10
local path = "/sys/class/power_supply/" .. (ARGS.path or "BAT1") .. "/"

function b.update()
	local file = io.open(path.."capacity")
	local val = tonumber(file:read("*a")).."%"
	file:close()
	local file2 = io.open(path .. "status")
	local val2 = file2:read("*a")
	file2:close()
	local status = " ! "
	if val2  == "Charging\n" then
		status = "-(="
	elseif val2 == "Discharging\n" then
		status = "[_}"
	elseif val2 == "Unknown\n" then
		status = "[?}"
	end
	b.status = status .. string.rep(" ",4-#val)..val
end

function b.click() end

return b

