-------------------------------
--    "Sky" awesome theme    --
--  By Andrei "Garoth" Thorp --
-------------------------------
-- If you want SVGs and extras, get them from garoth.com/awesome/sky-theme

-- BASICS
theme = {}
theme.font          = "sans 8"

theme.bg_focus      = "#E8E7E6" -- "#e2eeea"
theme.bg_normal     = "#8972CF" -- gentoo-purple -- "#729fcf"
theme.bg_urgent     = "#fce94f"
theme.bg_minimize   = "#0067ce"

theme.fg_normal     = "#2e3436"
theme.fg_focus      = "#2e3436"
theme.fg_urgent     = "#2e3436"
theme.fg_minimize   = "#2e3436"

theme.border_width  = "2"
theme.border_normal = "#dae3e0"
theme.border_focus  = theme.bg_normal -- "#729fcf"
theme.border_marked = "#eeeeec"

theme.menu_bg_focus = theme.bg_normal -- "#7985A3"
theme.menu_bg_normal = theme.bg_focus -- "#454545"
theme.menu_border_color = "#7985A3"

theme.name = "sky2"
theme.shared = "/usr/local/share/awesome"
theme.config = awful.util.getdir("config")
theme.path = theme.config .. "/themes/" .. theme.name

-- IMAGES
theme.layout_fairh           = theme.shared .. "/themes/sky/layouts/fairh.png"
theme.layout_fairv           = theme.shared .. "/themes/sky/layouts/fairv.png"
theme.layout_floating        = theme.shared .. "/themes/sky/layouts/floating.png"
theme.layout_magnifier       = theme.shared .. "/themes/sky/layouts/magnifier.png"
theme.layout_max             = theme.shared .. "/themes/sky/layouts/max.png"
theme.layout_fullscreen      = theme.shared .. "/themes/sky/layouts/fullscreen.png"
theme.layout_tilebottom      = theme.shared .. "/themes/sky/layouts/tilebottom.png"
theme.layout_tileleft        = theme.shared .. "/themes/sky/layouts/tileleft.png"
theme.layout_tile            = theme.shared .. "/themes/sky/layouts/tile.png"
theme.layout_tiletop         = theme.shared .. "/themes/sky/layouts/tiletop.png"

theme.icon_theme = "Tango"
theme.icon_theme_size = "32x32"
theme.awesome_icon = theme.config .. "/icons/im-aim.png"
theme.clientmenu_icon = theme.shared .. "/icons/awesome16.png"
theme.xvkbd_icon = theme.config .. "/icons/keyboard.png"
theme.tasklist_floating_icon = theme.shared .. "/themes/sky/layouts/floating.png"


-- from default for now...
theme.menu_submenu_icon     = theme.shared .. "/themes/default/submenu.png"
theme.taglist_squares_sel   = theme.shared .. "/themes/default/taglist/squarefw.png"
theme.taglist_squares_unsel = theme.shared .. "/themes/default/taglist/squarew.png"

-- MISC
theme.wallpaper_cmd         = nil --{ "awsetbg /usr/local/share/awesome/themes/sky/sky-background.png" }
theme.taglist_squares       = "true"
theme.titlebar_close_button = "true"
theme.menu_width            = "200"
theme.menu_height           = 24
theme.menu_context_height   = 20
theme.menu_border_width     = 0

-- Define the image to load
theme.titlebar_close_button_normal = theme.shared .. "/themes/default/titlebar/close_normal.png"
theme.titlebar_close_button_focus = theme.shared .. "/themes/default/titlebar/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = theme.shared .. "/themes/default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive = theme.shared .. "/themes/default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = theme.shared .. "/themes/default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active = theme.shared .. "/themes/default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = theme.shared .. "/themes/default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive = theme.shared .. "/themes/default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = theme.shared .. "/themes/default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active = theme.shared .. "/themes/default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = theme.shared .. "/themes/default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive = theme.shared .. "/themes/default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = theme.shared .. "/themes/default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active = theme.shared .. "/themes/default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = theme.shared .. "/themes/default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive = theme.shared .. "/themes/default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = theme.shared .. "/themes/default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active = theme.shared .. "/themes/default/titlebar/maximized_focus_active.png"

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
