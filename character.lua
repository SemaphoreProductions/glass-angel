local Character = ...

local SPEED = 10


function Character:new(name, sprite, moveset, position)
    local character = {
        name = name,
        sprite = sprite,
        moveset = moveset,
        speed = SPEED,
        position = position or vec2(0.0, 0.0),
        velocity = vec2(0.0, 0.0)
    }

    function character:handleInput()
        character.velocity = vec2(0.0, 0.0)
        for _, key in ipairs(globalWindow:keys_down()) do
            if character.moveset[key] ~= nil then
                character.velocity = character.velocity + character.moveset[key]
            end
        end
        character.velocity = character.velocity * character.speed
    end

    return character
end

function Character:newNode(character)
    local player = am.group(
        am.translate(character.position) ^ am.sprite(character.sprite)
    )
    
    player:action(function (node)
        character:handleInput()
        -- Handle velocity
        character.position = character.position + character.velocity * am.delta_time        
        local translate = node:child(1)
        translate.position2d = character.position
    end)

    return player
end