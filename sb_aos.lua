local CFG = require("cfg")

---@class SOAApproach: bmImplementation
local AOS = {
    bunnycount = 0,
    bunnies = {},
    Setup = function(self, img, imgw, imgh, sb)
        self.img = img
        self.imgw = imgw
        self.imgh = imgh
        self.sb = sb
    end,
    Update = function(self, dt)
        local i = 1
        local count = #self.bunnies
        while i <= count do
            local bunny = self.bunnies[i]
            bunny.position.x = bunny.position.x + bunny.speed.x * dt
            bunny.position.y = bunny.position.y + bunny.speed.y * dt

            local center_x = bunny.position.x + self.imgw / 2
            local center_y = bunny.position.y + self.imgh / 2

            if center_x > CFG.WIDTH or center_x < 0 then
                bunny.speed.x = -bunny.speed.x
            end
            if center_y > CFG.HEIGHT or center_y < 0 then
                bunny.speed.y = -bunny.speed.y
            end

            -- setColor for each is actually expensive, removing this line improves performance vastly.
            self.sb:setColor(bunny.color.r, bunny.color.g, bunny.color.b, 1)
            self.sb:set(i, bunny.position.x, bunny.position.y)
            i = i + 1
        end
    end,
    SpawnBunnies = function(self, x, y)
        local count = #self.bunnies

        for i = 1, CFG.ADD_AMOUNT do
            local bunny = {
                position = { x = x, y = y },
                speed = {
                    x = love.math.random(-250, 250),
                    y = love.math.random(-250, 250)
                },
                color = {
                    r = love.math.random(50 / 255, 240 / 255),
                    g = love.math.random(80 / 255, 240 / 255),
                    b = love.math.random(100 / 255, 240 / 255)
                }
            }
            self.bunnies[count + i] = bunny

            self.sb:add(bunny.position.x, bunny.position.y)
        end

        self.bunnycount = count + CFG.ADD_AMOUNT
    end,
    DespawnBunnies = function(self)
        -- Determine how many bunnies to remove (up to 10000)
        local count_to_remove = math.min(CFG.REMOVE_AMOUNT, #self.bunnies)

        -- If there are bunnies to remove, slice the bunnies table starting from the 1001st bunny
        if count_to_remove > 0 then
            -- Directly slice the table from the `count_to_remove + 1` to the end
            local new_bunnies = {}
            for i = count_to_remove + 1, #self.bunnies do
                table.insert(new_bunnies, self.bunnies[i])
            end
            self.bunnies = new_bunnies
            self.bunnycount = #self.bunnies
        end

        -- Clear the SpriteBatch and re-add remaining bunnies
        self.sb:clear()
        for i = 1, #self.bunnies do
            local bunny = self.bunnies[i]
            self.sb:add(bunny.position.x, bunny.position.y)
        end
    end
}

return AOS
