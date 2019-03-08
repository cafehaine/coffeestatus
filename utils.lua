local m = {}

-- Do nothing
function m.noop() end

-- Return the value of an environment variable or default if it isn't set or is
-- empty.
function m.getenv(variable, default)
	local value = os.getenv(variable)
	if not value or value == "" then
		return default
	end
	return value
end

-- Return the first valid path for a file, starting from the end of the paths
-- table.
function m.filepath(filename, paths)
	for i=#paths, 1, -1 do
		file = io.open(paths[i]..filename)
		if file then
			file:close()
			return paths[i]..filename
		end
	end
	return nil
end

-- Recursively clone a table.
function m.tableclone(tab)
	local output = {}
	for k,v in pairs(tab) do
		if type(v) == "table" then
			output[k] = m.tableclone(v)
		else
			output[k] = v
		end
	end
	return output
end

-- Overlay a table with another one.
function m.overlaytables(root, overlay)
	local output = m.tableclone(root)

	for k,v in pairs(overlay) do
		output[k] = v
	end

	return output
end

return m
