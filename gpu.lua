local CFG = require("cfg")
local shader_src = require("gpu_shader")

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
---@field mesh love.Mesh
---@field shader love.Shader
local GPU = {
    bunnycount = 0,
    -- positions
    pos_x = {},
    pos_y = {},
    -- speeds
    spd_x = {},
    spd_y = {},
    -- colors
    clr_r = {},
    clr_g = {},
    clr_b = {},
    -- impl
    Setup = function(self, img, imgw, imgh)
        local features = love.graphics.getSupported()
        assert(features["instancing"],
            "gpu instancing not supported by your gpu. requires at least OpenGL ES 2 or OpenGL 2")

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

        self.mesh = love.graphics.newMesh({
            { "BunnyPosition", "float", 2 },
            { "BunnyTint",     "float", 3 },
        }, CFG.MAX_BUNNIES, nil, "dynamic")
        self.quad:attachAttribute("BunnyPosition", self.mesh, "perinstance")
        self.quad:attachAttribute("BunnyTint", self.mesh, "perinstance")

        self.shader = love.graphics.newShader(shader_src)
    end,
    Update = function(self, dt)
        local pos_x, pos_y = self.pos_x, self.pos_y
        local spd_x, spd_y = self.spd_x, self.spd_y
        local red, green, blue = self.clr_r, self.clr_g, self.clr_b
        local half_imgw, half_imgh = self.imgw / 2, self.imgh / 2
        local width, height = CFG.WIDTH, CFG.HEIGHT
        local instances = self.mesh

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
    end,
    SpawnBunnies = function(self, x, y)
        local count = self.bunnycount
        local new_count = math.min(count + CFG.ADD_AMOUNT, CFG.MAX_BUNNIES)

        for i = count + 1, new_count do
            self.pos_x[i] = x
            self.pos_y[i] = y
            self.spd_x[i] = love.math.random(-250, 250)
            self.spd_y[i] = love.math.random(-250, 250)
            self.clr_r[i] = love.math.random(50 / 255, 240 / 255)
            self.clr_g[i] = love.math.random(80 / 255, 240 / 255)
            self.clr_b[i] = love.math.random(100 / 255, 240 / 255)
            self.mesh:setVertex(i, self.pos_x[i], self.pos_y[i], self.clr_r[i], self.clr_g[i], self.clr_b[i])
        end

        self.bunnycount = new_count
    end,
    DespawnBunnies = function(self)
        local old_count = self.bunnycount
        local remove_count = math.min(CFG.REMOVE_AMOUNT, old_count)
        local new_count = old_count - remove_count

        for i = 1, new_count do
            local source = i + remove_count
            self.pos_x[i], self.pos_y[i] = self.pos_x[source], self.pos_y[source]
            self.spd_x[i], self.spd_y[i] = self.spd_x[source], self.spd_y[source]
            self.clr_r[i], self.clr_g[i], self.clr_b[i] = self.clr_r[source], self.clr_g[source], self.clr_b[source]
            self.mesh:setVertex(i, self.pos_x[i], self.pos_y[i], self.clr_r[i], self.clr_g[i], self.clr_b[i])
        end

        for i = old_count, new_count + 1, -1 do
            self.pos_x[i], self.pos_y[i] = nil, nil
            self.spd_x[i], self.spd_y[i] = nil, nil
            self.clr_r[i], self.clr_g[i], self.clr_b[i] = nil, nil, nil
        end

        self.bunnycount = new_count
    end,
    Draw = function(self)
        if self.bunnycount == 0 then return end

        love.graphics.setShader(self.shader)

        -- from https://love2d.org/wiki/love.graphics.drawInstanced >
        -- Draws many instances of a Mesh with a single draw call, using hardware
        -- geometry instancing.
        -- Each instance can have unique properties (positions, colors, etc.)
        -- but will not by default unless a custom per-instance vertex attributes
        -- or the love_InstanceID GLSL 3 vertex shader variable is used, otherwise
        -- they will all render at the same position on top of each other.
        -- Instancing is not supported by some older GPUs that are only capable of
        -- using OpenGL ES 2 or OpenGL 2. Use love.graphics.getSupported to check.
        love.graphics.drawInstanced(self.quad, self.bunnycount)

        love.graphics.setShader()
    end
}

return GPU
