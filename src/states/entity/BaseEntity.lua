BaseEntity = class {__includes = BaseState}

function BaseEntity:init(params)
    for k, v in pairs(params) do
        self[k] = v
    end

    self._isBubbleActive = false
    self._bubbleColor = gColors['white']
end

function BaseEntity:update(dt)
    if self.animation then
        self.animation:update(dt, self)
        local frame = self.animation:getFrame()
        if frame then
            self.frame = frame
        end
    end
end

function BaseEntity:showBubble(color)
    self._isBubbleActive = true
    self._bubbleColor = color or self._bubbleColor or gColors['white']
end

function BaseEntity:hideBubble()
    self._isBubbleActive = false
end

function BaseEntity:render()
    if self.type == 'Cursor' then
        self.x = mouseX
        self.y = mouseY
    end

    love.graphics.draw(self.frame, self.x, self.y, 0, 
        self.desired_width / self.frame:getWidth(), self.desired_height / self.frame:getHeight())

    if self._isBubbleActive then
        -- Event-driven floating animation using math.sin
        local floatOffset = math.sin(love.timer.getTime() * 4) * 2
        local bx = self.x + self.desired_width / 2
        local by = self.y - 8 + floatOffset -- Floating above the entity
        
        -- Glow effect
        local r, g, b, a = unpack(self._bubbleColor)
        love.graphics.setColor(r, g, b, 0.3)
        love.graphics.circle('fill', bx, by, 6)
        
        -- Main bubble
        love.graphics.setColor(r, g, b, 1)
        love.graphics.circle('fill', bx, by, 4)
        
        -- Shine/Highlight
        love.graphics.setColor(1, 1, 1, 0.6)
        love.graphics.circle('fill', bx - 1.5, by - 1.5, 1.5)
        
        -- Border
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.setLineWidth(1)
        love.graphics.circle('line', bx, by, 4.5)
        
        love.graphics.setColor(gColors['white'])
    end
end

function BaseEntity:isMouseOver()
    return mouseX > self.x and mouseX < self.x + self.desired_width and
           mouseY > self.y and mouseY < self.y + self.desired_height
end