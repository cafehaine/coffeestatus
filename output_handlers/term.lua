local m = {}

function m.writestatus(modules)
	local line = {}
	for i = 1, #modules do
		if type(modules[i].status) == "table" then
			local temp = {}
			for _,part in ipairs(modules[i].status) do
				if type(part) == "string" then
					temp[_] = part
				else
					temp[_] = part.text
				end
			end
			line[i] = table.concat(temp, "")
		else
			line[i] = modules[i].status
		end
	end
	output = table.concat(line," | ")
	io.write("\r"..output)
	io.flush()
end

return m
