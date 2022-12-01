assets = require "assets"

local Window = require "window"
globalWindow = Window:new()

-- preload sprites to prevent stuttering

local preload = {
    "assets/images/background3.png",
    "assets/images/expressions/angry.png",
    "assets/images/expressions/angry_A.png",
    "assets/images/expressions/happy.png",
    "assets/images/expressions/happy_A.png",
    "assets/images/expressions/neutral.png",
    "assets/images/expressions/neutral_A.png",
    "assets/images/expressions/surprise.png",
    "assets/images/expressions/surprise_A.png",
    "assets/images/stage1finished.png",
    "assets/images/stage3.png",
}

for _, file in ipairs(preload) do
    am.sprite(file)
end

local gameover = require 'gameover'

local Menu = require "menu"

local Game = require "game"

fonts = require("fonts")

globalWindow.scene = Menu:new()