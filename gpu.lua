local CFG = require("cfg")

-- each bunny is one instance of a shared quad.
-- simulation happens in the CPU, and the color
-- is applied on the GPU.
-- this technique is practically never seen in
-- tutorials or learning resources, i first
-- heard of it in this video about a year ago:
-- https://www.youtube.com/watch?v=TOPvFvL_GRY
-- while this improves performance astronomically,
-- it can make debugging harder
---@class GPU : bmImplementation
---@field quad love.Mesh
---@field instances love.Mesh
---@field shader love.Shader
local GPU = {
    bunnycount = 0,
    pos_x = {},
    pos_y = {},
    spd_x = {},
    spd_y = {},
    red = {},
    green = {},
    blue = {},
}

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

local function setInstance(instance_mesh, i, self)
    instance_mesh:setVertex(i, self.pos_x[i], self.pos_y[i], self.red[i], self.green[i], self.blue[i])
end

GPU.Setup = function(self, img, imgw, imgh)
    self.img = img
    self.imgw = imgw
    self.imgh = imgh

    self.quad = love.graphics.newMesh({
        { 0,    0,    0, 0, 1, 1, 1, 1 },
        { imgw, 0,    1, 0, 1, 1, 1, 1 },
        { imgw, imgh, 1, 1, 1, 1, 1, 1 },
        { 0,    0,    0, 0, 1, 1, 1, 1 },
        { imgw, imgh, 1, 1, 1, 1, 1, 1 },
        { 0,    imgh, 0, 1, 1, 1, 1, 1 },
    }, "triangles", "static")
    self.quad:setTexture(img)

    self.instances = love.graphics.newMesh({
        { "BunnyPosition", "float", 2 },
        { "BunnyTint",     "float", 3 },
    }, CFG.MAX_BUNNIES, nil, "dynamic")
    self.quad:attachAttribute("BunnyPosition", self.instances, "perinstance")
    self.quad:attachAttribute("BunnyTint", self.instances, "perinstance")

    self.shader = love.graphics.newShader(shader_code)
end

GPU.Update = function(self, dt)
    local pos_x, pos_y = self.pos_x, self.pos_y
    local spd_x, spd_y = self.spd_x, self.spd_y
    local red, green, blue = self.red, self.green, self.blue
    local half_imgw, half_imgh = self.imgw / 2, self.imgh / 2
    local width, height = CFG.WIDTH, CFG.HEIGHT
    local instances = self.instances

    for i = 1, self.bunnycount do
        local x = pos_x[i] + spd_x[i] * dt
        local y = pos_y[i] + spd_y[i] * dt
        pos_x[i], pos_y[i] = x, y

        if x + half_imgw > width or x + half_imgw < 0 then
            spd_x[i] = -spd_x[i]
        end
        if y + half_imgh > height or y + half_imgh < 0 then
            spd_y[i] = -spd_y[i]
        end

        instances:setVertex(i, x, y, red[i], green[i], blue[i])
    end
end

GPU.SpawnBunnies = function(self, x, y)
    local count = self.bunnycount
    local new_count = math.min(count + CFG.ADD_AMOUNT, CFG.MAX_BUNNIES)

    for i = count + 1, new_count do
        self.pos_x[i] = x
        self.pos_y[i] = y
        self.spd_x[i] = love.math.random(-250, 250)
        self.spd_y[i] = love.math.random(-250, 250)
        self.red[i] = love.math.random(50 / 255, 240 / 255)
        self.green[i] = love.math.random(80 / 255, 240 / 255)
        self.blue[i] = love.math.random(100 / 255, 240 / 255)
        setInstance(self.instances, i, self)
    end

    self.bunnycount = new_count
end

GPU.DespawnBunnies = function(self)
    local old_count = self.bunnycount
    local remove_count = math.min(CFG.REMOVE_AMOUNT, old_count)
    local new_count = old_count - remove_count

    for i = 1, new_count do
        local source = i + remove_count
        self.pos_x[i], self.pos_y[i] = self.pos_x[source], self.pos_y[source]
        self.spd_x[i], self.spd_y[i] = self.spd_x[source], self.spd_y[source]
        self.red[i], self.green[i], self.blue[i] = self.red[source], self.green[source], self.blue[source]
        setInstance(self.instances, i, self)
    end

    for i = old_count, new_count + 1, -1 do
        self.pos_x[i], self.pos_y[i] = nil, nil
        self.spd_x[i], self.spd_y[i] = nil, nil
        self.red[i], self.green[i], self.blue[i] = nil, nil, nil
    end

    self.bunnycount = new_count
end

GPU.Draw = function(self)
    if self.bunnycount == 0 then
        return
    end

    love.graphics.setShader(self.shader)
    love.graphics.drawInstanced(self.quad, self.bunnycount)
    love.graphics.setShader()
end

return GPU
