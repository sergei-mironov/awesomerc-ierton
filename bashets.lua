------------------------------------------------------------------------
-- Bashets - use your shellscript's output in Awesome3 widgets
--
-- @author Anton Lobov &lt;ahmad200512@yandex.ru&gt;
-- @copyright 2009 Anton Lobov
-- @license GPLv2
-- @release 0.3 for Awesome 3.4
-- @todo Implement better timer scheduling if possible. 
-----------------------------------------------------------------------

-- Grab only needed enviroment
local awful = require("awful")
local string = string
local io = io
local table = table
local pairs = pairs
local timer = timer
local type = type

--- Bashets module
module("bashets")

-- Default paths
local script_path = "/usr/share/awesome/bashets/"
local tmp_folder = "/tmp/"

-- Utility functions table
local util = {}

-- Timer data
local timerdata = {}
local timers = {}

-- Some default values
local defaults = {}
defaults.update_time = 1
defaults.file_update_time = 2
defaults.format_string = "$1"
defaults.separator = nil
defaults.field = "text"

widget_field = defaults.field

-- State variable
local is_running = false

-- # Utility functions

--- Split string by separator into table
-- @param str String to split
-- @param sep Separator to use
function util.split(str, sep)
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

function util.tmpname(script)
	-- Replace all slashes with empty string so that /home/user1/script.sh 
	-- and /home/user2/script.sh will have different temporary files
	local tmpname = string.gsub(script, '/', '')

	-- Replace all spaces with dots so that "script.sh arg1"
	-- and "script.sh arg2" will have different temporary files
	tmpname = string.gsub(tmpname, '%s+', '.')

	-- Generated script-parameter unique temporary file path
	local file = tmp_folder .. tmpname .. '.bashets.out'

	return file
end

function util.fullpath(script)
	if string.find(script, '^/') == nil then
		script = script_path .. script
	end

	return script
end

--- Execute a command and write it's output to temporary file
-- @param script Script to execute
-- @param file File for script output
function util.execfile(script, file)
	-- Spawn command and redirect it's output to file
	awful.util.spawn_with_shell(script .. " > " .. file)
end

--- Read temporary file to a table or string
-- @param file File to be read
-- @param israw If true, return raw string, not table
function util.readfile(file, sep)
	local fh = io.input(file)
	local str = fh:read("*all");
	io.close(fh)

	if sep == nil then
		return str
	else
		parts = util.split(str, sep);
		return parts
	end
end

--- Read script output to a table or string
-- @param script Script to execute
-- @param israw If true, return raw string, not table
function util.readshell(script, sep)
	local str = awful.util.pread(script)

	if sep == nil then
		return str
	else
		parts = util.split(str, sep);
		return parts
	end
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

--- Add function to corresponding timer object (Awesome >= 3.4 timer API)
-- @param updtime Update time for widget, also dispatch time for timer
-- @param func Function to dispatch
function util.add_to_timings(updtime, func, force_new)
	local found = false

	-- Search for an existing timer at the same period
	for k,tmr in pairs(timerdata) do
		if tmr[1] == updtime and (force_new == nil or force_new == false) then
			table.insert(timerdata[k][2], func)
			found = true
		end
	end

	-- Add a new timer for period if not found
	if not found then
		table.insert(timerdata, {updtime, {func}})
	end
end

--- Create timer table to define timers for multiple widget updates
function util.create_timers_table()
	-- Parse table with timer data
	for _,tmr in pairs(timerdata) do
		-- Create timer for the period
		local t = timer {timeout = tmr[1]}
		-- Function to call all dispatched functions
		local f = function()
			for _, func in pairs(tmr[2]) do
				func()
			end
		end
		t:add_signal("timeout", f)
		table.insert(timers, t)
	end
end

--- Update widget from values
function util.update_widget(widget, values, format)
	local wifield = widget_field or "text"
	if widget ~= nil then
		if type(values) == "table" then
			widget[wifield] = util.format(values, format)
		else
			widget[wifield] = values
		end
	end
end

-- # Setter functions

--- Set path for scripts
-- @param path Path to set
function set_script_path(path)
	script_path = path
end

--- Set path for temporary files
-- @param path Path to set
function set_temporary_path(path)
	tmp_folder = path
end

