local Menu = ...

local anima = require("anima")

local audio = require("audio")

local textHeight = 64

local function __NULL__() end

local textColor = vec4(0.5, 0.5, 0.5, 1)
local highlightedTextColor = vec4(1, 1, 1, 1)

function text_node(text, halign, valign)
    return am.text(fonts.annapurnaRegular, text, textColor, halign, valign)
end

function yantiq(text, halign, valign)
    return am.text(fonts.yantiq, text, textColor, halign, valign)
end

function yantiqLarge(text, halign, valign)
    return am.text(fonts.yantiqLarge, text, highlightedTextColor, halign, valign)
end

function ned(text, halign, valign)
    return am.text(fonts.ned, text, highlightedTextColor, halign, valign)
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end
 

-- Menu UI
function button(text, offset, action)
    local buttonAction = action or __NULL__
    local uppercenter = vec2(0, -screenEdge.y / 5 * (offset or 0))
    return am.translate(uppercenter.x, uppercenter.y) ^ yantiq(text):action(function(node)
        local mouse_pos = globalWindow:mouse_position()
        if bounds(uppercenter, vec2(node.width, textHeight), mouse_pos) then
            anima.tween(node, 0.5, { color = highlightedTextColor })
            if globalWindow:mouse_pressed("left") then
                node:append(am.group():action(am.play(audio.menuButtonClick, false, 0.65, 0.5)))
                buttonAction()
            end
        else
            if node("tween") then
                anima.tween(node, 0.5, { color = textColor })
            end
        end
    end)
end

function bounds(uppercenter, size, target)
    return target.y < uppercenter.y and target.y > uppercenter.y - size.y
end

function Menu:new()
    print()
    local images = {
        am.scale(2) ^ am.sprite("assets/images/dot_eyes.png"),
        am.scale(2) ^ am.sprite("assets/images/stone_angel.png"),
        am.scale(2) ^ am.sprite("assets/images/rainbow.png"),
        am.scale(2) ^ am.sprite("assets/images/sad_angel.png"),
        am.scale(2) ^ am.sprite("assets/images/unnerving.png"),
    }
    local frames = 0

    local menu = am.group() ^ {
        am.group():action(function(node)
            if frames == 0 and node.num_children == 0 and math.random() < 0.05 then
                table.shuffle(images)
                node:append(images[1])
                frames = 10
            elseif frames == 0 then
                node:remove_all()
            else
                frames = frames - 1
            end
        end),
        am.particles2d({
            source_pos = vec2(0, screenEdge.y + 100),
            source_pos_var = vec2(screenEdge.x * 2, 50),
            start_size = 3,
            start_size_var = 1,
            max_particles = 10000,
            warmup_time = 40,
            emission_rate = 40,
            life = 1000,
            speed = -200,
            speed_var = 20,
            angle = math.rad(90)
        }),
        am.particles2d({
            source_pos = vec2(0, screenEdge.y + 100),
            source_pos_var = vec2(screenEdge.x * 2, 50),
            start_size = 3,
            start_size_var = 1,
            max_particles = 10000,
            warmup_time = 40,
            emission_rate = 10,
            life = 1000,
            speed = -100,
            speed_var = 70,
            angle = math.rad(90)
        }),
        am.translate(0, screenEdge.y / 2) ^ 
            { yantiqLarge("[glass angel]", "center", "bottom"), 
            am.translate(0, -96) 
                ^ ned("[glass angel]", "center", "bottom") 
            },
        button("start", 0),
        button("level select", 1),
        button("settings", 2),
        button("credits", 3),
        button("quit", 4, function() globalWindow:close() end),
        am.group():action(am.play(audio.mainMenuMusic, true))
    }

    menu:action(function(scene)
        -- Menu main loop
    end)
    return menu
end
