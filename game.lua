local Game = ...
local Character = require 'character'

local avaicon = [[
    YYY
    YYY
    YYY
]]

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

function Game:new()
    local score = 0
    local wave = 1

    globalBumpWorld = bump.newWorld(16)

    local ava = Character:new("ava", avaicon, avaMoveset)
    local finch = Character:new("finch", finchicon, finchMoveset)

    local game = am.group() ^ {
        am.scale(30) ^ Character:newNode(ava),
        am.scale(30) ^ Character:newNode(finch)
    }
    

    -- main game loop
    game:action(function(node) end)

    return game
end