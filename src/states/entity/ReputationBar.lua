ReputationBar = class {__includes = BaseEntity}

local config = {
    desired_width = 30,
    desired_height = 12,
    x = 210,
    y = 2,
    buffer = 2,
    counter = 0,
}

function ReputationBar:init()
    BaseEntity.init(self, config)

    self.type = 'ReputationBar'
    self.backgroundColor = gColors['curtain']
    self.reputation = DataManager:getData('reputation')
    self.rColor = gColors['yellow']
    self:updateColors()

    self.onCustomerServed = function(amount)
        self:changeReputation(amount)
    end

    Signal:register('customer-served', self.onCustomerServed)
end

function ReputationBar:changeReputation(amount)
    self.reputation = math.min(100, math.max(0, self.reputation + amount))
    DataManager:modify('reputation', self.reputation)
    self:updateColors()
end

function ReputationBar:updateColors()
    local percent = self.reputation / 100
    if percent > 0.5 then
        self.rColor[1] = 0.2 + (percent * 0.8)
        self.rColor[2] = 1.0
    else
        self.rColor[1] = 1.0
        self.rColor[2] = 0.2 + (percent * 0.8)
    end

    self.backgroundColor = gColors['white']
    self.backgroundChange = true
end

function ReputationBar:update(dt)
    if self.backgroundChange then
        local duration = 0.3
        self.counter = self.counter + dt

        if self.counter > duration then
            self.counter = 0
            self.backgroundChange = false
            self.backgroundColor = gColors['curtain']
        end
    end
end

function ReputationBar:render()
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle('fill', self.x, self.y, self.desired_width, self.desired_height)

    local availableWidth = self.desired_width - (self.buffer * 2)
    local currentDisplayWidth = (self.reputation / 100) * availableWidth

    love.graphics.setColor(self.rColor)
    love.graphics.rectangle('fill', self.x + self.buffer, self.y + self.buffer, currentDisplayWidth, self.desired_height - (self.buffer * 2))

    love.graphics.setColor(gColors['white'])
end