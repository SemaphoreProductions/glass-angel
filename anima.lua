local anima = ...

function anima.tween(node, time, values, ease)
    local ease = am.ease.linear
    node:append(am.group():action(am.tween(node, time, values, ease))):tag("tween")
end

function anima.te(spritesheet, frames)
    local texture = am.texture2d(spritesheet.file)
    local width, height = spritesheet.width, spritesheet.height

    local sprites = {}

    local animlength = 0

    for i, frames in ipairs(frames) do
        if i > animlength then
            animlength = i
        end
        table.insert(sprites, am.sprite({
            texture = texture,

        }))
    end

    local node = am:group()

    node.tick = 0
    
    return am:group():action(function(node)
        
    end)
end