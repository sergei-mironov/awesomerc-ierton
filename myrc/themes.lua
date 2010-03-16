local awful = require("awful")
local beautiful = require("beautiful")
local freedesktop_utils = require("freedesktop.utils")
local freedesktop_menu = require("freedesktop.menu")
local naughty = require("naughty")

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
		local folder = string.gsub(l,"[%w/._-]+/([%w-_]+)/theme.lua", "%1")
		local item = { folder,
		function () 
			local themepath = string.gsub(l,"(%w+)/theme.lua", "%1")
			os.execute("rm -f " .. themespath .. "/.current")
			os.execute("ln -s " .. folder .. " " .. themespath .. "/.current")
			awesome.restart()
		end }
		table.insert(mythememenu, item)
	end

	f:close()
	return mythememenu
end

function current()
    local filename = awful.util.getdir("config") .. "/themes/.current/theme.lua"
    local handle = io.open(filename)
    if handle == nil then
        return awful.util.getdir("config") .. "/themes/blue-black-red/theme.lua"
    else
        io.close(handle)
        return filename
    end
end


