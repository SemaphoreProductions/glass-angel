local Enemy = require 'enemy'
local Projectile = require 'projectile'

local minion = [[
...r.r.r...
.rrrrrrrrr.
.rRrrrrrRr.
rrrrMMMrrrr
.rrMMmMMrr.
rrrMmmmMrrr
.rrMMmMMrr.
rrrrMMMrrrr
.rRrrrrrRr.
.rrrrrrrrr.
...r.r.r...
]]

local function move_and_then(velocity, after)
    return am.parallel({function(enemy)
        enemy.position2d = enemy.position2d + velocity * am.delta_time
    end, after})
end

local function repeat_every(secs, func)
    return coroutine.create(function(enemy)
        while true do
            am.wait(am.delay(secs))
            func(enemy)
        end
    end)
end

local zoomer = function(scene, xfunc) local time = am.frame_time return Enemy.minion(scene, minion, nil, move_and_then(vec2(0, -600), function(enemy)
    enemy.position2d = enemy.position2d{ x = xfunc(time)}
end)) end


local shooter_bullet = "assets/sprite/shooter_bullet.png"

local shooter = function(scene, xvel)
    local factory = Projectile:newMultishotBulletFactory(shooter_bullet, {-10, -5, 0, 5, 10}, 400)
    return Enemy.minion(scene, minion, nil, move_and_then(vec2(xvel, -200), repeat_every(2, function(enemy)
        factory:fire(scene, enemy.position2d)
    end)), 3, 200) end

local function display_title(scene, text, scale)
    local size = scale or 1
    scene:append(am.scale(size):tag"title" ^ am.text(fonts.annapurnaBoldLarge, text))
end

local function fade_title(scene, fade_time)
    local title = scene"title":child(1)
    return am.tween(title, fade_time, {
            color = vec4(title.color.x, title.color.y, title.color.z, 0)
        }
    )
end

local function any_key_down()
    return #globalWindow:keys_pressed() > 0 or globalWindow:mouse_down("left")
end

local function clear_dialogue(scene)
    scene:remove("dialogue")
end

local function show_dialogue(scene, text, character_name, portrait)
    local chars_per_second = 15
    return coroutine.create(function()
        if scene"dialogue" ~= nil then
            clear_dialogue(scene)
        end
        local dialogue_container = am.translate(vec2(0, -screenEdge.y / 2)):tag"dialogue" ^ {
            -- character portrait
            am.rect(-screenEdge.x, screenEdge.y * 2, screenEdge.x, -screenEdge.y, vec4(0, 0, 0, 0.5)),
            am.translate(vec2(-screenEdge.x / 2, 0)) ^ am.scale(0.2, 0.2) ^ am.sprite(portrait),
            am.rect(-screenEdge.x, -screenEdge.y / 6, screenEdge.x, -screenEdge.y / 2, vec4(0, 0, 0, 0.7)),
            am.translate(screenEdge.x, -screenEdge.y / 6) ^ am.scale(3) ^ am.text(character_name, "right", "bottom"),
            am.translate(-screenEdge.x + 20, -screenEdge.y / 3) ^ am.scale(3) ^ am.text("", nil, "left", "center"):tag"textbox",
        }
        scene:append(dialogue_container)
        local textbox = dialogue_container"textbox"
        for i = 1, #text do
            if i > 1 and any_key_down() then
                -- skip to end
                textbox.text = text
                break
            end
            local c = text:sub(i, i)
            am.wait(am.delay(1 / chars_per_second))
            textbox.text = textbox.text .. c
        end
    end)
end

local function until_any_key()
    return coroutine.create(function()
        am.wait(am.delay(am.delta_time))
        repeat
            coroutine.yield()
        until any_key_down()
    end)
end

