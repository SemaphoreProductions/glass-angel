local Enemy = require 'enemy'
local Projectile = require 'projectile'
local audio = require 'audio'
local anima = require 'anima'
local Menu = require 'menu'

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

local eyeSprite = anima.te(
    {
        file = "assets/sprite/eye_sheet.png",
        width = 50,
        height = 57,
        fps = 4.0,
    },
    {
        { row = 1, col = 1 },
        { row = 1, col = 2 },
    }
)

local shooterSprite = am.scale(2) ^ anima.te(
    {
        file = "assets/sprite/demon_sheet.png",
        width = 39,
        height = 47,
        fps = 8.0,
    },
    {
        { row = 1, col = 1 },
        { row = 1, col = 2 },
        { row = 1, col = 3 },
        { row = 1, col = 4 },
        { row = 1, col = 5 },
        { row = 1, col = 6 },
        { row = 1, col = 7 },
        { row = 1, col = 8 },
    }
)

local harpSprite = anima.te(
    {
        file = "assets/sprite/harp_sheet.png",
        width = 129,
        height = 143,
        fps = 4.0,
    },
    {
        { row = 1, col = 1 },
        { row = 1, col = 2 },
        { row = 1, col = 3 },
        { row = 1, col = 4 },
        { row = 1, col = 5 },
        { row = 1, col = 6 },
    }
)

local bigEyeSprite = anima.te(
    {
        file = "assets/sprite/bigeyeball_sheet.png",
        width = 39,
        height = 47,
        fps = 4.0,
    },
    {
        { row = 1, col = 1 },
        { row = 1, col = 2 },
        { row = 1, col = 3 },
        { row = 1, col = 4 },
        { row = 1, col = 5 },
        { row = 1, col = 6 },
        { row = 1, col = 7 },
        { row = 1, col = 8 },
    }
)

local bossSprite = anima.te(
    {
        file = "assets/sprite/boss_sheet.png",
        width = 315,
        height = 313,
        fps = 6.0,
    },
    {
        { row = 1, col = 1 },
        { row = 1, col = 2 },
        { row = 1, col = 3 },
        { row = 1, col = 4 },
        { row = 1, col = 5 },
        { row = 1, col = 6 },
        { row = 1, col = 7 },
        { row = 1, col = 8 },
    }
)


local shooter_bullet = "assets/sprite/shooter_bullet.png"

local zoomer = function(scene, xfunc, vel)
    local time = am.frame_time
    return Enemy.new(
        scene,
        eyeSprite,
        30,
        nil,
        move_and_then(
            vel or vec2(0, -600),
            function(enemy)
                if xfunc ~= nil then
                    enemy.position2d = enemy.position2d{ x = xfunc(time)}
                end
            end
        ),
        2,
        20
    )
end

local shooter = function(scene, xvel)
    local factory = Projectile:newBulletFactory(scene"enemy-curtain", shooter_bullet, {-10, -5, 0, 5, 10}, 400, true, "enemyBullet")
    return Enemy.new(
        scene,
        shooterSprite,
        50,
        nil,
        move_and_then(
            vec2(xvel, -200),
            repeat_every(2, function(enemy)
                factory:fire(scene, enemy.position2d)
            end)
        ),
        6,
        200
    )
end

local harp = function(scene, xfunc)
    local pattern = {}
    for i=-180,180,10 do
        table.insert(pattern, i)
    end
    local factory = Projectile:newBulletFactory(scene"enemy-curtain", shooter_bullet, pattern, 300, true, "enemyBullet")
    return Enemy.new(
        scene,
        harpSprite,
        100,
        nil,
        move_and_then(
            vec2(0, -200),
            repeat_every(2, function(enemy)
                if xfunc ~= nil then
                    enemy.position2d = enemy.position2d{ x = xfunc(time)}
                end
                factory:fire(scene, enemy.position2d)
            end)
        ),
        10,
        500
    )
end

local function display_title(scene, text, scale)
    local size = scale or 1
    local title = am.scale(size):tag"title" ^ am.text(fonts.annapurnaBoldLarge, text)
    if scene"title" ~= nil then
        scene:replace("title", title)
    else
        scene:append(title)
    end
end

local function fade_title(scene, fade_time)
    local title = scene"title":child(1)
    return am.tween(title, fade_time, {
            color = vec4(title.color.x, title.color.y, title.color.z, 0)
        }
    )
