local Reader = ...

local bg = require 'bg'


function Reader.new(script)
    local reader = {
        script = script,
        item = 1,
        scene = 1,
    }

    function reader:init_stage(scene)
        local music = reader.script[reader.item].bgmusic
        local background = reader.script[reader.item].bg
        local loop = reader.script[reader.item].musicloop ~= false
        if music ~= nil then
            scene.track = am.track(music, loop, 1, VOLUME)
            scene:action("music", am.play(scene.track))
        end
        if background ~= nil then
            print(background)
            bg.set_texture(scene, background)
        end
    end
    
    function reader:update(scene)
        if scene("continue") ~= nil then
            local current_scene = script[reader.item].scenes[reader.scene]
            scene:remove("continue")
            scene:action("script", current_scene)
            if reader.scene == 1 then
                reader:init_stage(scene)
            end
            if #reader.script[reader.item].scenes < reader.scene + 1 then
                reader.item = reader.item + 1 
                reader.scene = 1
            else
                reader.scene = reader.scene + 1
            end
        end
    end

    return reader
end