-- The complete script to the game - cutscenes, enemy waves, and boss fights
return {
    -- Stage 1
    {
        bgmusic = "audio/shockandawe.ogg",
        scenes = {
            coroutine.create(function(scene)
                am.wait(am.delay(0.5))
                am.wait(show_dialogue(scene"dialoguearea", "Well, this is it.\nThis is... hell.", "Ava", "assets/images/expressions/neutral_A.png"))
                am.wait(until_any_key())
                am.wait(show_dialogue(scene"dialoguearea", "It's a lot more colorful\nthan I expected.", "Finch", "assets/images/expressions/surprise.png"))
                am.wait(until_any_key())
                am.wait(show_dialogue(scene"dialoguearea", "What? Were you expecting\nan infernal wasteland or something?", "Ava", "assets/images/expressions/surprise_A.png"))
                am.wait(until_any_key())
                am.wait(show_dialogue(scene"dialoguearea", "Something like that, yes.", "Finch", "assets/images/expressions/surprise.png"))
                am.wait(until_any_key())
                am.wait(show_dialogue(scene"dialoguearea", "Meh. That's only to scare people.", "Ava", "assets/images/expressions/neutral_A.png"))
                am.wait(until_any_key())
                am.wait(show_dialogue(scene"dialoguearea", "Well, shouldn't we be scared?", "Finch", "assets/images/expressions/surprise.png"))
                am.wait(until_any_key())
                am.wait(show_dialogue(scene"dialoguearea", "Scared? We're about to\n take down the lord of darkness\nhimself, and you're scared?", "Ava", "assets/images/expressions/surprise_A.png"))
                am.wait(until_any_key())
                am.wait(show_dialogue(scene"dialoguearea", "*sigh* I can't believe you talked me\ninto this. What will our godparents\nthink?", "Finch", "assets/images/expressions/surprise.png"))
                am.wait(until_any_key())
                am.wait(show_dialogue(scene"dialoguearea", "Look, once in a while\nsomebody's got to show these demons\ntheir place.", "Ava", "assets/images/expressions/neutral_A.png"))
                am.wait(until_any_key())
                am.wait(show_dialogue(scene"dialoguearea", "We're not sinning.\nThis is what we were made to do.\nOur parents should be proud.", "Ava", "assets/images/expressions/neutral_A.png"))
                am.wait(until_any_key())
                am.wait(show_dialogue(scene"dialoguearea", "Even if we die?\nThere's hundreds of them\nand only two of us.", "Finch", "assets/images/expressions/neutral.png"))
                am.wait(until_any_key())
                am.wait(show_dialogue(scene"dialoguearea", "Look, there's no time to argue.\nHere they come!", "Ava", "assets/images/expressions/surprise_A.png"))
                am.wait(until_any_key())
                clear_dialogue(scene)
                scene:append(am:group():tag"continue")
            end),
            coroutine.create(function(scene)
                ava.shouldFire = true
                finch.shouldFire = true
                display_title(scene, "GET READY")
                am.wait(am.delay(1))
                am.wait(fade_title(scene, 1))
                am.wait(am.delay(2))
                scene:append(am:group():tag"continue")
            end),
            coroutine.create(function(scene)
                local i = 5
                while i > 0 do
                    scene"enemies":append(zoomer(scene, function(time) return math.sin(am.frame_time + time) * screenEdge.x / 2 end):spawn_top(0))
                    am.wait(am.delay(0.5))
                    i = i - 1
                end
                local i = 3
                local inc = screenEdge.x / i
                math.randomseed(1337)
                while i > 0 do
                    scene"enemies":append(shooter(scene, -100):spawn_top(screenEdge.x / 2 - inc * (3 - i)))
                    am.wait(am.delay(2 * (math.random() + 1.5)))
                    i = i - 1
                end
                local i = 20
                while i > 0 do
                    scene"enemies":append(shooter(scene, 50 * (math.random() - 0.5)):spawn_top(screenEdge.x * 1.5 * (math.random() - 0.5)))
                    am.wait(am.delay((math.random() + 0.5)))
                    i = i - 1
                end
                am.wait(am.delay(3))
                scene:append(am:group():tag"continue")
            end),
            coroutine.create(function(scene)
                display_title(scene, "That's all we\n have for now.\nLook forward\n to more!", 0.8)
            end)
        }
    },
    {
        scenes = {}
    }
}