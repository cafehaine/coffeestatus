local m = {}
_print('{"version":1,"click_events":true}')
_print("[")
io.flush()

local json = require("json")

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

function m.writestatus(modules)
	local line = {}
	for i = 1, #modules do
		local tab = {
			name = modules[i].name,
			instance = tostring(i)
		}
		if type(modules[i].status) == "table" then
			tab.markup = "pango"
			tab.full_text = formatWithPango(modules[i].status)
		else
			tab.full_text = modules[i].status
		end
		line[i] = json.encode(tab)
	end
	output = "["..table.concat(line,",").."],"
	_print(output)
	io.flush()
end

return m
