local awful = require("awful")
--local beautiful = require("beautiful")
--local freedesktop_utils = require("freedesktop.utils")
--local freedesktop_menu = require("freedesktop.menu")

local io = io
local table = table
local awesome = awesome
local ipairs = ipairs
local tostring = tostring
local type = type
local string = string

module("myrc.memory")

local tables = {}
local current_version = 1

function init()
	local config = awful.util.getdir("config").."/memory.data"
	tables, err = table.load(config)
	if err ~= nil then
		tables = {}
	end
	if tables.verion == nil then
		tables.verion = current_version
	end
end

function set(t, key, value)
	if type(tables[t]) == "nil" then
		tables[t] = {}
	end
	local oldvalue = tables[t] [key]
	tables[t] [key] = value
	if oldvalue ~= value then
		local config = awful.util.getdir("config").."/memory.data"
		local res, err = table.save(tables, config)
	end
	return value
end

function get(table, key, defvalue)

	if type(tables[table]) == "nil" then
		return defvalue
	elseif type(tables[table][key]) == nil then
		return defvalue
	end

	return tables[table][key]
end


