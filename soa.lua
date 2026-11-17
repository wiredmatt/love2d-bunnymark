local CFG = require("cfg")

---@class SOAApproach: bmApproach
local SOA = {
    bunnycount = 0,
    pos_x = {},
    pos_y = {},
    spd_x = {},
    spd_y = {},
    clr_r = {},
    clr_g = {},
    clr_b = {},
    Setup = function(self, img, imgw, imgh, sb)
        self.img = img
        self.imgw = imgw
        self.imgh = imgh
        self.sb = sb
    end,
    Update = function(self, dt)
        local count = self.bunnycount
        local pos_x, pos_y = self.pos_x, self.pos_y
        local spd_x, spd_y = self.spd_x, self.spd_y
        local clr_r, clr_g, clr_b = self.clr_r, self.clr_g, self.clr_b
        local sb = self.sb
        local half_imgw, half_imgh = self.imgw / 2, self.imgh / 2
        local width, height = CFG.WIDTH, CFG.HEIGHT

        for i = 1, count do
            local x = pos_x[i] + spd_x[i] * dt
            local y = pos_y[i] + spd_y[i] * dt
            pos_x[i], pos_y[i] = x, y

            if x + half_imgw > width or x + half_imgw < 0 then
                spd_x[i] = -spd_x[i]
            end
            if y + half_imgh > height or y + half_imgh < 0 then
                spd_y[i] = -spd_y[i]
            end

            sb:setColor(clr_r[i], clr_g[i], clr_b[i], 1)
            sb:set(i, x, y)
        end
    end,
    SpawnBunnies = function(self, x, y)
        local count = self.bunnycount
        local pos_x, pos_y = self.pos_x, self.pos_y
        local spd_x, spd_y = self.spd_x, self.spd_y
        local clr_r, clr_g, clr_b = self.clr_r, self.clr_g, self.clr_b
        local sb = self.sb

        for i = 1, CFG.ADD_AMOUNT do
            local bunnyidx = count + i
            pos_x[bunnyidx], pos_y[bunnyidx] = x, y
            spd_x[bunnyidx] = love.math.random(-250, 250)
            spd_y[bunnyidx] = love.math.random(-250, 250)
            clr_r[bunnyidx] = love.math.random(50 / 255, 240 / 255)
            clr_g[bunnyidx] = love.math.random(80 / 255, 240 / 255)
            clr_b[bunnyidx] = love.math.random(100 / 255, 240 / 255)

            sb:setColor(clr_r[bunnyidx], clr_g[bunnyidx], clr_b[bunnyidx], 1)
            sb:add(x, y)
        end

        self.bunnycount = count + CFG.ADD_AMOUNT
    end,
    DespawnBunnies = function(self)
        local count_to_remove = math.min(CFG.REMOVE_AMOUNT, self.bunnycount)
        local old_count = self.bunnycount
        local new_count = old_count - count_to_remove

        if count_to_remove > 0 then
            local pos_x, pos_y = self.pos_x, self.pos_y
            local spd_x, spd_y = self.spd_x, self.spd_y
            local clr_r, clr_g, clr_b = self.clr_r, self.clr_g, self.clr_b

            for i = 1, new_count do
                local source = i + count_to_remove
                pos_x[i], pos_y[i] = pos_x[source], pos_y[source]
                spd_x[i], spd_y[i] = spd_x[source], spd_y[source]
                clr_r[i], clr_g[i], clr_b[i] = clr_r[source], clr_g[source], clr_b[source]
            end

            for i = old_count, new_count + 1, -1 do
                pos_x[i], pos_y[i] = nil, nil
                spd_x[i], spd_y[i] = nil, nil
                clr_r[i], clr_g[i], clr_b[i] = nil, nil, nil
            end

            self.bunnycount = new_count
        end

        self.sb:clear()
        for i = 1, self.bunnycount do
            self.sb:setColor(self.clr_r[i], self.clr_g[i], self.clr_b[i], 1)
            self.sb:add(self.pos_x[i], self.pos_y[i])
        end
    end
}

return SOA
