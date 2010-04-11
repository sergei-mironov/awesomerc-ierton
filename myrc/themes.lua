-- Author: Sergey Mironov ierton@gmail.com
-- License: BSD3
-- 2009-2010
--
-- Library manages current theme symlink

local awful = require("awful")
local io = io
local table = table
local awesome = awesome
local os = os
local string = string

module("myrc.themes")


local function hasfile(f)
    local exists = io.open(f)
    if exists then
        io.close(exists)
        return f
    end
    return nil
end

-- List your theme files and feed menu table
-- Item handlers will create .current symlink 
-- to point to theme selected
function menu(args)
    args = args or {}
    args.default_icon = args.default_icon or "/usr/local/share/awesome/icons/awesome16.png"
	local mythememenu = {}
	local cfgpath = awful.util.getdir("config")
	local themespath = cfgpath .. "/themes"
	local cmd = "find -L " .. themespath .. " -name 'theme.lua' -and -not -path '*.current*'"
	local f = io.popen(cmd)
	for l in f:lines() do
		local folder = string.gsub(l,"[%w/._-]+/([%w-_]+)/theme.lua", "%1")
        local icon = 
            hasfile(themespath .. "/" .. folder .. "/awesome-icon.png") or
            hasfile(args.default_icon)
		local item = { folder, function () 
			local themepath = string.gsub(l,"(%w+)/theme.lua", "%1")
			awful.util.pread("rm -f " .. themespath .. "/.current")
			awful.util.pread("ln -s " .. folder .. " " .. themespath .. "/.current")
			awesome.restart()
		end, icon }
		table.insert(mythememenu, item)
	end

	f:close()
	return mythememenu
end

-- Returns current theme.
-- @param default Default theme name
function current(default)
    local default = default or "blue-black-red"
    local filename = awful.util.getdir("config") .. "/themes/.current/theme.lua"
    local handle = io.open(filename)
    if handle == nil then
        return awful.util.getdir("config") .. "/themes/" .. default .. "/theme.lua"
    else
        io.close(handle)
        return filename
    end
end


