local shader_code = [[
#ifdef VERTEX
attribute vec2 BunnyPosition;
attribute vec3 BunnyTint;

varying vec3 bunnyTint;

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    // shared quad is at the origin, so apply the full position
    vertex_position.xy += BunnyPosition;
    bunnyTint = BunnyTint;
    return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
varying vec3 bunnyTint;
vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 screen_coords)
{
    return Texel(tex, texcoord) * color * vec4(bunnyTint, 1.0);
}
#endif
]]

return shader_code
