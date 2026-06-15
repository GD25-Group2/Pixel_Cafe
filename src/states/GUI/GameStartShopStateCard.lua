GameStartShopStateCard = class {__includes = BaseState}

function GameStartShopStateCard:init(shopState)
    self.isGUI = true
    self.shopState = shopState
end

function GameStartShopStateCard:updateTimer(timer)
    self.shopState.timer = timer
end

function GameStartShopStateCard:render()
    local state = self.shopState
    if not state then return end
    
    local card = state.card

    -- Outer background setup
    love.graphics.setColor(card.color)
    love.graphics.rectangle('fill', card.x, card.y, card.width, card.height, 6, 6)
    
    love.graphics.setColor(card.border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', card.x, card.y, card.width, card.height, 6, 6)
    
    -- Header titles using parent state context values
    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(gColors['white'])
    love.graphics.printf("Day " .. tostring(state.currentDate) .. " - Prep Your Stock!", card.x, card.y + 10, card.width, 'center')
    
    love.graphics.setFont(gFonts['small'])
    local timerText = "Shift Starts In: " .. math.ceil(state.timer) .. "s"
    if state.timer <= 3 then
        local pulse = math.abs(math.sin(state.timer * math.pi * 2))
        love.graphics.setColor(1, 0.4 + 0.6 * pulse, 0.4 + 0.6 * pulse, 1)
    end
    love.graphics.printf(timerText, card.x, card.y + 35, card.width, 'center')
    
    -- Inner display bounding box panel configuration
    local innerX = card.x + 10
    local innerY = card.y + 60
    local innerW = card.width - 20
    local innerH = card.height - 90
    
    love.graphics.setColor(0.1, 0.12, 0.16, 1)
    love.graphics.rectangle('fill', innerX, innerY, innerW, innerH, 4, 4)
    love.graphics.setColor(0.2, 0.25, 0.35, 1)
    love.graphics.rectangle('line', innerX, innerY, innerW, innerH, 4, 4)
    
    love.graphics.setColor(1, 1, 1, 1)
end