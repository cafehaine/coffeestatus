local p = {}

--[[
 luastatus supports using pango markup like attributes.
 see bellow for a quick demo of how to use this.
 the attributes allowed are the same as the span attributes in pango,
 represented inside a table.
]]--
-- For more informations about pango:
-- https://developer.gnome.org/pango/stable/PangoMarkupFormat.html

p.interval = 100000
p.name = "pango demo"

p.status = {
	"Normal text",
	{foreground="#F00",text="C"},
	{foreground="#FF0",text="O"},
	{foreground="#0F0",text="L"},
	{foreground="#0FF",text="O"},
	{foreground="#00F",text="R"},
	{foreground="#F0F",text="S "},
	{style="italic",text="italic "},
	{weight="bold",text="bold "},
	{underline="single",text="underline "},
	{size="xx-small",text="xx-small :)"}
	}

function p.update() end
function p.click() end

return p

