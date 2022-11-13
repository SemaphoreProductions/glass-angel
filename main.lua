assets = require "assets"
bump = require "lib.bump"

local Window = require "window"
local Menu = require "menu"

globalWindow = Window:new()

-- Does this _need_ to be global?
globalBumpWorld = bump.newWorld(16)

fonts = require("fonts")

globalWindow.scene = Menu:new()