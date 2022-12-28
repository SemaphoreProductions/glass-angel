local Enemy = ...

local Projectile = require 'projectile'
local Fx = require 'fx'
local Physics = require 'physics'
local splash = require 'lib/splash'

function Enemy.shootAtPlayer(scene, position) 
    -- shoot at player on our side of the screen
    local player
    if position.x > 0 and scene"ava" ~= nil then
        -- Shoot at ava
        player = scene"ava"
    else
        -- Shoot at finch
        player = scene"finch"
    end
    -- calc relative vector
    local rel = player.position2d - position
    local angle = math.atan2(rel.y, rel.x)
    return angle
end

local hurt = am.sfxr_synth(20560004)
local dead = am.sfxr_synth(50323902)

function Enemy.new(scene, sprite, radius, rotation, behavior, health, score, invulnTime)
    health = health or 1
    score = score or 50
    invulnTime = invulnTime or 0.1

    local enemy = am.translate(0.0, 0.0):action(
        am.parallel{
            behavior,
            Enemy.dieOnHit(scene"enemies", scene"enemy-curtain", scene"bullet-curtain", radius, health),
            function(enemy)
                if enemy.position2d.y < -screenEdge.y + 50 then
                    Physics.removeObject(enemy, scene"enemies") -- silent garbage disposal
                end
            end,
            function(enemy)
                if Physics.world.shapes[enemy] == nil then
                    return
                end
                Physics.world:update(enemy, enemy.position2d.x, enemy.position2d.y)
            end
        }
    ):tag"enemy":tag"enemyCollidable" ^ am.rotate(rotation or 0) ^ sprite

    function enemy:get_score()
        return score
    end

    function enemy:get_radius()
        return radius
    end

    function enemy:spawn_at(x, y)
        enemy.position2d = vec2(x, y)
        return enemy
    end

    function enemy:spawn_top(x)
        return enemy:spawn_at(x, screenEdge.y + 100)
    end

    function enemy:die(theater)
        print(enemy)
        theater:action(am.play(dead))
        -- Update player score
        Score = Score + enemy.score
        -- todo: bullet effect on hit
        Enemy.explode(enemy, theater)
    end

    local enemyShape = splash.circle(enemy.position2d.x, enemy.position2d.y, radius)

    Physics.world:add(enemy, enemyShape)

    return enemy
end

function check_bounds(center, size, target)
    return target.x <= center.x + size.x/2
       and target.x >= center.x - size.x/2
       and target.y <= center.y + size.y/2
       and target.y >= center.y - size.y/2
end

--- AAAA stupid local transforms make everything miserable
function Enemy.dieOnHit(theater, enemyCurtain, curtain, radius, health)
    return function(enemy)
        if invuln or enemy.position2d.y + 30 > screenEdge.y then
            return
        end
        -- Check translation
        -- find a better way to get enemy size
        local bullet = Physics.queryCollidableWithTag(splash.circle(enemy.position2d.x, enemy.position2d.y, radius), "playerBullet")
        if bullet then
            bullet:die(theater)
            if health > 1 then
                theater:action(am.play(hurt))
                health = health - 1
            else
                enemy:die(theater)
            end
        end
    end
end

local function death(enemy, duration)
    local duration = duration or 0.4
    local effect = Fx.pulse_explosion(enemy.position2d, 3, 100, duration)
    effect.duration = duration
    return effect
end

-- Deletes `enemy` from the `theater` and replaces it
-- with a temporary death effect
function Enemy.explode(enemy, theater)
    Physics.removeObject(enemy, theater)
    local death_effect = death(enemy)
    -- put the effect at the lowest layer possible in `theater`
    theater:prepend(death_effect)
    theater:action(coroutine.create(function() 
        am.wait(am.delay(death_effect.duration))
        theater:remove(death_effect) 
    end))
end
