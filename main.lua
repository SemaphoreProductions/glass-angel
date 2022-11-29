assets = require "assets"

local Window = require "window"
globalWindow = Window:new()

local Menu = require "menu"

local Game = require "game"

fonts = require("fonts")

globalWindow.scene = Game:new()