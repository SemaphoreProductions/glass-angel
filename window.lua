local Window = ...

local aspectRatio = vec2(1024, 1024)

screenEdge = aspectRatio / 2


function Window:new()
    return am.window{
        title = "Glass Angel",
        width = aspectRatio.x,
        height = aspectRatio.y,
        mode = "windowed",
        clear_color = vec4(0.04, 0.04, 0.04, 1),
        highdpi = true,
        msaa_samples = 4,
    }
end
