local Enemy = ...

local Projectile = require 'projectile'

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

function Enemy.new(scene, sprite, radius, rotation, behavior, health, score, invulnTime)
    health = health or 1
    score = score or 50
    invulnTime = invulnTime or 0.1

    local invuln = false

    local enemy = am.translate(0.0, 0.0):action(
        am.parallel{
            behavior,
            Enemy.dieOnHit(scene"enemies", scene"bullet-curtain", health, invuln, invulnTime),
            function(enemy)
                if enemy.position2d.y < -screenEdge.y + 50 then
                    scene"enemies":remove(enemy) -- silent garbage disposal
                end
            end
        }
    ):tag"enemy" ^ am.rotate(rotation or 0) ^ sprite

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

    return enemy
end

function check_bounds(center, size, target)
    return target.x <= center.x + size.x/2
       and target.x >= center.x - size.x/2
       and target.y <= center.y + size.y/2
       and target.y >= center.y - size.y/2
end

local hurt = am.sfxr_synth(20560004)
local dead = am.sfxr_synth(50323902)

--- AAAA stupid local transforms make everything miserable
function Enemy.dieOnHit(theater, curtain, health, invuln, invulnTime)
    return function(enemy)
        if invuln or enemy.position2d.y + 30 > screenEdge.y then
            return
        end
        -- Check for collision
        -- ugh this is not efficient (O(n^2))
        for _, bullet in ipairs(curtain:all"playerBullet") do
            -- Check translation
            -- find a better way to get enemy size
            if check_bounds(bullet.position2d, vec2(55, 55), enemy.position2d) then
                if health > 1 then
                    theater:action(am.play(hurt))
                    curtain:remove(bullet)
                    health = health - 1
                    invuln = true
                    local old_sprite = enemy"sprite"
                    --enemy:replace("sprite", hit)
                    enemy:action(coroutine.create(function()
                        am.wait(am.delay(invulnTime))
                        --enemy:replace("sprite", old_sprite)
                        invuln = false
                    end))
                else
                    theater:action(am.play(dead))
                    Score = Score + enemy.score
                    -- kaboom!
                    theater:remove(enemy)
                    curtain:remove(bullet)
                end
            end
        end
    end
end
