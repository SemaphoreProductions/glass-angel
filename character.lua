local Character = ...

local Projectile = require 'projectile'

local SPEED = 600
local RADIUS = 2

local bullet = "assets/sprite/angel_bullet.png"

local playerBulletFactory = function(curtain) return Projectile:newBulletFactory(curtain, bullet, 90, 700, false, "playerBullet") end


function Character:new(name, sprite, moveset, position, bcenter, bsize, curtain)
    local character = {
        name = name,
        sprite = sprite,
        radius = RADIUS,
        moveset = moveset,
        speed = SPEED,
        position = position or vec2(0.0, 0.0),
        velocity = vec2(0.0, 0.0),
        dead = false,
        life = 2,
        invuln = false,
        bcenter = bcenter,
        bsize = bsize,
        shouldFire = false,
        readyToFire = true,
        awaiting = false,
        factory = playerBulletFactory(curtain)
    }

    function character:handleInput()
        character.velocity = vec2(0.0, 0.0)
        for _, key in ipairs(globalWindow:keys_down()) do
            if character.moveset[key] ~= nil then
                character.velocity = character.velocity + character.moveset[key]
            end
        end
        character.velocity = character.velocity * character.speed
    end

    return character
end

function Character:newNode(character)
    local player = am.translate(character.position):tag(character.name) ^ character.sprite
    
    player:action(function (node)
        character:handleInput()
        -- Handle velocity
        local newPos = character.position + character.velocity * am.delta_time
        if check_bounds(character.bcenter, character.bsize, newPos) then
            character.position = newPos     
        end
        local translate = node"translate"
        translate.position2d = character.position
    end)

    return player
end