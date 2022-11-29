local Projectile = ...

local Enemy = require 'enemy'



function Projectile:shootAt(me, other, speed)
    local velocity = normalize(vec2(me, other)) * speed
    return function(node)
        node.position2d = node.position2d + am.delta_time * velocity
    end
end

function Projectile:newBullet(sprite, position, rotation, behavior, tagname)
    return am.translate(position)
    :tag(tagname)
    :action(behavior) 
    ^ am.rotate(rotation) 
    ^ am.sprite(sprite)
end

function Projectile:newBulletFactory(curtain, sprite, angle, speed, shootPlayer, tagname)
    local tagname = tagname or "bullet"
    local shootPlayer = (shootPlayer ~= false)
    local factory = {}
    function factory:fire(scene, position)
        local shootAngle = math.rad(angle)
        if shootPlayer then
            shootAngle = shootAngle + Enemy.shootAtPlayer(scene, position)
        end
        local velocity = vec2(math.cos(shootAngle), math.sin(shootAngle)) * speed
        curtain:append(Projectile:newBullet(sprite, position, shootAngle, function(node)
            if node.position2d.x > screenEdge.x*2 or node.position2d.x < -screenEdge.x*2
                or node.position2d.y > screenEdge.y*2 or node.position2d.y < -screenEdge.y*2 then
                scene:remove(node)
            end
            node.position2d = node.position2d + am.delta_time * velocity
        end, tagname))
    end
    
    return factory
end

function Projectile:newMultishotBulletFactory(curtain, sprite, angles, speed, shootPlayer, tagname)
    local tagname = tagname or "bullet"
    local shootPlayer = (shootPlayer ~= false)
    local factory = {}
    function factory:fire(scene, position)
        for _, angle in ipairs(angles) do
            local shootAngle = math.rad(angle)
            if shootPlayer then
                shootAngle = shootAngle + Enemy.shootAtPlayer(scene, position)
            end
            local velocity = speed * vec2(math.cos(shootAngle), math.sin(shootAngle))
            curtain:append(Projectile:newBullet(sprite, position, shootAngle, function(node)
                if node.position2d.x > screenEdge.x*2 or node.position2d.x < -screenEdge.x*2
                    or node.position2d.y > screenEdge.y*2 or node.position2d.y < -screenEdge.y*2 then
                    scene:remove(node)
                end
                node.position2d = node.position2d + am.delta_time * velocity
            end, tagname))
        end
    end
    
    return factory
end