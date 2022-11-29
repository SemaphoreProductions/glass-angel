local Reader = ...


function Reader.new(script)
    local reader = {
        script = script,
        item = 1,
        scene = 1,
    }
    
    function reader:update(scene)
        if scene("continue") ~= nil then
            local current_scene = script[reader.item].scenes[reader.scene]
            scene:remove("continue")
            scene:action("script", current_scene)
            if #reader.script[reader.item].scenes < reader.scene + 1 then
                reader.item = reader.item + 1 
            else
                reader.scene = reader.scene + 1
            end
        end
    end

    return reader
end