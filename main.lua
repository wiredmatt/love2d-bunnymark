local CFG = require("cfg")

---@type love.Image
local image

---@type love.SpriteBatch
local sb

---@type number
local imgw
---@type number
local imgh

---@type bmApproach
local Impl = nil

love.load = function()
    love.window.setMode(CFG.WIDTH, CFG.HEIGHT, { resizable = false })
    image = love.graphics.newImage("assets/wabbit_alpha.png")
    imgw = image:getWidth()
    imgh = image:getHeight()
    sb = love.graphics.newSpriteBatch(image, CFG.MAX_BUNNIES)

    Impl = require(CFG.APPROACH)

    Impl:Setup(image, imgw, imgh, sb)
end

love.draw = function()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(sb)

    if CFG.SHOW_FPS then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", 0, 0, CFG.WIDTH, 16)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.print(
            "#bunnies: " .. Impl.bunnycount ..
            " | approach: " .. CFG.APPROACH ..
            " | fps: " .. love.timer.getFPS(), 0, 0)
    end

    if CFG.SHOW_STATS then
        local stats = love.graphics.getStats()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", 0, CFG.HEIGHT - 16, CFG.WIDTH, 16)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.print(
            "stats" ..
            "| drawcalls: " .. stats.drawcalls ..
            "| images: " .. stats.images,
            0, CFG.HEIGHT - 16
        )
    end
end

love.update = function(dt)
    Impl:Update(dt)
end

love.mousereleased = function(x, y, button)
    if button == 1 then -- right click = spawn
        Impl:SpawnBunnies(x, y)
    else                -- left click = despawn
        Impl:DespawnBunnies()
    end
end