--- Set default values
-- @param defs Table with defaults
function set_defaults(defs)
	if type(defs) == "table" then
		if defs.update_time ~= nil then
			defaults.update_time = defs.update_time
		end 
		if defs.file_update_time ~= nil then
			defaults.file_update_time = defs.file_update_time
		end 
		if defs.format_string ~= nil then
			defaults.format_string = defs.format_string
		end 

		defaults.separator = defs.separator --now could be nil

		if defs.widget_field ~= nil then
			defaults.field = defs.widget_field
		end
	end
end

--- Set widget field for updates
-- @param fieldstr String representing widget field
function set_widget_field(fieldstr)
	widget_field = fieldstr
end


-- # Acting functions

--- Start widget updates
function start()
	-- Create timers table if not initialized or empty
	if (not timers) or table.maxn(timers) == 0 then
		util.create_timers_table()
	end
	-- Start all timers
	for _, tmr in pairs(timers) do
		tmr:start()
	end
	is_running = true
end

--- Stop widget updates
function stop()
	-- Stop all timers
	for _, tmr in pairs(timers) do
		tmr:stop()
	end
	is_running = false
end

--- Check whether updates are running
function get_running()
	return is_running
end

--- Toggle updates
function toggle()
	if is_running then
		start()
	else
		stop()
	end
end

--- Shedule function for timed execution
-- @param func Function to run
-- @param updatime Update time (optional)
function schedule(func, updtime)
	updtime = updtime or defaults.update_time
	if func ~= nil then
		util.add_to_timings(updtime, func)
	end
end

-- # Widget registration functions

--- Register script for text widget
-- @param widget Widget to update
-- @param script Script to use it's output
-- @param format User-defined format string (optional)
-- @param updtime Update time in seconds (optional)
-- @param sep Output separator (optional)
function register(widget, script, format, updtime, sep)
	-- Set optional variables
	updtime = updtime or defaults.update_time
	format = format or defaults.format_string
	sep = sep or defaults.separator

	script = util.fullpath(script)

	-- Do it first time
	local data = util.readshell(script, sep)
	util.update_widget(widget, data, format)

	-- Schedule it for timed execution
	schedule(function() 
		local data = util.readshell(script, sep)
		util.update_widget(widget, data, format) 
	end, updtime)
end

--- Register script for widget's widget_field throughout the temporary file
-- @param widget Widget to update
-- @param script Script to use it's output
-- @param format User-defined format string (optional)
-- @param time1 File update time in seconds (optional)
-- @param time2 Widget update time in seconds (optional)
-- @param sep Output separator (optional)
function register_async(widget, script, format, time1, time2, sep)
	-- Set optional variables
	time1 = time1 or defaults.file_update_time
	time2 = time2 or defaults.update_time 
	format = format or defaults.format_string 
	sep = sep or defaults.separator

	script = util.fullpath(script)
	local tmpfile = util.tmpname(script)

	-- Create temporary file if not exists
	fl = io.open(tmpfile, "w")
	io.close(fl)

	-- Do it first time
	util.execfile(script, tmpfile)
	local data = util.readfile(tmpfile)
	util.update_widget(widget, data, format)

	-- Schedule it for timed execution
	schedule(function() util.execfile(script, tmpfile) end, time1)
	schedule(function()
		local data = util.readfile(tmpfile, sep)
		util.update_widget(widget, data, format)
	end, time2)
end

--- Register text file for text widget
-- @param widget Widget to update
-- @param file File to use as data source
-- @param format Format string (optional)
-- @param time Update time (optional)
-- @param sep Separator (optional)
function register_file(widget, file, format, time, sep)
	-- Set optional variables
	time = time or defaults.update_time
	format = format or defaults.format_string
	sep = sep or defaults.separator

	-- Do it first time
	local data = util.readfile(file, sep)
	util.update_widget(widget, data, format)

	-- Schedule it for timed execution
	schedule(function()
		local data = util.readfile(file, sep)
		util.update_widget(widget, data, format)
	end, time)
end

--- Register Lua function for text widget
-- @param widget Widget to update
-- @param func Function to return variables table
-- @param format Format string (optional)
-- @param time Update time (optional)
function register_lua(widget, func, format, time)
	-- Set optional variables
	time = time or defaults.update_time
	format = format or defaults.format_string
	sep = sep or defaults.separator

	-- Do it first time
	local data = func()
	util.update_widget(widget, data, format)

	-- Schedule it for timed execution
	schedule(function()
		local data = func()
		util.update_widget(widget, data, format)
	end, time)
end

