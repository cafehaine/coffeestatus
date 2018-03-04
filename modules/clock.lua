local c = {}

c.interval = 1
c.name = "clock"

function c.update()
	c.status = os.date("%a %d %b - %H:%M")
end

function c.click()
	os.execute("gnome-calendar&")
	c.status = "Starting calendar."
end

return c
