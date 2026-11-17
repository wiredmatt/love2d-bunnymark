local CFG = require("cfg")

---@class SOAApproach: bmApproach
local SOA = {
    bunnycount = 0,
    positions = {},
    speeds = {},
    colors = {},
    Setup = function(self, img, imgw, imgh, sb)
        self.img = img
        self.imgw = imgw
        self.imgh = imgh
        self.sb = sb
    end,
    Update = function(self, dt)
        local i = 1
        local count = self.bunnycount

        while i <= count do
            local bunny_pos = self.positions[i]
            local bunny_spd = self.speeds[i]
            bunny_pos.x = bunny_pos.x + bunny_spd.x * dt
            bunny_pos.y = bunny_pos.y + bunny_spd.y * dt

            local center_x = bunny_pos.x + self.imgw / 2
            local center_y = bunny_pos.y + self.imgh / 2

            if center_x > CFG.WIDTH or center_x < 0 then
                bunny_spd.x = -bunny_spd.x
            end
            if center_y > CFG.HEIGHT or center_y < 0 then
                bunny_spd.y = -bunny_spd.y
            end

            -- setColor for each is actually expensive, removing this line improves performance vastly.
            local bunny_clr = self.colors[i]
            self.sb:setColor(bunny_clr.r, bunny_clr.g, bunny_clr.b, 1)
            self.sb:set(i, bunny_pos.x, bunny_pos.y)
            i = i + 1
        end
    end,
    SpawnBunnies = function(self, x, y)
        local count = self.bunnycount

        for i = 1, CFG.ADD_AMOUNT do
            local bunnyidx = count + i

            local pos = { x = x, y = y }
            self.positions[bunnyidx] = pos
            self.speeds[bunnyidx] = {
                x = love.math.random(-250, 250),
                y = love.math.random(-250, 250),
            }
            self.colors[bunnyidx] = {
                r = love.math.random(50 / 255, 240 / 255),
                g = love.math.random(80 / 255, 240 / 255),
                b = love.math.random(100 / 255, 240 / 255)
            }

            self.sb:add(pos.x, pos.y)
        end

        self.bunnycount = count + CFG.ADD_AMOUNT
    end,
    DespawnBunnies = function(self)
        -- Determine how many bunnies to remove (up to 10000)
        local count_to_remove = math.min(CFG.REMOVE_AMOUNT, self.bunnycount)

        -- If there are bunnies to remove, slice the bunnies table starting from the 1001st bunny
        if count_to_remove > 0 then
            local new_pos = {}
            local new_spd = {}
            local new_clr = {}

            for i = count_to_remove + 1, self.bunnycount do
                table.insert(new_pos, self.positions[i])
                table.insert(new_spd, self.speeds[i])
                table.insert(new_clr, self.colors[i])
            end

            self.positions = new_pos
            self.speeds = new_spd
            self.colors = new_clr

            self.bunnycount = self.bunnycount - count_to_remove
        end

        -- Clear the SpriteBatch and re-add remaining bunnies
        self.sb:clear()
        for i = 1, self.bunnycount do
            local pos = self.positions[i]
            self.sb:add(pos.x, pos.y)
        end
    end
}

return SOA
