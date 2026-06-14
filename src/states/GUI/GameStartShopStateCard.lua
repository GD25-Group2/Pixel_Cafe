GameStartShopStateCard = class {__includes = BaseState}

function GameStartShopStateCard:init()
    self.isGUI = true
end

function GameStartShopStateCard:render()
    love.graphics.setColor(self.card.color)
    love.graphics.rectangle('fill', self.card.x, self.card.y, self.card.width, self.card.height, 6, 6)
    
    love.graphics.setColor(self.card.border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', self.card.x, self.card.y, self.card.width, self.card.height, 6, 6)
    
    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(gColors['white'])
    love.graphics.printf("Day " .. tostring(self.currentDate) .. " - Prep Your Stock!", self.card.x, self.card.y + 10, self.card.width, 'center')
    
    love.graphics.setFont(gFonts['small'])
    local timerText = "Shift Starts In: " .. math.ceil(self.timer) .. "s"
    if self.timer <= 3 then
        local pulse = math.abs(math.sin(self.timer * math.pi * 2))
        love.graphics.setColor(1, 0.4 + 0.6 * pulse, 0.4 + 0.6 * pulse, 1)
    end
    love.graphics.printf(timerText, self.card.x, self.card.y + 35, self.card.width, 'center')
    
    local innerX = self.card.x + 10
    local innerY = self.card.y + 60
    local innerW = self.card.width - 20
    local innerH = self.card.height - 90
    
    love.graphics.setColor(0.1, 0.12, 0.16, 1)
    love.graphics.rectangle('fill', innerX, innerY, innerW, innerH, 4, 4)
    love.graphics.setColor(0.2, 0.25, 0.35, 1)
    love.graphics.rectangle('line', innerX, innerY, innerW, innerH, 4, 4)
    
    love.graphics.setColor(1, 1, 1, 1)
end
    