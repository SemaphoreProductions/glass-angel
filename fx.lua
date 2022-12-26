local Fx = ...

function Fx.pulse_explosion(position, start_radius, end_radius, duration, ratio, c1, c2, blend)
    local blend = blend or "subtract"
    local c1 = c1 or vec4(201. / 255., 47. / 255., 20. /255., 1.0)
    local c2 = c2 or c1 / 1.6
    local ratio = ratio or 0.5
    return am.blend(blend) ^ {
        am.circle(position, start_radius, c2):action(coroutine.create(function(c)
            am.wait(am.tween(c, duration / 4, { radius = end_radius}, am.ease.hyperbola))
            am.wait(am.tween(c, duration * 3 / 4, { color = c.color{a = 0.}}, am.ease.linear))
        end)),
        am.circle(position, start_radius * ratio, c1):action(coroutine.create(function(c)
            am.wait(am.tween(c, duration / 4, { radius = end_radius * ratio }, am.ease.hyperbola))
            am.wait(am.tween(c, duration * 3 / 4, { color = c.color{a = 0.}}, am.ease.cubic))
        end))
    }
end