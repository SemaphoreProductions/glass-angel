local anima = ...

function anima.tween(node, time, values, ease)
    local ease = am.ease.linear
    node:append(am.group():action(am.tween(node, time, values, ease))):tag("tween")
end