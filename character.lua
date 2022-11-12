local Character = ...

local SPEED = 10


function Character:new(name, sprite, moveset)
    local character = {
        name = name,
        sprite = sprite,
        moveset = moveset,
        speed = SPEED,
        position = vec2(),
        velocity = vec2()
    }

    function character:handleInput(window)
        for key in window:keys_down() do
            if moveset[key] ~= nil then
                velocity = velocity + speed * moveset[key]
            end
        end
    end

    return character
end

function Character:newNode(character)
    local player = am.group(
        am.translate(character.position) ^ am.sprite(character.sprite)
    )
    
    player:action(function (node, dt)
        -- Handle velocity
        character.position = character.position + character.velocity * dt
        local translate = node:child_pairs()[1][2]
        translate.position2d = character.position
    end)

    return player
end