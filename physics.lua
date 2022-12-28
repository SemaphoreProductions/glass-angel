local Physics = ...

local splash = require "lib/splash"

Physics.world = nil

-- A container for a Splash world that is tied to the lifetime of a scene Graph
function Physics.newWorld(cellSize)
    local world = splash.new(cellSize)
    Physics.world = world
    local physicsNode = am.group():tag"physics"
    function physicsNode:get_world()
        return world
    end
    return physicsNode
end

function Physics.removeObject(object, parent)
    parent:remove(object)
    Physics.world:remove(object)
end

function Physics.queryCollidable(shape)
    return Physics.world:queryShape(shape)
end

function Physics.queryCollidableWithTag(shape, tag)
    local items = Physics.queryCollidable(shape)
    for _, item in ipairs(items) do
        if #item:all(tag, false) > 0 then
            return item
        end
    end
    return nil
end