local Reader = ...

local bg = require 'bg'


function Reader:new(script)
    local reader = {
        script = script,
        item = 1,
        scene = 1,
    }
    setmetatable(reader, self)
    self.__index = self
    return reader
end

function Reader:init_stage(scene)
    local music = self.script[self.item].bgmusic
    local background = self.script[self.item].bg
    local loop = self.script[self.item].musicloop ~= false
    if music ~= nil then
        scene.track = am.track(music, loop, 1, VOLUME)
        scene:action("music", am.play(scene.track))
    end
    if background ~= nil then
        bg.set_texture(scene, background)
    end
end

function Reader:update(scene)
    if scene("continue") ~= nil then
        local current_scene = self.script[self.item].scenes[self.scene]
        scene:remove("continue")
        scene:action("script", current_scene)
        if self.scene == 1 then
            self:init_stage(scene)
        end
        if #self.script[self.item].scenes < self.scene + 1 then
            self.item = self.item + 1 
            self.scene = 1
        else
            self.scene = self.scene + 1
        end
    end
end