end

local function any_key_down()
    return globalWindow:mouse_down("left")
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

local function until_left_click()
    return coroutine.create(function()
        repeat
            coroutine.yield()
        until globalWindow:mouse_down("left")
    end)
end

-- The complete script to the game - cutscenes, enemy waves, and boss fights
return function(scene)
    local ava = scene"ava"
    local finch = scene"finch"
    return {
    -- Stage 1
    {
        bgmusic = audio.stage1,
        bg = "assets/images/stage1finished.png",
        scenes = {
            --[[coroutine.create(function(scene)
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
                local i = 60
                while i > 0 do
                    scene"enemies":append(zoomer(scene, function(time) return math.sin(am.frame_time + time) * screenEdge.x / 2 end):spawn_top(0))
                    am.wait(am.delay(0.3))
                    i = i - 1
                end
                local i = 10
                math.randomseed(1337)
                while i > 0 do
                    scene"enemies":append(shooter(scene, 50 * (-1) ^ (i)):spawn_top((math.random() * 50) * (-1) ^ i))
                    am.wait(am.delay(2 * (math.random() + 1.5)))
                    i = i - 1
                end
                am.wait(am.delay(1))
                scene:append(am:group():tag"continue")
            end),
            coroutine.create(function(scene)
                for i=1,30 do
                    scene"enemies":append(zoomer(scene, nil, vec2(300 * (-1)^(i+1), -50)):spawn_at((screenEdge.x + 100) * (-1)^i, (math.random() - 0.5) * screenEdge.y))
                    am.wait(am.delay(0.4))
                end
                am.wait(am.delay(2))
                scene:append(am.group():tag"continue")
            end),]]
            am.parallel{
                coroutine.create(function(scene)
                    am.wait(am.delay(5))
                    local i = 18
                    while i > 0 do
                        scene"enemies":append(shooter(scene, (math.random() - 0.5) * 200):spawn_top((math.random() * screenEdge.x) * (-1) ^ i))
                        am.wait(am.delay(2))
                        i = i - 1
                    end
                    am.wait(am.delay(5))
                    -- fade music
                    am.wait(am.tween(scene.track, 4, { volume = 0.0}))
                    scene:append(am.group():tag"continue")
                end
                ),
                coroutine.create(function(scene)
                    local i = 200
                    while i > 0 do
                        scene"enemies":append(zoomer(scene):spawn_top((math.random() - 0.5) * screenEdge.x))
                        am.wait(am.delay((0.2)))
                        i = i - 1
                    end
                end)
            }
        }
    },
    {
        bgmusic = audio.stageclear,
        musicloop = false,
        scenes = {
            coroutine.create(function(scene)
                display_title(scene, "Circle 1 Cleared!\nLeft click\nto continue.", 0.5)
                am.wait(until_left_click())
                am.wait(fade_title(scene, 1.0))
                scene:append(am:group():tag"continue")
            end)
        }
    },
    -- Stage 2
    {
        bgmusic = audio.stage2,
        bg = "assets/images/stage3.png",
        scenes = {
            coroutine.create(function(scene)
                ava.shouldShoot = false
                finch.shouldShoot = false
                am.wait(show_dialogue(scene"dialoguearea", "We've reached the 2nd circle.\nWe're getting close.", "Ava", "assets/images/expressions/happy_A.png"))
                am.wait(until_any_key())
                am.wait(show_dialogue(scene"dialoguearea", "Uhh, how many circles are there,\n again?", "Finch", "assets/images/expressions/surprise.png"))
                am.wait(until_any_key())
                am.wait(show_dialogue(scene"dialoguearea", "Only three, actually.", "Ava", "assets/images/expressions/happy_A.png"))
                am.wait(until_any_key())
                am.wait(show_dialogue(scene"dialoguearea", "Although, since the developer\n ran out of time,\n there's only two.", "Ava", "assets/images/expressions/angry_A.png"))
                am.wait(until_any_key())
                am.wait(show_dialogue(scene"dialoguearea", "Huh? I thought there were more.", "Finch", "assets/images/expressions/neutral.png"))
                am.wait(until_any_key())
                am.wait(show_dialogue(scene"dialoguearea", "Nah. That's just something\nDante made up.", "Ava", "assets/images/expressions/happy_A.png"))
                am.wait(until_any_key())
                am.wait(show_dialogue(scene"dialoguearea", "What does each circle represent?", "Finch", "assets/images/expressions/neutral.png"))
                am.wait(until_any_key())
                am.wait(show_dialogue(scene"dialoguearea", "I... have no idea.", "Ava", "assets/images/expressions/surprise_A.png"))
                am.wait(until_any_key())
                clear_dialogue(scene)
                scene:append(am.group():tag"continue")
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
            am.parallel{
                coroutine.create(function(scene)
                    for i=1,10 do
                        scene"enemies":append(harp(scene):spawn_top((math.random() - 0.5) * 400))
                        am.wait(am.delay(5))
                    end
                    scene:append(am:group():tag"continue")
                end),
                coroutine.create(function(scene)
                    for i=1,100 do
                        scene"enemies":append(zoomer(scene, nil, vec2(300, 0)):spawn_at(-screenEdge.x - 100, (math.random() - 0.5) * screenEdge.y))
                        am.wait(am.delay(0.3))
                    end
                end),
                coroutine.create(function(scene)
                    local i = 15
                while i > 0 do
                    scene"enemies":append(shooter(scene, (math.random() - 0.5) * 200):spawn_top((math.random() * screenEdge.x) * (-1) ^ i))
                    am.wait(am.delay(1))
                    i = i - 1
                end
                end)
            }
        }
    },
    {
        bgmusic = audio.stageclear,
        musicloop = false,
        scenes = {
            coroutine.create(function(scene)
                display_title(scene, "Circle 2 Cleared!\nLeft click\nto continue.", 0.5)
                am.wait(until_left_click())
                am.wait(fade_title(scene, 1.0))
                scene:append(am.group():tag"continue")
            end),
            coroutine.create(function(scene)
                scene:append(am.group():tag"continue")
            end)
        }
    },
    {
        bgmusic = audio.stage3,
        bg = "assets/images/stage3.png",
        scenes = {
            coroutine.create(function(scene)
                am.wait(am.delay(6))
                am.wait(show_dialogue(scene"dialoguearea", "Umm... this is the boss\n level, right?", "Finch", "assets/images/expressions/angry.png"))
                am.wait(until_any_key())
                am.wait(show_dialogue(scene"dialoguearea", "As I said,\nthe developer ran out\nof time.", "Ava", "assets/images/expressions/surprise_A.png"))
                am.wait(until_any_key())
                am.wait(show_dialogue(scene"dialoguearea", "So uhhh sorry.\nThis is anticlimactic.", "Ava", "assets/images/expressions/surprise_A.png"))
                am.wait(until_any_key())
                am.wait(show_dialogue(scene"dialoguearea", "Okay, regardless,\nit's time to judge you,\nthe player.", "Ava", "assets/images/expressions/neutral_A.png"))
                am.wait(until_any_key())
                if Continue ~= false then
                    am.wait(show_dialogue(scene"dialoguearea", "Well, it looks\nlike you used Continue to\nget this far.", "Ava", "assets/images/expressions/neutral_A.png"))
                    am.wait(until_any_key())
                    am.wait(show_dialogue(scene"dialoguearea", "No shame in that!\n This game is tricky and unfair.", "Ava", "assets/images/expressions/happy_A.png"))
                    am.wait(until_any_key())
                    am.wait(show_dialogue(scene"dialoguearea", "If you're up for a\nchallenge, try reaching here\nwithout using Continue.", "Finch", "assets/images/expressions/happy.png"))
                    am.wait(until_any_key())
                else
                    am.wait(show_dialogue(scene"dialoguearea", "Wow, look at that!\nNot a single Continue!", "Ava", "assets/images/expressions/happy_A.png"))
                    am.wait(until_any_key())
                    am.wait(show_dialogue(scene"dialoguearea", "Congrats! That is\nnot easy.", "Ava", "assets/images/expressions/happy_A.png"))
                    am.wait(until_any_key())
                    am.wait(show_dialogue(scene"dialoguearea", "If you're up for\nanother go, why not beat\nyour last score?", "Finch", "assets/images/expressions/happy.png"))
                    am.wait(until_any_key())
                end
                am.wait(show_dialogue(scene"dialoguearea", "Your final score was " .. Score .. ".\n Thank you for playing!", "Finch", "assets/images/expressions/happy.png"))
                am.wait(until_any_key())
                globalWindow.scene = Menu:new()
            end)
        }
    }
} end