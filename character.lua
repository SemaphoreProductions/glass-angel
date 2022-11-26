local Character = ...

local SPEED = 600
local RADIUS = 2


function Character:new(name, sprite, moveset, position, bcenter, bsize)
    local character = {
        name = name,
        sprite = sprite,
        radius = RADIUS,
        moveset = moveset,
        speed = SPEED,
        position = position or vec2(0.0, 0.0),
        velocity = vec2(0.0, 0.0),
        dead = false,
        bcenter = bcenter,
        bsize = bsize
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
    local player = am.translate(character.position) ^ character.sprite
    
    player:action(function (node)
        character:handleInput()
        -- Handle velocity
        local newPos = character.position + character.velocity * am.delta_time
        if check_bounds(character.bcenter, character.bsize, newPos) then
            character.position = newPos     
        end
        local translate = node"translate"
        translate.position2d = character.position
    end)

    return player
end