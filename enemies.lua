local Enemies = ...

local anima = require 'anima'
local Enemy = require 'enemy'
local Projectile = require 'projectile'

function move_and_then(velocity, after)
    return am.parallel({function(enemy)
        enemy.position2d = enemy.position2d + velocity * am.delta_time
    end, after})
end

function repeat_every(secs, func)
    return coroutine.create(function(enemy)
        while true do
            am.wait(am.delay(secs))
            func(enemy)
        end
    end)
end

local eyeSprite = anima.te(
    {
        file = "assets/sprite/eye_sheet.png",
        width = 50,
        height = 57,
        fps = 4.0,
    },
    {
        { row = 1, col = 1 },
        { row = 1, col = 2 },
    }
)

local shooterSprite = am.scale(2) ^ anima.te(
    {
        file = "assets/sprite/demon_sheet.png",
        width = 39,
        height = 47,
        fps = 8.0,
    },
    {
        { row = 1, col = 1 },
        { row = 1, col = 2 },
        { row = 1, col = 3 },
        { row = 1, col = 4 },
        { row = 1, col = 5 },
        { row = 1, col = 6 },
        { row = 1, col = 7 },
        { row = 1, col = 8 },
    }
)

local harpSprite = anima.te(
    {
        file = "assets/sprite/harp_sheet.png",
        width = 129,
        height = 143,
        fps = 4.0,
    },
    {
        { row = 1, col = 1 },
        { row = 1, col = 2 },
        { row = 1, col = 3 },
        { row = 1, col = 4 },
        { row = 1, col = 5 },
        { row = 1, col = 6 },
    }
)

local bigEyeSprite = anima.te(
    {
        file = "assets/sprite/bigeyeball_sheet.png",
        width = 39,
        height = 47,
        fps = 4.0,
    },
    {
        { row = 1, col = 1 },
        { row = 1, col = 2 },
        { row = 1, col = 3 },
        { row = 1, col = 4 },
        { row = 1, col = 5 },
        { row = 1, col = 6 },
        { row = 1, col = 7 },
        { row = 1, col = 8 },
    }
)

local bossSprite = anima.te(
    {
        file = "assets/sprite/boss_sheet.png",
        width = 315,
        height = 313,
        fps = 6.0,
    },
    {
        { row = 1, col = 1 },
        { row = 1, col = 2 },
        { row = 1, col = 3 },
        { row = 1, col = 4 },
        { row = 1, col = 5 },
        { row = 1, col = 6 },
        { row = 1, col = 7 },
        { row = 1, col = 8 },
    }
)


local shooter_bullet = "assets/sprite/shooter_bullet.png"

zoomer = function(scene, xfunc, vel) local time = am.frame_time return Enemy.minion(scene, eyeSprite, 30, nil, move_and_then(vel or vec2(0, -600), function(enemy)
    if xfunc ~= nil then
        enemy.position2d = enemy.position2d{ x = xfunc(time)}
    end
end, 2, 20)) end

shooter = function(scene, xvel)
    local factory = Projectile:newMultishotBulletFactory(scene"enemy-curtain", shooter_bullet, {-10, -5, 0, 5, 10}, 400)
    return Enemy.minion(scene, shooterSprite, 50, nil, move_and_then(vec2(xvel, -200), repeat_every(2, function(enemy)
        factory:fire(scene, enemy.position2d)
    end)), 6, 200) end

harp = function(scene, xfunc)
    local pattern = {}
    for i=-180,180,10 do
        table.insert(pattern, i)
    end
    local factory = Projectile:newMultishotBulletFactory(scene"enemy-curtain", shooter_bullet, pattern, 300)
    return Enemy.minion(scene, harpSprite, 100, nil, move_and_then(vec2(0, -200), repeat_every(2, function(enemy)
        if xfunc ~= nil then
            enemy.position2d = enemy.position2d{ x = xfunc(time)}
        end
        factory:fire(scene, enemy.position2d)
    end)), 10, 500)
end