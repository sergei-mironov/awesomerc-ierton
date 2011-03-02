local awful = require("awful")

module("myrc.logmon")

function init()
	awful.util.spawn(awful.util.getdir("config").."/lognotifier", false)
end

