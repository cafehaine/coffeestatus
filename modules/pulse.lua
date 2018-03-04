local p = {}

p.name = "pulse"
p.interval = 0.5

-- requires luarocks rock "pulseaudio_dbus"
local pulse = require("pulseaudio_dbus")
local status, connection = pcall(pulse.get_connection, pulse.get_address())
if not status then
	error("Failed to connect to pulseaudio. Please check that pulseaudio is running and 'module-dbus-protocol' is loaded.")
end

local core = pulse.get_core(connection)
local sink = pulse.get_device(connection, core:get_sinks()[1])
local state = sink:is_muted() and "muted" or "normal"
local stateTags = {muted="<X",normal="<)"}
local volume = sink:get_volume_percent()[1]

local function toPercent(val)
	return string.rep(" ",3-#tostring(val)) .. tostring(val).."%"
end

local function generateStatus()
	local output = {}
	if state == "muted" then
		output[1] = {foreground="#B00",text=stateTags[state]}
	else
		output[1] = stateTags[state]
	end
	if volume >= 90 and volume <= 100 then
		output[2] = {foreground="#FA0",text=toPercent(volume)}
	elseif volume > 100 then
		output[2] = {foreground="#F00",text=toPercent(volume)}
	else
		output[2] = toPercent(volume)
	end
	return output
end

function p.update()
	state = sink:is_muted() and "muted" or "normal"
	-- Soundcard failed to read volume, reset sink before we fail
	if sink:get_volume() == nil then
		sink = pulse.get_device(connection, core:get_sinks()[1])
	end
	volume = sink:get_volume_percent()[1]
	p.status = generateStatus()
end

function p.click(arg)
	-- left click = start pavucontrol
	if arg.button == 1 then
		os.execute("pavucontrol&")
		return -- return now, we don't need to update anything
	-- right click = toggle mute
	elseif arg.button == 3 then
		sink:toggle_muted()
	-- scroll up = vol up
	elseif arg.button == 4 then
		sink:set_volume_percent({math.min(volume + 2,150)})
	-- scroll down = vol down
	elseif arg.button == 5 then
		sink:set_volume_percent({math.max(volume - 2, 0)})
	end
	p.update()
end

return p
