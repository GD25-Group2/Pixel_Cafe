Shadow = class {__includes = BaseEntity}

function Shadow:init(params)
    BaseEntity.init(self, params)
    self.type = 'Shadow'
    self.priority = 60
end

function Shadow:setFrame(frame)
    self.frame = frame
end

function Shadow:setCoor(x, y)
    self.x, self.y = x, y
end

function Shadow:render()
    local tx = self.texture or self.frame
    local quad = nil
    local sw, sh = 0, 0

    if self.frame == nil and self.texture == nil then
        return
    elseif self.frame and self.frame.getViewport then
        quad = self.frame
        local _, _, w, h = quad:getViewport()
        sw, sh = w, h
    elseif tx and tx.getWidth then
        sw = tx:getWidth()
        sh = tx:getHeight()
    end

    love.graphics.setScissor(0, COUNTER_Y, VIRTUAL_WIDTH, COUNTER_LOWER_Y - COUNTER_Y)
    local sx = self.desired_width / sw
    local sy = -(self.desired_height / sh) * 0.5 

    local x = self.xBuffer and self.x + self.xBuffer or self.x
    local y = self.yBuffer and self.y + self.yBuffer or self.y

    local ox = 0
    local oy = sh
    local kx, ky = 0.4, 0
    local r = 0

    love.graphics.setColor(0, 0, 0, 0.4)

    if quad then
        love.graphics.draw(tx, quad, x, y, r, sx, sy, ox, oy, kx, ky)
    else
        love.graphics.draw(tx, x, y, r, sx, sy, ox, oy, kx, ky)
    end

    love.graphics.setScissor()
end