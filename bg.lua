local bg = ...

bg.texture = am.texture2d("assets/images/background.png")

bg.texture.twrap = "repeat"


local vert_shader = [[
    attribute vec2 vert;
    attribute vec2 uv;
    uniform mat4 MV;
    uniform mat4 P;
    varying vec2 v_uv;
    void main() {
        v_uv = uv;
        gl_Position = P * MV * vec4(vert, 0, 1);
    }
]]

local frag_shader = [[
    precision mediump float;
    uniform sampler2D tex;
    varying vec2 v_uv;
    uniform float scrollFactor;
    void main() {
        vec2 uv = vec2(v_uv.x, v_uv.y + scrollFactor);
        gl_FragColor = texture2D(tex, uv);
    }
]]


bg.scrollingShader = am.program(vert_shader, frag_shader)

bg.scrollSpeed = 0.5

bg.scrolling = am.use_program(bg.scrollingShader)
^ am.bind{
    P = mat4(1),
    uv = am.rect_verts_2d(0, 0, 1, 1),
    vert = am.rect_verts_2d(-1, -1, 1, 1),
    tex = bg.texture,
    scrollFactor = 0.0
}:action(function(node)
    node.scrollFactor = node.scrollFactor + am.delta_time * bg.scrollSpeed
end)
^ am.draw("triangles", am.rect_indices())