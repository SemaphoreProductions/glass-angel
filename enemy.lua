local Enemy = ...

local Projectile = require 'projectile'

function Enemy.shootAtPlayer() end

function Enemy.minion(sprite, position, rotation, behavior)
    local minion = {}

    function minion:spawn()
        print(position)
        return am.translate(position):action(behavior) 
        ^ am.rotate(rotation or 0) 
        ^ am.scale(5)
        ^ am.sprite(sprite)
    end

    return minion
end