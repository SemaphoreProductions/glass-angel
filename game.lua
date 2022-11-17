local Game = ...
local Character = require 'character'
local bg = require 'bg'
local anima = require 'anima'
local Projectile = require 'projectile'

local finchicon = [[
    BBB
    BBB
    BBB
]]

local avaMoveset = {
    ["left"]  = vec2(-1.0, 0.0),
    ["right"] = vec2(1.0, 0.0),
    ["up"]    = vec2(0.0, 1.0),
    ["down"]  = vec2(0.0, -1.0)
}

local finchMoveset = {
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
}

local fire = "space"

local bullet = [[
    WWWWW
    WWWWW
    WWWWW
    WWWWW
    WWWWW
]]

local playerBulletFactory = Projectile:newPlayerBulletFactory(bullet, math.rad(90), 700)

local primaryCooldown = 0.2

local lastprimaryFire = 0.0

local elapsed = 0.0

function update_players(scene, players)
    local fired = false
    for _, player in ipairs(players) do
        if elapsed > lastprimaryFire + primaryCooldown then
            playerBulletFactory:fire(scene, player.position)
            fired = true
        end
    end
    if fired then
        lastprimaryFire = elapsed
    end
end

function Game:new()
    local score = 0
    local wave = 1

    local finch = Character:new("finch", anima.te({
        file = "assets/sprite/red_angel.png",
        width = 128,
        height = 192,
        fps = 12.0
    }, idleAnimation), finchMoveset, vec2(-300, -250))
    local ava = Character:new("ava", anima.te({
        file = "assets/sprite/blue_angel.png",
        width = 128,
        height = 192,
        fps = 12.0
    }, idleAnimation), avaMoveset, vec2(300, -250))

    local game = am.group() ^ {
        bg.scrolling,
        Character:newNode(ava),
        Character:newNode(finch)
    }
    

    -- main game loop
    game:action(function(scene)
        elapsed = elapsed + am.delta_time
        update_players(scene, {ava, finch})
    end)

    return game
end