local Projectile = ...



function Projectile:shootAt(me, other, speed)
    local velocity = normalize(vec2(me, other)) * speed
    return function(node)
        node.position2d = node.position2d + am.delta_time * velocity
    end
end

function Projectile:newBullet(sprite, position, rotation, behavior, tagname)
    return am.translate(position):tag(tagname):action(behavior) ^ am.rotate(rotation) ^ am.sprite(sprite)
end

function Projectile:newPlayerBulletFactory(sprite, angle, speed, tagname)
    local tagname = tagname or "bullet"
    local factory = {}
    local velocity = vec2(math.cos(angle), math.sin(angle)) * speed
    function factory:fire(scene, position)
        scene:append(Projectile:newBullet(sprite, position, angle, function(node)
            if node.position2d.x > screenEdge.x*2 or node.position2d.x < -screenEdge.x*2
                or node.position2d.y > screenEdge.y*2 or node.position2d.y < -screenEdge.y*2 then
                scene:remove(node)
            end
            node.position2d = node.position2d + am.delta_time * velocity
        end, tagname))
    end
    
    return factory
end