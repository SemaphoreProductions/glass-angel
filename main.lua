assets = require "assets"

local Window = require "window"
globalWindow = Window:new()

-- preload sprites to prevent stuttering

for _, file in ipairs(am.glob{"assets/images/*.png", "assets/images/expressions/*.png"}) do
    am.sprite(file)
end

local gameover = require 'gameover'

local Menu = require "menu"

local Game = require "game"

fonts = require("fonts")

globalWindow.scene = Game:new()