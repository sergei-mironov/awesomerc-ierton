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
    local rotate = env.rotate or nil
    local logout = env.logout or awesome.quit

    freedesktop_utils.terminal = terminal
    freedesktop_utils.icon_theme = beautiful.icon_theme 
    freedesktop_utils.icon_sizes = {beautiful.icon_theme_size}

	local myquitmenu = {
        { "&Poweroff", poweroff, freedesktop_utils.lookup_icon({ icon = 'system-shutdown' })}, 
        { "&Reboot", reboot, freedesktop_utils.lookup_icon({ icon = 'system-shutdown' })}, 
        { "H&ibernate", hibernate, freedesktop_utils.lookup_icon({ icon = 'system-shutdown' }) }, 
        { "&Logout", logout , freedesktop_utils.lookup_icon({ icon = 'gnome-logout' })}, 
	}

    local myawesomemenu = { 
        { "&Themes", themes.menu(), 
            freedesktop_utils.lookup_icon({ icon = 'wallpaper' }) }, 
        { "&Restart", awesome.restart, freedesktop_utils.lookup_icon({ icon = 'reload' }) },
        { "&Stop", awesome.quit, freedesktop_utils.lookup_icon({ icon = 'stop' }) } 
    }

    local mymainmenu_items_head = {
        { "&A Awesome", myawesomemenu, beautiful.awesome_icon },
        { "&E Terminal", terminal, freedesktop_utils.lookup_icon({icon = 'terminal'}) },
        { "&M File Manager", fileman, freedesktop_utils.lookup_icon({icon = 'file-manager'}) },
        { "&F Firefox", browser, freedesktop_utils.lookup_icon({icon = 'browser'}) },
        { "", nil, nil}, --separator
    }

    local mymainmenu_items_tail = {
        { "", nil, nil}, --separator
        { "&R Rotate", {
            {"&Normal", rotate .. " normal" , freedesktop_utils.lookup_icon({icon = 'stock_down'})},
            {"&Left",   rotate .. " left"   , freedesktop_utils.lookup_icon({icon = 'stock_left'})},
            {"&Rigth",  rotate .. " right"  , freedesktop_utils.lookup_icon({icon = 'stock_right'})},
        }, freedesktop_utils.lookup_icon({icon = 'reload'})},
        { "&W Wifi", {
            {"&Unblock", env.rfkill.unblock , freedesktop_utils.lookup_icon({icon = 'stock_up'})},
            {"&Block",   env.rfkill.block   , freedesktop_utils.lookup_icon({icon = 'stock_down'})},
        }, freedesktop_utils.lookup_icon({icon = 'wicd-gtk'})},
        { "&X Xkill", xkill, freedesktop_utils.lookup_icon({ icon = "weather-storm"}) },
        { "&U Run", run, freedesktop_utils.lookup_icon({ icon = "access"}) },
        { "", nil, nil}, --separator
        { "&P Power", myquitmenu, freedesktop_utils.lookup_icon({ icon = 'gnome-logout' }) },
    }

    local mymainmenu_items = {}
    for _, item in ipairs(mymainmenu_items_head) do table.insert(mymainmenu_items, item) end
    for _, item in ipairs(freedesktop_menu.new()) do table.insert(mymainmenu_items, item) end
    for _, item in ipairs(mymainmenu_items_tail) do table.insert(mymainmenu_items, item) end

    return awful.menu({ items = mymainmenu_items, x = 0, y = 0})
end

