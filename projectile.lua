local Projectile = ...



function Projectile:shootAt(me, other, speed)
    local velocity = normalize(vec2(me, other)) * speed
    return function(node)
        node.position2d = node.position2d + am.delta_time * velocity
    end
end

function Projectile:newBullet(sprite, position, behavior)
    return am.translate(position):tag("bullet"):action(behavior) ^ am.sprite(sprite)
end


function Projectile:newBulletFactory(sprite)
    local factory = {}
    function factory:fire(scene, position, pattern, behavior)
        for _, instance in pattern do
            scene:append(Projectile:newBullet(sprite, position - instance.position or vec2(0., 0.), behavior))
        end
    end
    return factory
end

function Projectile:newPlayerBulletFactory(sprite, angle, speed)
    local factory = {}
    local velocity = vec2(math.cos(angle), math.sin(angle)) * speed
    function factory:fire(scene, position)
        scene:append(Projectile:newBullet(sprite, position, function(node)
            if node.position2d.x > screenEdge.x or node.position2d.x < -screenEdge.x
                or node.position2d.y > screenEdge.y or node.position2d.y < -screenEdge.y then
                scene:remove(node)
            end
            node.position2d = node.position2d + am.delta_time * velocity
        end))
    end
    
    return factory
end