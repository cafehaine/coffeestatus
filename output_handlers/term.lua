local m = {}

local function hexToRGB(color)
	local hex = color:match("^#(%x*)$")
	if not hex or #hex ~= 3 and #hex ~= 6 then
		return nil
	end
	-- Convert 3 digit hex to 6 digit hex color
	if #hex == 3 then
		hex = hex:gsub(".","%1%1")
	end
	r,g,b = hex:match("(..)(..)(..)")
	return tonumber(r, 16)..";"..tonumber(g, 16)..";"..tonumber(b, 16)
end

local function handlePango(parts)
	local temp = {}
	for i,part in ipairs(parts) do
		if type(part) == "string" then
			temp[i] = part
		else
			local before = ""
			local after = ""
			for key,val in pairs(part) do
				if key == "underline" and val ~= "none" then
					before = before .. "\27[4m"
					after = "\27[24m" .. after
				elseif key == "foreground" then
					local color = hexToRGB(val)
					if color then
						before = before .. "\27[38;2;"..color.."m"
						after = "\27[39m" .. after
					end
				elseif key == "background" then
					local color = hexToRGB(val)
					if color then
						before = before .. "\27[48;2;"..color.."m"
						after = "\27[49m" .. after
					end
				end
			end
			temp[i] = before .. part.text .. after
		end
	end
	return table.concat(temp, "")
end

function m.writestatus(modules)
	local line = {}
	for i = 1, #modules do
		if type(modules[i].status) == "table" then
			line[i] = handlePango(modules[i].status)
		else
			line[i] = modules[i].status
		end
	end
	output = table.concat(line," | ")
	io.write("\r"..output)
	io.flush()
end

return m
