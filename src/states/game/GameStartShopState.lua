GameStartShopState = class{__includes = BaseState}

local itemsData = {
    ['PaperCup'] = { type = 'PaperCup', name = 'Paper Cup', price = 2, purchasable = true },
    ['CoffeeSeed'] = { type = 'CoffeeSeed', name = 'Rotten Tooth', price = 10, purchasable = true },
    ['Bread'] = { type = 'Bread', name = 'Revolting Loaf', price = 5, purchasable = true },
    ['CoffeeMachine'] = { type = 'CoffeeMachine', name = 'Coffee Machine', price = 50, purchasable = false, level = 1 },
}

function GameStartShopState:init()
    self.type = 'GameStartShopState'
    self.timer = 15 -- 15 seconds countdown
    
    local data = DataManager:getData()
    self.currentDate = data and data['currentDate'] or 1
    
    self.card = {
        width = 320,
        height = 190,
        x = math.floor(VIRTUAL_WIDTH / 2 - 160),
        y = math.floor(VIRTUAL_HEIGHT / 2 - 95),
        color = {0.14, 0.16, 0.22, 1},
        border = {0.4, 0.5, 0.6, 1},
    }
    
    self.items = {}
    local i = 0
    for name, v in pairs(itemsData) do
        local stock = StockManager:getStockTotal()[name] or 0
        local price = v.price
        local level = v.purchasable and 0 or StockManager:getLevel(name)
        if not v.purchasable and level then
            price = price * (2 ^ (level - 1))
        end
        
        table.insert(self.items, {
            id = i,
            name = v.name,
            type = v.type,
            price = price,
            stock = stock,
            purchasable = v.purchasable,
            level = level,
        })
        i = i + 1
    end
    
    -- Ensure items are sorted so they don't randomly shuffle
    table.sort(self.items, function(a, b) return a.id < b.id end)
    
    self.scrollY = 0
    self.maxScrollY = math.max(0, #self.items * 45 - 90)
    
    self.buttons = {}
    self.interactables = {}
    
    -- Start Shift button at the bottom
    self.startShiftButton = Button({
        text = 'Start Shift',
        x = self.card.x + self.card.width / 2 - 40,
        y = self.card.y + self.card.height - 25,
        desired_width = 80,
        desired_height = 20,
        action = function()
            gStateStack:clear()
            gStateStack:resume()
        end,
        clickable = true,
        defaultColor = gColors['white'],
        hoverColor = gColors['yellow'],
    })
    table.insert(self.interactables, self.startShiftButton)
    
    -- Purchase buttons for items
    for idx, item in ipairs(self.items) do
        local btn = Button({
            text = item.purchasable and 'Purchase' or 'Upgrade',
            x = self.card.x + self.card.width - 80,
            y = 0, 
            desired_width = 60,
            desired_height = 18,
            action = function()
                local totalMoney = DataManager:getData('totalMoney') or 0
                if item.purchasable and totalMoney >= item.price then
                    item.stock = StockManager:purchase(item.type, item.price)
                elseif not item.purchasable and item.level < 3 and totalMoney >= item.price then
                    StockManager:upgrade(item.type, item.price)
                    item.level = item.level + 1
                    item.price = item.price * 2
                end
            end,
            clickable = true,
            defaultColor = gColors['white'],
            hoverColor = gColors['yellow'],
        })
        table.insert(self.buttons, btn)
        table.insert(self.interactables, btn)
    end
end

function GameStartShopState:update(dt)
    self.timer = self.timer - dt
    if self.timer <= 0 then
        gStateStack:clear()
        gStateStack:resume()
        return
    end
    
    if gWheelY and gWheelY ~= 0 then
        self.scrollY = math.max(0, math.min(self.maxScrollY, self.scrollY - gWheelY * 15))
        gWheelY = 0
    end
    
    local innerY = self.card.y + 60
    local innerH = self.card.height - 90
    local itemHeight = 45
    
    for idx, btn in ipairs(self.buttons) do
        local itemY = innerY + 5 + (idx - 1) * itemHeight - self.scrollY
        btn.y = itemY + 10
        
        -- Disable clicking if button is outside the scroll view
        if itemY >= innerY - 20 and itemY + 40 <= innerY + innerH + 20 then
            btn:enable()
        else
            btn:disable()
        end
    end
    
    self:mouseResponse()
end

function GameStartShopState:render()
    -- outer card
    love.graphics.setColor(self.card.color)
    love.graphics.rectangle('fill', self.card.x, self.card.y, self.card.width, self.card.height, 6, 6)
    
    love.graphics.setColor(self.card.border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', self.card.x, self.card.y, self.card.width, self.card.height, 6, 6)
    
    -- Title Text
    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(gColors['white'])
    love.graphics.printf("Day " .. tostring(self.currentDate) .. " - Prep Your Stock!", self.card.x, self.card.y + 10, self.card.width, 'center')
    
    -- Timer Text
    love.graphics.setFont(gFonts['small'])
    local timerText = "Shift Starts In: " .. math.ceil(self.timer) .. "s"
    if self.timer <= 3 then
        local pulse = math.abs(math.sin(self.timer * math.pi * 2))
        love.graphics.setColor(1, 0.4 + 0.6 * pulse, 0.4 + 0.6 * pulse, 1)
    end
    love.graphics.printf(timerText, self.card.x, self.card.y + 35, self.card.width, 'center')
    
    -- Inner Container for items
    local innerX = self.card.x + 10
    local innerY = self.card.y + 60
    local innerW = self.card.width - 20
    local innerH = self.card.height - 90
    
    love.graphics.setScissor(innerX, innerY, innerW, innerH)
    
    -- Items Background
    love.graphics.setColor(0.1, 0.12, 0.16, 1)
    love.graphics.rectangle('fill', innerX, innerY, innerW, innerH, 4, 4)
    love.graphics.setColor(0.2, 0.25, 0.35, 1)
    love.graphics.rectangle('line', innerX, innerY, innerW, innerH, 4, 4)
    
    local itemHeight = 45
    for idx, item in ipairs(self.items) do
        local itemY = innerY + 5 + (idx - 1) * itemHeight - self.scrollY
        
        -- Background of single row
        love.graphics.setColor(0.12, 0.15, 0.2, 1)
        love.graphics.rectangle('fill', innerX + 5, itemY, innerW - 10, 40, 4, 4)
        
        love.graphics.setColor(gColors['white'])
        love.graphics.setFont(gFonts['small'])
        love.graphics.printf("Name: " .. item.name, innerX + 15, itemY + 5, innerW, 'left')
        
        if item.purchasable then
            love.graphics.printf("Price: " .. item.price, innerX + 15, itemY + 20, innerW, 'left')
            love.graphics.printf("Owned: " .. item.stock, innerX + 100, itemY + 20, innerW, 'left')
        else
            love.graphics.printf("Price: " .. item.price, innerX + 15, itemY + 20, innerW, 'left')
            love.graphics.printf("Level: " .. item.level, innerX + 100, itemY + 20, innerW, 'left')
        end
        
        local btn = self.buttons[idx]
        if btn then
            btn:render()
        end
    end
    
    love.graphics.setScissor() -- Clear scissor
    
    -- Draw bottom button
    self.startShiftButton:render()
    
    love.graphics.setColor(1, 1, 1, 1)
end
