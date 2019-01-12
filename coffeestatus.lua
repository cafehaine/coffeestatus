#!/bin/lua5.3
--[[
 Remember to install the following luarocks rocks :

 - luasocket  : used for sleep/gettime here and used in the mpd module
     [ archlinux package: community/lua-socket ]
 - luaposix   : used for "nonblocking" io to read clicks from i3bar
     [ archlinux package: aur/lua-posix ]
 - luajson  : used to communicate back and forth with i3bar
     [ archlinux package: extra/lua-luajson ]
]]

-- Do nothing
local function noop() end

-- Return the value of an environment variable or default if it isn't set or is
-- empty.
local function getenv(variable, default)
	local value = os.getenv(variable)
	if not value or value == "" then
		return default
	end
	return value
end

-- Return the first valid path for a file, starting from the end of the paths
-- table.
local function filepath(filename, paths)
	for i=#paths, 1, -1 do
		file = io.open(paths[i]..filename)
		if file then
			file:close()
			return paths[i]..filename
		end
	end
	return nil
end

-- Detect if running dev or installed version based on the script's name
MODE = "installed"
if arg[0]:sub(-4) == ".lua" then
	MODE = "dev"
end

-- Path of coffeestatus
BINARY_PATH = arg[0]:match(".*/") or "./"

-- Home
HOME = os.getenv("HOME").."/"

-- Paths for modules
if MODE == "installed" then
	local xdg_data_home = getenv("XDG_DATA_HOME", HOME..".local/share").."/"
	MODULE_PATHS = {
		BINARY_PATH.."../lib/coffeestatus/modules/",
		HOME..".coffeestatus/",
		xdg_data_home.."coffeestatus/modules/",
	}
else
	MODULE_PATHS = {BINARY_PATH.."modules/"}
end

-- Paths for config
CONFIG_PATHS = {
	"/etc/coffeestatus_conf.json",
	HOME..".coffeestatus/conf.json",
	getenv("XDG_CONFIG_HOME", HOME..".config").."/coffeestatus/conf.json",
}
if MODE == "dev" then
	table.insert(CONFIG_PATHS, 1, BINARY_PATH.."default_conf.json")
end

print('{"version":1,"click_events":true}')
print("[")
print('[{"full_text":"Loading coffeestatus"}],')
io.flush()

local posix = require("posix")
local rpoll = require("posix.poll").rpoll
local stdin = require("posix.unistd").STDIN_FILENO
local socket = require("socket")
local json = require("json")

-- if you don't want to use luasocket at all, replace the following functions
-- to another module that you want to use
local sleep = socket.sleep
local gettime = socket.gettime

-- remove access to print in order to prevent devs from "crashing" i3bar with
-- random garbage in stdout
local logfile = io.open("/tmp/coffeestatus_log","w")

-- act as a replacement for print, outputing everything in /tmp/coffeestatus_log
local function log(...)
	local output = {}
	for i = 1, select("#", ...) do
		output[i] = tostring(select(i,...))
	end
	logfile:write(table.concat(output, "\t").."\n")
	logfile:flush()
end

local p = print
_G.print = log

print("Log started on " .. os.date())

-- check for new input from error mode
local function errorInputCheck()
	if rpoll(stdin,0) == 1 then
		local str = io.read()
		-- it was the first time the bar was clicked, read twice
		if str == "[" then
			io.read()
		end
		return true
	end
	return false
end

-- error mode
local function handleError(message)
	log("Error happened")
	log("--------------")
	log(message)
	while 1 do
		p('[{"full_text":"An error happened, look at /tmp/coffeestatus_log for more."}],')
		io.flush()
		sleep(1)
		if errorInputCheck() then return end
		p('[{"full_text":"Click the bar to try and continue running. This might make coffeestatus unstable."}],')
		io.flush()
		sleep(1)
		if errorInputCheck() then return end
	end
end
---------------------
-- Program startup --
---------------------

local modules = {}
local timers = {}
local conf = io.open(filepath("", CONFIG_PATHS))
local status, value = pcall(json.decode,conf:read("*a"))
if not status then
	handleError("Failed to read configuration file:\n"..value)
