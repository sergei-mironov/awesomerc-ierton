local awful = require("awful")
local beautiful = require("beautiful")
local freedesktop_utils = require("freedesktop.utils")
local freedesktop_menu = require("freedesktop.menu")
local themes = require("myrc.themes")

local io = io
local table = table
local awesome = awesome
local ipairs = ipairs
local os = os
local string = string
local mouse = mouse

module("myrc.mainmenu")

local env = {}

-- Reserved.
function init(enviroment)
    env = enviroment
end

-- Creates main menu
-- Note: Uses beautiful.icon_theme and beautiful.icon_theme_size
-- env - table with string constants - command line to different apps
function build()
    local terminal = (env.terminal or "xterm") .. " "
    local man = (env.man or "xterm -e man") .. " "
    local editor = (env.editor or "xterm -e " .. (os.getenv("EDITOR") or "vim")) .. " "
    local browser = (env.browser or "firefox") .. " "
    local run = (env.run or "gmrun")
    local fileman = env.fileman or "xterm -e mc"
    local xkill = env.xkill or "xkill" .. " "
    local poweroff = env.poweroff or "sudo /sbin/poweroff"
    local hibernate = env.hibernate or nil
    local reboot = env.reboot or "sudo /sbin/reboot"

    freedesktop_utils.terminal = terminal
    freedesktop_utils.icon_theme = beautiful.icon_theme 
    freedesktop_utils.icon_sizes = {beautiful.icon_theme_size}

	local myquitmenu = {
        { "Poweroff", poweroff, freedesktop_utils.lookup_icon({ icon = 'gnome-logout' })}, 
        { "Reboot", reboot }, 
        { "Hibernate", hibernate }, 
        { "Logout", awesome.quit }, 
	}

    local myawesomemenu = { 
        { "Themes", themes.menu() }, 
        { "Edit config", editor .. awful.util.getdir("config") .. "/rc.lua", 
            freedesktop_utils.lookup_icon({ icon = 'package_settings' }) 
        },
        { "Edit theme", editor .. awful.util.getdir("config") .. "/current_theme" ,
            freedesktop_utils.lookup_icon({ icon = 'package_settings' }) 
        },
        { "Restart", awesome.restart, freedesktop_utils.lookup_icon({ icon = 'gtk-refresh' }) },
        { "Stop", awesome.quit } 
    }

    local mymainmenu_items_head = {
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
        { "Terminal", terminal, freedesktop_utils.lookup_icon({icon = 'terminal'}) },
        { "File Manager", fileman, freedesktop_utils.lookup_icon({icon = 'file-manager'}) },
        { "Browser", browser, freedesktop_utils.lookup_icon({icon = 'browser'}) },
        { "", nil, nil}, --separator
    }

    local mymainmenu_items_tail = {
        { "", nil, nil}, --separator
        { "Xkill", xkill, freedesktop_utils.lookup_icon({ icon = "weather-storm"}) },
        { "Run", run, freedesktop_utils.lookup_icon({ icon = "access"}) },
        { "", nil, nil}, --separator
        { "Quit", myquitmenu, freedesktop_utils.lookup_icon({ icon = 'gnome-logout' }) },
    }

    local mymainmenu_items = {}
    for _, item in ipairs(mymainmenu_items_head) do table.insert(mymainmenu_items, item) end
    for _, item in ipairs(freedesktop_menu.new()) do table.insert(mymainmenu_items, item) end
    for _, item in ipairs(mymainmenu_items_tail) do table.insert(mymainmenu_items, item) end

    return awful.menu({ items = mymainmenu_items, x = 0, y = 0})
end

