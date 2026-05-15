Scrollbar = class{__includes = BaseEntity}

function Scrollbar:init(params)
    BaseEntity.init(self, params)
    self.scrollValue = 0
    self.maxHeight = 0
    self.isGUI = true
    self.thumbHeight = self.desired_height
end

function Scrollbar:clicked()
    return
end

function Scrollbar:wheelScroll(y)
    local sensitivity = 20
    self.scrollValue = self.scrollValue - (y * sensitivity)

    self.scrollValue = math.max(0, math.min(self.scrollValue, self.maxHeight))
end

function Scrollbar:getY()
    return self.scrollValue
end

function Scrollbar:addHeight(height)
    self.maxHeight = (self.maxHeight or 0) + height
    if self.maxHeight > 0 then
        local ratio = self.desired_height / (self.maxHeight + self.desired_height)
        self.thumbHeight = math.max(10, self.desired_height * ratio)
    end
end

function Scrollbar:render()
    local scrollPercent = self.maxHeight > 0 and (self.scrollValue / self.maxHeight) or 0
    local trackSpace = self.desired_height - self.thumbHeight
    local thumbY = self.y + (scrollPercent * trackSpace)

    love.graphics.setColor(gColors['white'])
    love.graphics.rectangle('fill', self.x, thumbY, self.desired_width, self.thumbHeight)
end