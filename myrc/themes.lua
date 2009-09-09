local awful = require("awful")
local beautiful = require("beautiful")
local freedesktop_utils = require("freedesktop.utils")
local freedesktop_menu = require("freedesktop.menu")

local io = io
local table = table
local awesome = awesome
local ipairs = ipairs
local os = os
local string = string

module("myrc.themes")

-- List your theme files and feed the menu table
function menu()
	local mythememenu = {}
	local cfgpath = awful.util.getdir("config")
	local themespath = cfgpath .. "/themes"
	local cmd = "find -L " .. themespath .. " -name 'theme.lua' -and -not -path '*.current*'"
	local f = io.popen(cmd)
	for l in f:lines() do
		local item = { string.gsub(l,"[%w/._-]+/([%w-_]+)/theme.lua", "%1"),
		function () 
			local themepath = string.gsub(l,"(%w+)/theme.lua", "%1")
			os.execute("rm -f " .. themespath .. "/.current")
			os.execute("ln -s " .. l .. " " .. themespath .. "/.current")
			awesome.restart()
		end }
		table.insert(mythememenu, item)
	end

	f:close()
	return mythememenu
end

function current()
	return awful.util.getdir("config") .. "/themes/.current"
end


