local Character = ...

local Projectile = require 'projectile'

local SPEED = 600
local RADIUS = 2

local bullet = "assets/sprite/angel_bullet.png"

local playerBulletFactory = function(curtain) return Projectile:newBulletFactory(curtain, bullet, 90, 1400, false, "playerBullet") end


function Character:new(option)
    local character = am.translate(option.position2d or vec2(0.0)):tag(option.name) ^ option.sprite
    for k,v in pairs({
        name = option.name,
        sprite = option.sprite,
        radius = RADIUS,
        moveset = option.moveset,
        speed = SPEED,
        velocity = vec2(0.0),
        invuln = false,
        bcenter = option.bcenter,
        bsize = option.bsize,
        shouldFire = false,
        readyToFire = true,
        awaiting = false,
        factory = playerBulletFactory(option.curtain)
    }) do character[k] = v end

    function character:handleInput()
        character.velocity = vec2(0.0)
        for _, key in ipairs(globalWindow:keys_down()) do
            if character.moveset[key] ~= nil then
                character.velocity = character.velocity + character.moveset[key]
            end
        end
        character.velocity = character.velocity * character.speed
    end
    
    character:action(function (node)
        character:handleInput()
        -- Handle velocity
        local newPos = character.position2d + character.velocity * am.delta_time
        if check_bounds(character.bcenter, character.bsize, newPos) then
            character.position2d = newPos     
        end
    end)

    return character
end