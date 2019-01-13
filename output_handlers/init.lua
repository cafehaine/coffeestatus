-- Get the parent process id from /proc/self/stat (see man proc)
local proc_stat = io.open("/proc/self/stat")
local ppid = tonumber(proc_stat:read("*a"):match("%d* %(.*%) %w (%d*)"))
proc_stat:close()

local binary = nil
repeat
-- Get the parent process binary name
	local parent_stat = io.open("/proc/"..ppid.."/stat")
	binary, ppid = parent_stat:read("*a"):match("%d* %((.*)%) %w (%d*)")
	parent_stat:close()
until (binary ~= "bash" and binary ~= "sh")

print("Calling process: "..binary)

if binary == "i3bar" or binary == "swaybar" then
	print("Assuming i3 format.")
	return require("output_handlers.i3")
else
	print("Assuming term format.")
	return require("output_handlers.term")
end
