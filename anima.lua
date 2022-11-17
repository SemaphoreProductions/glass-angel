local anima = ...

function anima.tween(node, time, values, ease)
    local ease = am.ease.linear
    node:append(am.group():action(am.tween(node, time, values, ease))):tag("tween")
end

function anima.te(spritesheet, frames)
    local texture = am.texture2d(spritesheet.file)
    local width, height = spritesheet.width, spritesheet.height
    local fps = spritesheet.fps

    local sprites = {}
    local sequence = {}

    local animlength = 1

    for i, frame in pairs(frames) do
        if i > animlength then
            animlength = i
        end
        if frame ~= nil then
            local x2 = (frame.col) * width
            local x1 = x2 - width
            local y2 = frame.row * height
            local y1 = y2 - height
            table.insert(sprites, am.sprite({
                texture = texture,
                s1 = x1 / texture.width,
                s2 = x2 / texture.width,
                t1 = y1 / texture.height,
                t2 = y2 / texture.height,
                x1 = 0,
                x2 = width,
                y1 = 0,
                y2 = height,
                width = width,
                height = height,
            }))
            table.insert(sequence, { at = i, sprite = sprites[#sprites] })
        end
    end

    local anim = am.scale(vec2(1., 1.)):action(function(node)
        node.elapsed = node.elapsed + am.delta_time
        local frame = math.floor(node.elapsed * fps) % animlength
        local sprite = nil
        for _, seq in ipairs(sequence) do
            if frame <= seq.at then
                sprite = seq.sprite
                break
            end
        end
        if sprite ~= nil then
            node:remove_all()
            node:append(sprite)
        end
    end)

    anim.elapsed = 0.0
    
    return anim
end