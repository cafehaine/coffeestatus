local d = {}

local blacklist = ARGS.blacklist or {}
d.name = "df"
d.interval = 60

-- input: output of df command
-- output: table with the following structure:
-- {
-- 	{
-- 		mount = "path_of_mount",
-- 		usage = "percent%"
-- 	},
-- 	…
-- }

local function treatOutput(data)
	local output = {}
	local firstline = true
	for line in data:gmatch("[^\n]+") do
		if firstline then
			firstline = false
		else
			local mount, usage = line:match("(.+)%s(.+%%)")
			mount = mount:match(".*/(.-)%s*$")
			if mount == "" then
				mount = "root"
			end
			local skip = false
			for k,v in ipairs(blacklist) do
				if v == mount then
					skip = true
				end
			end
			if not skip then
				output[#output + 1] = {mount = mount, usage = usage}
			end
		end
	end
	return output
end

local function formatPercent(percent)
	return string.rep(" ",4-#percent)..percent
end

function d.update()
	local file = io.popen("df -xdevtmpfs -xtmpfs --output=target,pcent")
	local drives = treatOutput(file:read("*a"))
	file:close()

	local concat = {}
	for k,v in ipairs(drives) do
		concat[#concat + 1] = v.mount..":"..formatPercent(v.usage)
	end
	d.status = table.concat(concat," ")
end

function d.click() end

return d

