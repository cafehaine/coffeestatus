local socket = require("socket")
local sock = nil

-- Warning: this skips most verifications that string.sub does and does not
-- handle negative indices, be careful when using this. (Also it is not really
-- efficient.)
function utf8.sub(str,start,finish)
	output = {}
	if finish == nil then
		finish = utf8.len(str)
	end
	local pos = 0
	for p, c in utf8.codes(str) do
		pos = pos + 1
		if pos >= start and pos <= finish then
			output[#output + 1] = utf8.char(c)
		end
	end
	return table.concat(output)
end

-------------------
-- Actual module --
-------------------

local m = {}

m.satus = ""
m.name = "mpd"
m.interval = 0.5
local marquee = 1
local marqueedir = 1
local track
local state = "pause"
local stateTags = {pause="||", play="[>", stop="[]", err="--"}
local textLength = ARGS.length or 20
local progress = 0 -- from 0-1, used to draw the progress bar/underline
local tick = 3 -- only update mpd once in 4 updates

local function stringStarts(str,start)
   return string.sub(str,1,string.len(start)) == start
end

local function connect()
	sock = socket.connect("127.0.0.1",6600)
	if sock ~= nil then
		-- skip first OK status
		sock:receive()
	end
end

local function query(command)
	connect()
	if sock == nil then
		connect()
		return 1
	end
	sock:send(command .. "\n")
	local answer = ""
	local a, b, c
	local answers = {}
	while answer ~= "OK" do
		answer, a, b, c = sock:receive()
		if stringStarts(answer, "ACK") then
			sock:close()
			return 1
		end
		local columnIndex = string.find(answer,":")
		if columnIndex ~= nil then
			local val = string.sub(answer,columnIndex+2)
			answers[string.sub(answer,1,columnIndex -1)] =
				tonumber(val) or val
		end
	end
	sock:close()
	return answers
end

local function createText(click,vol)
	local before
	if vol ~= nil then
		before = tostring(vol)..string.rep(" ",3 - #tostring(vol))
	else
		before = stateTags[state] .. " "
	end
	-- center text
	local center
	if utf8.len(track) < textLength then
		local pad = textLength - utf8.len(track)
		center = string.rep(" ",math.ceil(pad/2)) .. track .. string.rep(" ",math.floor(pad/2))
	elseif utf8.len(track) == textLength then
		center = track
	else -- marquee
		if not click then
			marquee = marquee + marqueedir
		end
		if marqueedir == 1 and utf8.len(track) - marquee == textLength - 1 then
			marqueedir = -1
		elseif marqueedir == -1 and marquee == 1 then
			marqueedir = 1
		end
		center = utf8.sub(track,marquee,marquee + 19)
	end
	local underlined = math.floor(progress * textLength + 0.5)
	if underlined == 0 then
		m.status = before..center
	elseif underlined == textLength then
		m.status = {before,{underline="single",text=center}}
	else
		m.status = {
			before,
			{underline = "single", 
				text=utf8.sub(center,1,underlined)},
			utf8.sub(center,underlined + 1)
		}
	end

end

function m.update()
	tick = tick + 1
	if tick == 4 then
		--TODO put this in a function so it can be called from m.click()
		local current = query("currentsong")
		local status = query("status")
		if type(current) ~= "number" and type(status) ~= "number" then
			state = status.state
			local newTrack = (current.Artist or "?") .. " - " .. (current.Title or "?")
			if newTrack ~= track then
				marquee = 0
				marqueedir = 1
				track = newTrack
			end
			if state == "play" or state == "pause" then
				progress = status.elapsed / status.duration
			else
				progress = 0
			end
		else
			state = "err"
			track = "Can't connect to MPD"
		end
		tick = 0
	end
	createText()
end

-- creates a 20 char long string representing a slider
-- val varies from 0 to 100
local function slider(val)
	local count = math.ceil(val / 100 * textLength)
	return string.rep("#",count)..string.rep("-",textLength-count)
end

-- creates the status from the specified volume
local function volStatus(val)
	return val .. string.rep(" ",3-#tostring(val)) .. slider(val)
end

function m.click(arg)
	local status = query("status")
	if status ~=1 then
		-- left click = pause
		if arg.button == 1 then
			query("pause "..(status.state == "play" and "1" or "0"))
			tick = 3
		-- middle click = previous
		elseif arg.button == 2 then
			query("previous")
			tick = 3
		-- right click = next
		elseif arg.button == 3 then
			query("next")
			tick = 3
		-- scroll up = vol up
		elseif arg.button == 4 then
			local newvol = math.min(status.volume + 2, 100)
			query("setvol " .. newvol)
			m.status = volStatus(newvol)
		-- scroll down = vol down
		elseif arg.button == 5 then
			local newvol = math.max(status.volume - 2, 0)
			query("setvol " .. newvol)
			m.status = volStatus(newvol)
		end
	end
end

return m
