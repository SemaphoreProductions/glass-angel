local Menu = ...

local bg = require 'bg'

local anima = require("anima")

local audio = require("audio")

local Game = require("game")

local fonts = require 'fonts'

local textHeight = 64

local function __NULL__() end

local textColor = vec4(0.8, 0.8, 0.8, 1)
local highlightedTextColor = vec4(1, 1, 1, 1)

function text_node(text, halign, valign)
    return am.text(fonts.annapurnaRegular, text, textColor, halign, valign)
end

function large_text_node(text, halign, valign)
    return am.text(fonts.annapurnaRegularLarge, text, highlightedTextColor, halign, valign)
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
    return am.translate(uppercenter.x, uppercenter.y) ^ text_node(text):action(function(node)
        local mouse_pos = globalWindow:mouse_position()
        if bounds(uppercenter, vec2(node.width, textHeight), mouse_pos) then
            anima.tween(node, 0.5, { color = highlightedTextColor })
            if globalWindow:mouse_pressed("left") then
                node:append(am.group():action(am.play(audio.menuButtonClick, false, 0.65, VOLUME)))
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

    local menu = am.group() ^ {
        bg.scrolling,
        am.translate(0, screenEdge.y / 2) ^ 
            { large_text_node("[glass angel]", "center", "bottom"), 
            am.translate(0, -96) 
                ^ ned("[glass angel]", "center", "bottom") 
            },
        button("start", 0, function() 
            globalWindow.scene = Game:new()
        end),
        button("settings", 1),
        button("credits", 2),
        button("quit", 3, function() globalWindow:close() end),
        am.group():action(am.play(audio.mainMenuMusic, true, nil, VOLUME))
    }

    menu:action(function(scene)
        -- Menu main loop
    end)
    return menu
end
