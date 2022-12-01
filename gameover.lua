local gameover = ...

local audio = require 'audio'

local Menu = require 'menu'

gameover.scene = am.group():tag"gameover" ^ {
    am.rect(-screenEdge.x, screenEdge.y * 2, screenEdge.x, -screenEdge.y, vec4(0, 0, 0, 0.5)),
    large_text_node("Game Over"),
    button("continue", 2, function()
        Continue = true
        Life = 5
        for _, child in globalWindow.scene:child_pairs() do
            child.paused = false
        end
        globalWindow.scene:remove("gameover")
    end),
    button("return to menu", 3, function()
        Continue = false
        Score = 0
        globalWindow.scene = Menu:new()
    end)
}

gameover.scene:action("music", am.play(audio.stageclear, true, 0.25))

