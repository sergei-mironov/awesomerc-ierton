------------------------------------------------------------------------
-- Pipelets - will catch program messages
--
-- @author Sergey Mironov ierton-in-gmail
-- @copyright 2010 Sergey Mironov
-- @license GPLv3
-----------------------------------------------------------------------

local awful = require("awful")
local string = string
local io = io
local table = table
local pairs = pairs
local timer = timer
local type = type

module("pipelets")

-- Pipelets configuration
config = {
	script_path = "/usr/share/awesome/pipelets/",
	format_string = "$1",
	separator = nil,
	widget_field = "text",
}

-- # Utility functions
local util = {}

function util.fullpath(script)
	if string.find(script, '^/') == nil then
		script = config.script_path .. script
	end

	return script
end

--- Split string by separator into table
-- @param str String to split
-- @param sep Separator to use
function util.split(str, sep)
	if sep == nil then
		return { str }
	end
	local parts = {} --parts array
	local first = 1
	local ostart, oend = string.find(str, sep, first, true) --regexp disabled search

	while ostart do
		local part = string.sub(str, first, ostart - 1)
		table.insert(parts, part)
		first = oend + 1
		ostart, oend = string.find(str, sep, first, true)
	end

	local part = string.sub(str, first)
	table.insert(parts, part)

	return parts
end

--- Format script output with user defined format string
-- @param output sep-separated string of values
-- @param format Format string
-- @param sep Separator of values in string
function util.format(parts, format, sep)
	-- For each part with number "k" replace corresponding "$k" variable in format string
	for k,part in pairs(parts) do
		local part = string.gsub(part, "%%", "%1%1") --percent fix for next gsub (bug found in Wicked)
		part = awful.util.escape(part) --escape XML entities for correct Pango markup
		format = string.gsub(format, "$" .. k, part)
	end

	return format
end

--- Update widget from values
function util.update_widget(widget, values, format)
	local wifield = config.widget_field or "text"
	if widget ~= nil then
		if type(values) == "table" then
			widget[wifield] = util.format(values, format)
		else
			widget[wifield] = values
		end
	end
end

-- # Acting functions
function init()
	awful.util.spawn(awful.util.getdir("config").."/pipeman "..config.script_path)
end

local pipelets = {}

--- Function for external callbacks
function update(script_name, string)
	local f = pipelets[script_name]
	if f == nil then return end
	f(string)
end

--- Register widget in pipelets table
-- Pipe output will be splitted, escaped and formatted
--
-- @param widget Widget to send updates to
-- @param key Name of script or program to grab input from
-- @param format format of input (nil is allowed)
-- @param sep Separator (nil is alowed)
-- @returns the widget given
function register_fmt(widget, key, format, sep)
	-- Set optional variables
	format = format or config.format_string
	sep = sep or config.separator

	pipelets[key] = function(txt) 
		local txt = util.split(txt, sep)
		util.update_widget(widget, txt, format) 
	end

	return widget
end

--- Register widget in pipelets
-- Pipe output will be passed to widget as is
-- @param widget Widget to send updates to
-- @param key Name of script or program to grab input from
-- @returns the widget given
function register(widget, key)
	pipelets[key] = function(txt) 
		util.update_widget(widget, txt, "$1") 
	end
	return widget
end

