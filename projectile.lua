local Projectile = ...

function Bullet:new(sprite, position, behavior)
    return am.translate(position):tag("bullet"):action(behavior) ^ am.sprite(sprite)
end


function BulletFactory:new(sprite, position)
    local projectile = am.translate()

    function projectile:spawn(scene)

    end

    function projectile:fire(scene, pattern, behavior)
        for _, instance in pattern do
            scene:append(Bullet:new(sprite, position - instance.position or vec2(0., 0.), behavior))
        end
    end
end