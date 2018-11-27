local d = {}

local statvfs = require("posix.sys.statvfs").statvfs

local blacklist = ARGS.blacklist or {}

-- Transform the blacklist into a set
local tmp = {}
for k,v in pairs(blacklist) do
	tmp[v] = true
end
blacklist = tmp

d.name = "df"
d.interval = 10

local function getMountPoints()
	local output = {}
	for line in io.lines("/proc/mounts") do
		if line:match("^/") then
			local mountpoint = line:match("^%S* (%S*)")
			--TODO handle escaped characters
			local name = mountpoint:match("/(.-)$")
			if (name == "") then
				name = "root"
			end
			if not blacklist[name] then
				output[#output+1] = {fs=mountpoint, name=name}
			end
		end
	end
	return output
end

local function formatPercent(percent)
	return string.rep(" ",4-#percent)..percent
end

function d.update()
	local mountpoints = getMountPoints()
	local concat = {}
	for k,tab in ipairs(mountpoints) do
		local stats = statvfs(tab.fs)
		local per = math.floor((1 - stats.f_bavail / stats.f_blocks) *100).."%"
		concat[#concat+1] = tab.name..":"..formatPercent(per)
	end
	d.status = table.concat(concat," ")
end

function d.click() end

return d