end
to_load = value
conf:close()

for i=1, #to_load do
	_G.ARGS = to_load[i]
	p('[{"full_text":"Loading module ' ..i.. "/" ..#to_load.. '"}],')
	io.flush()
	local path = filepath(to_load[i].name..".lua", MODULE_PATHS)
	if path == nil then
		handleError("Could not find module '" .. to_load[i].name .. "'")
		modules[i] = {name=to_load[i].name,status="ERROR ["..to_load[i].name.."]",update=noop, click=noop, interval=100000}
		timers[i] = modules[i].interval
	else
		local status, value = pcall(dofile,path)
		if not status then
			handleError("Failed to load module "..to_load[i].name..":\n"..value)
			-- if user tries to continue after failed loading, replace module with
			-- this stub
			value = {name=to_load[i].name,status="ERROR ["..to_load[i].name.."]",update=noop, click=noop, interval=100000}
		end
		modules[i] = value
		timers[i] = modules[i].interval
	end
end

local changed = true
local output = ""

-- Treat str and call target module's click function
local function handleInput(str)
	-- immediatly read next line in case of opening bracket
	if str == "[" then
		str = io.read()
	--ignore coma (block following opening bracket does not have a coma)
	elseif string.sub(str,1,1) == "," then
		str = string.sub(str,2)
	end
	local table = json.decode(str)
	local inst = tonumber(table.instance)
	local oldstatus = modules[inst].status
	local status, value = pcall(modules[inst].click, table)
	if not status then
		handleError("Failed to run click function in module "..modules[inst].name..":\n"..value)
		return
	end
	-- reset timer since modules can change status during click events
	timers[inst] = 0
	changed = changed or oldstatus ~= modules[inst].status
end

-- Pango suff

local xmlPattern = "([%<%>%\"%'%&])"
local xmlChars = {
	["<"]="&lt;",
	[">"]="&gt;",
	['"']="&quot;",
	["&"]="&amp;",
	["'"]="&apos;"
}

local function escape(char)
	return xmlChars[char]
end

local function escapeXml(str)
	return str:gsub(xmlPattern,escape)
end

local function formatWithPango(tab)
	local output = {}
	for i=1,#tab do
		if type(tab[i]) == "string" then
			output[i] = escapeXml(tab[i])
		else
			local attributes = {}
			for k,v in pairs(tab[i]) do
				if k ~= "text" then
					attributes[#attributes + 1] = k.."=\""..v.."\""
				end
			end
			output[i] = "<span "..table.concat(attributes, " ")..">"..escapeXml(tab[i].text).."</span>"
		end
	end
	return table.concat(output)
end

-- Main loop
local oldtime = gettime()

while 1 do
	local line = {}
	-- compute delta time to be as accurate as possible for timers
	local newtime = gettime()
	local dt = newtime - oldtime
	oldtime = newtime
	-- computer probably went to sleep, skip this dt
	if dt > 2 then
		dt = 0
	end
	for i=1,#modules do
		timers[i] = timers[i] + dt
		if timers[i] >= modules[i].interval then
			local oldStatus = modules[i].status
			local status, value = pcall(modules[i].update)
			if not status then
				handleError("Failed to update module "..modules[i].name..":\n"..value)
			end
			if oldStatus ~= modules[i].status then
				changed = true
			end
			timers[i] = timers[i] - modules[i].interval
		end
	end
	-- update only if at least one of the statuses changed
	if changed then
		for i = 1, #modules do
			local tab = {
				name = modules[i].name,
				instance = tostring(i)}
			if type(modules[i].status) == "table" then
				tab.markup = "pango"
				tab.full_text = formatWithPango(modules[i].status)
			else
				tab.full_text = modules[i].status
			end
			line[i] = json.encode(tab)
		end
		output = "["..table.concat(line,",").."],"
		changed = false
		p(output)
		io.flush()
	end
	-- read input only if an event happened on the fd for stdin
	-- (since we fully empty stdin after each read, events happen whenever
	-- there is new inputs)
	if rpoll(stdin,0) == 1 then
		handleInput(io.read())
	end

	sleep(0.05)
end

