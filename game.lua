local Game = ...
local Character = require 'character'
local bg = require 'bg'
local anima = require 'anima'
local Projectile = require 'projectile'
local script = require 'script'
local Reader = require 'reader'
local audio = require 'audio'
local Enemy = require 'enemy'

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
    { row = 1, col = 1 },
    { row = 1, col = 2 },
}

local fire = "space"

local bullet = "assets/sprite/angel_bullet.png"

local playerBulletFactory = Projectile:newBulletFactory(bullet, 90, 700, false, "playerBullet")

local bulletCooldown = 0.2

function update_players(scene, players)
    local curtain = scene"bullet-curtain"
    for _, player in ipairs(players) do
        if not player.shouldFire then
            x = 1
        elseif not player.readyToFire and not player.awaiting then
            player.awaiting = true
            scene:action(player.name .. "_cooldown", coroutine.create(function(node)
                am.wait(am.delay(bulletCooldown))
                player.readyToFire = true
                player.awaiting = false
            end))
        elseif not player.awaiting then
            playerBulletFactory:fire(curtain, player.position)
            player.readyToFire = false
        end
    end
end

local function build_hud()
    
    return am:group():tag"hud" ^ {
        am.translate(-screenEdge.x, screenEdge.y) ^ am.scale(3) ^ am.text("ADA: 2", "left", "top"),
        am.translate(screenEdge.x, screenEdge.y) ^ am.scale(3) ^ am.text("FINCH: 2", "right", "top"),
        am.translate(0, screenEdge.y) ^ {
            am.scale(3) ^ am.text("SCORE", "center", "top"),
            am.translate(0, -16 * 3 - 8) ^ am.scale(3) ^ am.text(Score, "center", "top"):action(function(node) node.text = Score end)
        }
    }
end


function Game:new()
    Score = 0
    local wave = 1

    local reader = Reader.new(script)

    finch = Character:new("finch", anima.te({
        file = "assets/sprite/finch.png",
        width = 104 / 2,
        height = 82,
        fps = 2.0
    }, idleAnimation), finchMoveset, vec2(-300, -250), vec2(-screenEdge.x / 2, 0), screenEdge{ y = screenEdge.y * 2})
    ava = Character:new("ava", anima.te({
        file = "assets/sprite/ava.png",
        width = 104 / 2,
        height = 82,
        fps = 2.0
    }, idleAnimation), avaMoveset, vec2(300, -250), vec2(screenEdge.x / 2, 0), screenEdge{ y = screenEdge.y * 2})

    local game = am.group() ^ {
        bg.scrolling,
        am.group():tag"theater" ^ {
            am.group():tag("enemy-curtain"),
            am.group():tag("bullet-curtain"),
            am.group():tag("enemies"),
            am.group():tag"continue",
        },
        Character:newNode(ava),
        Character:newNode(finch),
        am.group():tag"dialoguearea",
        build_hud()
    }
    

    -- main game loop
    game:action(am.parallel({am.play(audio.stage1, true, nil, VOLUME), function(scene)
        update_players(scene, {ava, finch})
        reader:update(scene)
    end}))

    return game
end