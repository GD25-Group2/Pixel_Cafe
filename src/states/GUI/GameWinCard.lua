GameWinCard = class {__includes = BaseEntity}

local winConditionMoney = WIN_CONDITION_MONEY

function GameWinCard:init()
    BaseEntity.init(self, UI_CARD)
    self.priority = 15
    self.isGUI = true
    self.earnedToday = DataManager:getData('todayMoney')
    self.finalTotal = DataManager:getData('totalMoney')
    self.text = 'Congrats'

    self.counter = 0
    self.duration = 1
    self.done = false
    
    self.particleBurst = ParticleBurst()
    gStateStack:push(self.particleBurst)

    Signal:emit('victory_fireworks')
    Signal:emit('victory_fireworks')
end

function GameWinCard:render()
    -- Outer background setup
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, 6, 6)
    
    love.graphics.setColor(self.border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height, 6, 6)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(gColors['white'])
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf(self.text, self.x, self.y + 6, self.width, 'center')
    
    love.graphics.setFont(gFonts['medium'])
    local line1Y = self.y + 42
    local line2Y = self.y + 60
    local line3Y = self.y + 78
    local labelOffset = 20
    local radius = 25
    
    -- Line 1: Total
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf('Total', self.x + labelOffset, line1Y, self.width - labelOffset, 'left')
    love.graphics.setColor(0.2, 0.8, 0.2, 1)
    love.graphics.printf(string.format('$%.2f', self.finalTotal), self.x, line1Y, self.width - labelOffset, 'right')
    
    -- Line 2: Earned
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf('Earned', self.x + labelOffset, line2Y, self.width - labelOffset, 'left')
    love.graphics.setColor(0.2, 0.8, 0.2, 1)
    love.graphics.printf(string.format('$%.2f', self.earnedToday), self.x, line2Y, self.width - labelOffset, 'right')
    
    -- Line3: Challenge Completed
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf('Challenge Failed', self.x + labelOffset, line3Y, self.width - labelOffset, 'left')
    love.graphics.setColor(0.2, 0.8, 0.2, 1)
    love.graphics.setFont(gFonts['small'])
    love.graphics.printf(string.format('$%.2f', self.earnedToday) .. '/' .. winConditionMoney, self.x, line3Y, self.width - labelOffset, 'right')
end