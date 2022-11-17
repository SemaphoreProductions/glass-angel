local Game = ...
local Character = require 'character'
local bg = require 'bg'
local anima = require 'anima'

local finchicon = [[
    BBB
    BBB
    BBB
]]

avaMoveset = {
    ["left"]  = vec2(-1.0, 0.0),
    ["right"] = vec2(1.0, 0.0),
    ["up"]    = vec2(0.0, 1.0),
    ["down"]  = vec2(0.0, -1.0)
}

finchMoveset = {
    ["a"]  = vec2(-1.0, 0.0),
    ["d"] = vec2(1.0, 0.0),
    ["w"]    = vec2(0.0, 1.0),
    ["s"]  = vec2(0.0, -1.0)
}

local idleAnimation = {
    { row = 2, col = 1 },
    { row = 2, col = 2 },
    { row = 2, col = 3 },
    { row = 2, col = 4 },
    { row = 2, col = 5 },
    { row = 2, col = 6 },
    { row = 2, col = 7 },
    { row = 2, col = 8 },
    { row = 2, col = 9 },
    { row = 2, col = 10 },
    { row = 2, col = 11 },
    { row = 2, col = 12 },
    { row = 2, col = 13 },
    { row = 2, col = 14 },
    nil
}

function Game:new()
    local score = 0
    local wave = 1

    globalBumpWorld = bump.newWorld(16)

    local ava = Character:new("ava", anima.te({
        file = "assets/sprite/blue_angel.png",
        width = 128,
        height = 192,
        fps = 12.0
    }, idleAnimation), avaMoveset)
    local finch = Character:new("finch", anima.te({
        file = "assets/sprite/red_angel.png",
        width = 128,
        height = 192,
        fps = 12.0
    }, idleAnimation), finchMoveset)

    local game = am.group() ^ {
        bg.scrolling,
        Character:newNode(ava),
        Character:newNode(finch)
    }
    

    -- main game loop
    game:action(function(node) end)

    return game
end