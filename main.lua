local WIDTH = 800
local HEIGHT = 600

local ADD_AMOUNT = 1000
local REMOVE_AMOUNT = 10000

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

        local center_x = bunny.position.x + bunny_texture_width / 2
        local centerY = bunny.position.y + bunny_texture_height / 2

        if center_x > WIDTH or center_x < 0 then
            bunny.speed.x = -bunny.speed.x
        end
        if centerY > HEIGHT or centerY < 0 then
            bunny.speed.y = -bunny.speed.y
        end

        -- setColor for each is actually expensive, removing this line improves performance vastly.
        batch:setColor(bunny.color.r, bunny.color.g, bunny.color.b, 1)
        batch:set(i, bunny.position.x, bunny.position.y)
        i = i + 1
    end
end

local spawn_bunnies = function (x, y)
    local count = #bunnies

    for i = 1, ADD_AMOUNT do
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

        batch:add(bunny.position.x, bunny.position.y)
    end
end

local despawn_bunnies = function ()
    -- Determine how many bunnies to remove (up to 10000)
    local count_to_remove = math.min(REMOVE_AMOUNT, #bunnies)

    -- If there are bunnies to remove, slice the bunnies table starting from the 1001st bunny
    if count_to_remove > 0 then
        -- Directly slice the table from the `count_to_remove + 1` to the end
        local new_bunnies = {}
        for i = count_to_remove + 1, #bunnies do
            table.insert(new_bunnies, bunnies[i])
        end
        bunnies = new_bunnies
    end

    -- Clear the SpriteBatch and re-add remaining bunnies
    batch:clear()
    for i = 1, #bunnies do
        local bunny = bunnies[i]
        batch:add(bunny.position.x, bunny.position.y)
    end
end

love.mousereleased = function(x, y, button)
    if button == 1 then -- right click = spawn
        spawn_bunnies(x, y)
    else -- left click = despawn
        despawn_bunnies()
    end
end
