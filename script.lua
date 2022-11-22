local Enemy = require 'enemy'
local Projectile = require 'projectile'

local minion = [[
    RRRRRRR
    RRRRRRR
    RRRRRRR
    RRRRRRR
    RRRRRRR
    RRRRRRR
    RRRRRRR
]]

local function move_and_then(velocity, after)
    return am.parallel({function(enemy)
        enemy.position2d = enemy.position2d + velocity * am.delta_time
    end, after})
end

local function repeat_every(secs, func)
    return coroutine.create(function(enemy)
        while true do
            func(enemy)
            am.wait(am.delay(secs))
        end
    end)
end

local minionBulletFactory = Projectile:newPlayerBulletFactory("assets/sprite/angel_bullet.png", math.rad(270), 300)

local minion = Enemy.minion(minion, vec2(0, screenEdge), nil, move_and_then(vec2(0, -100), repeat_every(1, function(enemy)
    minionBulletFactory:fire(enemy, vec2(0, 0))
end)))

-- The complete script to the game - cutscenes, enemy waves, and boss fights
return {
    -- Stage 1
    {
        name = "Welcome to Hell",
        bgmusic = "audio/shockandawe.ogg",
        scenes = {
            coroutine.create(function(scene)
                am.wait(am.delay(1))
                scene:append(minion.spawn())
            end)
        }
    },
    {
        scenes = {}
    }
}