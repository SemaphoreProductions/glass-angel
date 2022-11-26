local Enemy = ...

local Projectile = require 'projectile'

function Enemy.shootAtPlayer() end

function Enemy.minion(sprite, rotation, behavior)
    local minion = {}

    function minion:spawn_top(x)
        local position = vec2(x, screenEdge.y + 100)
        return am.translate(position)
        :action(behavior)
        :tag"enemy" 
        ^ am.rotate(rotation or 0) 
        ^ am.scale(5)
        ^ am.sprite(sprite)
    end

    return minion
end

function check_bounds(center, size, target)
    return target.x < center.x + size.x/2 and target.x > center.x - size.x/2 and target.y < center.y + size.y/2 and target.y > center.y - size.y/2
end

--- AAAA stupid local transforms make everything miserable
function Enemy.dieOnHit(theater, curtain)
    for _, enemy in ipairs(theater:all"enemy") do
        if enemy.position2d.y < screenEdge.y then
                    -- Check for collision
        -- Ouch, O(n^2) is the best we can do?
        for _, bullet in ipairs(curtain:all"playerBullet") do
            -- Check translation
            -- find a better way to get enemy size
            if check_bounds(bullet.position2d, vec2(55, 55), enemy.position2d) then
                -- kaboom!
                theater:remove(enemy)
                curtain:remove(bullet)
            end
        end
        end
    end
end