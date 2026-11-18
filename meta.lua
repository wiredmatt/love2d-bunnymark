---@meta

---@class bmImplementation
---@field img love.Image?
---@field imgw number?
---@field imgh number?
---@field sb love.SpriteBatch?
---@field bunnycount number
---@field Setup fun(self, img,imgw,imgh,sb)
---@field Update fun(self, dt: number)
---@field Draw fun(self)?
---@field SpawnBunnies fun(self, x: number, y: number)
---@field DespawnBunnies fun(self)


---@alias bmImplementationId "sb_aos" | "sb_soa" | "gpu"
