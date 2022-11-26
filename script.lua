local Enemy = require 'enemy'
local Projectile = require 'projectile'

local minion = [[
...r.r.r...
.rrrrrrrrr.
.rRrrrrrRr.
rrrrMMMrrrr
.rrMMmMMrr.
rrrMmmmMrrr
.rrMMmMMrr.
rrrrMMMrrrr
.rRrrrrrRr.
.rrrrrrrrr.
...r.r.r...
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

local minionBulletFactory = Projectile:newPlayerBulletFactory("assets/sprite/angel_bullet.png", math.rad(270), 600)

local zoomer = function(scene) local time = am.frame_time return Enemy.minion(minion, nil, move_and_then(vec2(0, -600), function(enemy)
    --minionBulletFactory:fire(scene"enemy-curtain", enemy.position2d)
    enemy.position2d = enemy.position2d{ x = math.sin(am.frame_time + time) * screenEdge.x / 2}
end)) end

local function display_title(scene, text)
    local FONT = 50
    scene:append(am.text(fonts.annapurnaBoldLarge, text):tag"title")
end

local function fade_title(scene, fade_time)
    local title = scene"title"
    return am.tween(title, fade_time, {
            color = vec4(title.color.x, title.color.y, title.color.z, 0)
        }
    )
end

-- The complete script to the game - cutscenes, enemy waves, and boss fights
return {
    -- Stage 1
    {
        bgmusic = "audio/shockandawe.ogg",
        scenes = {
            coroutine.create(function(scene)
                display_title(scene, "Welcome to Hell!")
                am.wait(am.delay(1))
                am.wait(fade_title(scene, 1))
                scene:append(am:group():tag"continue")
            end),
            coroutine.create(function(scene)
                while true do
                    scene"enemies":append(zoomer(scene):spawn_top(math.sin(am.frame_time * 5) * 100))
                    am.wait(am.delay(0.5))
                end
            end)
        }
    },
    {
        scenes = {}
    }
}