local p = {}

p.name = "pulse"
p.interval = 0.5

-- requires luarocks rock "pulseaudio_dbus"
local stateTags = {muted="<X",normal="<)",unknown="??"}
local pulse = nil
local connection = nil
local state = "unknown"
local volume = nil

local function init_pulseaudio()
	if pulse == nil then
		status, pulse = pcall(require,"pulseaudio_dbus")
		if not status then
			return
		end
	end

	status, connection = pcall(pulse.get_connection, pulse.get_address())
	if not status then
		return
	end
end

local function update_pulseaudio()
	if pulse == nil or connection == nil then
		init_pulseaudio()
		if pulse == nil or connection == nil then
			state = "unknown"
			volume = "nil"
			return
		end
	end
	core = pulse.get_core(connection)
	sink = pulse.get_device(connection, core:get_sinks()[1])
	state = sink:is_muted() and "muted" or "normal"
	volume = sink:get_volume_percent()[1]
end

local function toPercent(val)
	return string.rep(" ",3-#tostring(val)) .. tostring(val).."%"
end

local function generateStatus()
	local output = {}
	if state == "muted" or state == "unknown" then
		output[1] = {foreground="#B00",text=stateTags[state]}
	else
		output[1] = stateTags[state]
	end
	if not volume then
		output[2] = " --%"
	elseif volume >= 90 and volume <= 100 then
		output[2] = {foreground="#FA0",text=toPercent(volume)}
	elseif volume > 100 then
		output[2] = {foreground="#F00",text=toPercent(volume)}
	else
		output[2] = toPercent(volume)
	end
	return output
end

function p.update()
	local oldstate = state
	local oldvolume = volume
	update_pulseaudio()
	if oldstate ~= state or oldvolume ~= volume then
		p.status = generateStatus()
	end
end

function p.click(arg)
	-- left click = start pavucontrol
	if arg.button == 1 then
		os.execute("pavucontrol&")
		return -- return now, we don't need to update anything
	elseif pulse and connection then
		-- right click = toggle mute
		if arg.button == 3 then
			sink:toggle_muted()
		-- scroll up = vol up
		elseif arg.button == 4 then
			sink:set_volume_percent({math.min(volume + 2,150)})
		-- scroll down = vol down
		elseif arg.button == 5 then
			sink:set_volume_percent({math.max(volume - 2, 0)})
		end
	end
	p.update()
end

p.status = generateStatus()

return p
