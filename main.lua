local WIDTH = 800
local HEIGHT = 600

---@type love.Image
local image

---@type love.SpriteBatch
local batch

---@type number
local bunny_texture_width
---@type number
local bunny_texture_height

local bunnies = {}

local MAX_BUNNIES = 85000

love.load = function ()
    love.window.setMode(WIDTH, HEIGHT, { resizable = false })
    image = love.graphics.newImage("assets/wabbit_alpha.png")
    bunny_texture_width = image:getWidth()
    bunny_texture_height = image:getHeight()
    batch = love.graphics.newSpriteBatch(image, MAX_BUNNIES)
end

love.draw = function ()
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(batch)

    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("fill", 0,0, WIDTH, 16)

    love.graphics.setColor(0,0,0,1)
    love.graphics.print("#bunnies: " .. #bunnies .. " | fps: " .. love.timer.getFPS(), 0, 0)
end

love.update = function (dt)
    local i = 1
    local count = #bunnies
    while i <= count do
        local bunny = bunnies[i]
        bunny.position.x = bunny.position.x + bunny.speed.x * dt
        bunny.position.y = bunny.position.y + bunny.speed.y * dt

        local centerX = bunny.position.x + bunny_texture_width / 2
        local centerY = bunny.position.y + bunny_texture_height / 2

        if centerX > WIDTH or centerX < 0 then
            bunny.speed.x = -bunny.speed.x
        end
        if centerY > HEIGHT or centerY < 0 then
            bunny.speed.y = -bunny.speed.y
        end

        -- Reusing the position in the batch
        batch:setColor(bunny.color.r, bunny.color.g, bunny.color.b, 1)
        batch:set(i, bunny.position.x, bunny.position.y)
        i = i + 1
    end
end

local spawn_bunnies = function (x, y)
    local count = #bunnies
    local maxToSpawn = 1000
    
    for i = 1, maxToSpawn do
        local bunny = {
            position = {x = x, y = y},
            speed = {
                x = love.math.random(-250, 250),
                y = love.math.random(-250, 250)
            },
            color = {
                r = love.math.random(50/255, 240/255),
                g = love.math.random(80/255, 240/255),
                b = love.math.random(100/255, 240/255)
            }
        }
        bunnies[count + i] = bunny
        
        -- We only need to add a single sprite to the batch at this point
        batch:add(bunny.position.x, bunny.position.y)
    end
end

local despawn_bunnies = function ()
end

love.mousereleased = function(x, y, button, istouch, presses)
    if button == 1 then -- right click = spawn
        spawn_bunnies(x, y)
    else -- left click = despawn
        despawn_bunnies()
    end
end
