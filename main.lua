assets = require "assets"

local Window = require "window"
globalWindow = Window:new()

local gameover = require 'gameover'

local Menu = require "menu"

local Game = require "game"

fonts = require("fonts")

globalWindow.scene = gameover.scene