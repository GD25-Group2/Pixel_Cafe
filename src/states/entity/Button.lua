Button = class {__includes = BaseEntity}

function Button:init(params)
    BaseEntity.init(self, params)
    self.isHovering = false
    self.isGUI = true
end

function Button:update(dt)
    if self.clickable then
        if self:isMouseOver() then
            self.isHovering = true
        else
            self.isHovering = false
        end
    end

    if self.coordinateChange then
        self.y = (self.id * (self.item_height + self.buffer)) + 20 - self.changeY + (self.buffer * 2)
    end
end

function Button:render()
    if self.isHovering and self.clickable then
        love.graphics.setColor(self.hoverColor)
    elseif self.clickable then
        love.graphics.setColor(self.defaultColor)
    else
        love.graphics.setColor(gColors['gray'])
    end
    love.graphics.rectangle('fill', self.x, self.y, self.desired_width, self.desired_height)
    if self.text then
        love.graphics.setColor(gColors['black'])
        love.graphics.setFont(gFonts['small'])
        local buffer = math.max(1, math.abs(self.desired_height - self.y) * 0.05)
        love.graphics.printf(self.text, self.x, self.y + buffer, self.desired_width, 'center')
    elseif self.frame then
        love.graphics.setColor(gColors['white'])
        love.graphics.draw(self.frame, self.x, self.y, 0, 
            self.desired_width / self.frame:getWidth(), self.desired_height / self.frame:getHeight())
    end
    love.graphics.setColor(gColors['black'])
    love.graphics.rectangle('line', self.x, self.y, self.desired_width, self.desired_height)
    love.graphics.setColor(gColors['white'])
end

function Button:clicked()
    if self.clickable then
        if gSounds['click'] then
            gSounds['click']:setVolume(gSettings.sfxVolume)
            gSounds['click']:play()
        end
        self.action()
    end
end

function Button:enable()
    self.clickable = true
end

function Button:disable()
    self.clickable = false
end

function Button:updateY(y, id, itemHeight, buffer)
    self.changeY = y
    self.id = id
    self.item_height = itemHeight
    self.buffer = buffer
end