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

local finchMoveset = {
    ["left"]  = vec2(-1.0, 0.0),
    ["right"] = vec2(1.0, 0.0),
    ["up"]    = vec2(0.0, 1.0),
    ["down"]  = vec2(0.0, -1.0)
}

local avaMoveset = {
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

local bulletCooldown = 0.05

local invulnTime = 1.0

local hurt = am.sfxr_synth(20560004)
local dead = am.sfxr_synth(50323902)

function update_players(scene, players)
    local curtain = scene"bullet-curtain"
    local enemy_curtain = scene"enemy-curtain"
    for _, player in ipairs(players) do
        if not player.shouldFire then
        elseif not player.readyToFire and not player.awaiting then
            player.awaiting = true
            scene:action(player.name .. "_cooldown", coroutine.create(function(node)
                am.wait(am.delay(bulletCooldown))
                player.readyToFire = true
                player.awaiting = false
            end))
        elseif not player.awaiting then
            player.factory:fire(scene, player.position)
            player.readyToFire = false
        end
        -- check for collisions
        for _, bullet in enemy_curtain:child_pairs() do
              if not player.invuln and check_bounds(bullet.position2d, vec2(5, 5), player.position) then
                if player.life > 0 then
                    scene:action(am.play(hurt))
                    enemy_curtain:remove(bullet)
                       player.life = player.life - 1
                       player.invuln = true
                      print(scene(player.name))
                      scene(player.name):action(coroutine.create(function()
                           am.wait(am.delay(invulnTime))
                           print("vulnerable")
                           player.invuln = false
                       end))
                else
                    scene:action(am.play(dead))
                    player.dead = true
                    -- kaboom!
                    enemy_curtain:remove(bullet)
                    scene:remove(player.name)
                    player.shouldFire = false
                    table.remove_all(players, player)
                   end
             end
        end
    end
end

local function build_hud()
    
    return am:group():tag"hud" ^ {
        am.translate(-screenEdge.x, screenEdge.y) ^ am.scale(3) ^ am.text("AVA: 2", "left", "top"):action(function(node) node.text = "AVA: " .. ava.life end),
        am.translate(screenEdge.x, screenEdge.y) ^ am.scale(3) ^ am.text("FINCH: 2", "right", "top"):action(function(node) node.text = "FINCH: " .. finch.life end),
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

    local game = am.group() ^ {
        bg.scrolling,
        am.group():tag"theater" ^ {
            am.group():tag("enemy-curtain"),
            am.group():tag("bullet-curtain"),
            am.group():tag("enemies"),
            am.group():tag"continue",
        }
    }

    ava = Character:new("ava", anima.te({
        file = "assets/sprite/ava.png",
        width = 104 / 2,
        height = 82,
        fps = 2.0
    }, idleAnimation), avaMoveset, vec2(-300, -250), vec2(-screenEdge.x / 2, 0), screenEdge{ y = screenEdge.y * 2}, game"bullet-curtain")
    finch = Character:new("finch", anima.te({
        file = "assets/sprite/finch.png",
        width = 104 / 2,
        height = 82,
        fps = 2.0
    }, idleAnimation), finchMoveset, vec2(300, -250), vec2(screenEdge.x / 2, 0), screenEdge{ y = screenEdge.y * 2}, game"bullet-curtain")

    game:append(Character:newNode(ava))
    game:append(Character:newNode(finch))
    game:append(am.group():tag"dialoguearea")
    game:append(build_hud())

    -- main game loop
    game:action(am.parallel({am.play(audio.stage1, true, nil, VOLUME), function(scene)
        update_players(scene, {ava, finch})
        reader:update(scene)
    end}))

    return game
end