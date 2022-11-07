assets = require "assets"

local Window = require "window"
local Menu = require "menu"

globalWindow = Window:new()

fonts = require("fonts")

globalWindow.scene = Menu:new()