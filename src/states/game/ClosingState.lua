ClosingState = class{__includes = BaseState}

function ClosingState:init(customerManager)
    self.priority = 0
    self.customerManager = customerManager
end

function ClosingState:enter()
    if self.customerManager then
        self.customerManager:forceExitAll()
    end
end

function ClosingState:update(dt)
    if self.customerManager then
        if self.customerManager:isEmpty() then
            if DataManager:getData('name') == 'special' and DataManager:getData('currentDate') == 3 then
                local todayMoney = DataManager:getData('todayMoney')
                local challengeBar = WIN_CONDITION_MONEY
                if todayMoney >= challengeBar then
                    gStateStack:clear()
                    gStateStack:push(GameWinConditionDecide())
                else
                    gStateStack:clear()
                    gStateStack:push(GameOver('You Lose'))
                end
            else
                gStateStack:clear()
                gStateStack:push(DayEndState())
            end
        end
    end
end

function ClosingState:render()
    local t = love.timer.getTime()
    local pulse = (math.sin(t * 3) + 1) / 2
    
    local bannerW = 220
    local bannerH = 28
    local bannerX = (VIRTUAL_WIDTH - bannerW) / 2
    local bannerY = 22
    
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle('fill', bannerX + 2, bannerY + 2, bannerW, bannerH, 2)
    
    love.graphics.setColor(0.05, 0.05, 0.1, 0.9)
    love.graphics.rectangle('fill', bannerX, bannerY, bannerW, bannerH, 2)
    
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 0.2, 0.2, 0.3 + 0.7 * pulse)
    love.graphics.rectangle('line', bannerX, bannerY, bannerW, bannerH, 2)
    
    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("STORE CLOSED", bannerX, bannerY + 4, bannerW, 'center')
    
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0.8, 0.8, 0.8, 0.8 + 0.2 * pulse)
    love.graphics.printf("All customers are leaving...", bannerX, bannerY + 16, bannerW, 'center')
    
    love.graphics.setColor(1, 1, 1, 1)
end
