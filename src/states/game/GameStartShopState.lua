GameStartShopState = class{__includes = BaseState}

local menuItems = {
    { type = 'Label', id = 0, name = 'Consumable Items List', price = 0, purchasable = false },
    { type = 'PaperCup', id = 1, name = 'Paper Cup', price = 2, purchasable = true },
    { type = 'CoffeeSeed', id = 2, name = 'Rotten Tooth', price = 10, purchasable = true },
    { type = 'Bread', id = 3, name = 'Revolting Loaf', price = 5, purchasable = true },
    { type = 'Meat', id = 4, name = 'Meat', price = 5, purchasable = true },
    { type = 'Label', id = 5, name = 'Upgradable Items List', price = 0, purchasable = false },
    { type = 'CoffeeMachine', id = 6, name = 'Coffee Machine', price = 50, purchasable = false, level = 1 },
    { type = 'Stove', id = 7, name = 'Stove', price = 50, purchasable = false, level = 1 },
    { type = 'PlateManager', id = 8, name = 'Plate', price = 50, purchasable = false, level = 1 }
}

function GameStartShopState:init()
    self.type = 'GameStartShopState'
    self.timer = 15
    
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
    self.interactables = {}
    
    self.scrollY = 0
    self.maxScrollY = math.max(0, #menuItems * 45 - 90)
    
    for _, data in ipairs(menuItems) do
        local currentData = {
            type = data.type,
            id = data.id,
            name = data.name,
            price = data.price,
            purchasable = data.purchasable,
            stock = StockManager:getStockTotal()[data.type] or 0,
            level = data.level and (StockManager:getLevel(data.type) or 1) or nil
        }
        
        local item = ShopItem(currentData, self.card)
        table.insert(self.items, item)
        gStateStack:push(item)
        
        if item.type ~= 'Label' then
            local btn = item:getButton()
            gStateStack:push(btn)
            table.insert(self.interactables, btn)
        end
    end
    
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
    gStateStack:push(self.startShiftButton)
    table.insert(self.interactables, self.startShiftButton)
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
    
    for i = 1, #self.items do
        local item = self.items[i]
        item:updateY(self.scrollY)
        
        if item.type ~= 'Label' and item.button then
            item.button:updateY(self.scrollY, item.id, item.height, 5)
            
            if item:getBottom() < innerY and item.isVisible then
                item.isVisible = false
                item.button:disable()
            elseif item:getBottom() >= innerY and item.y <= innerY + innerH and not item.isVisible then
                item.isVisible = true
                if item.purchasable or item.level < 3 then 
                    item.button:enable() 
                end
            elseif item.y > innerY + innerH and item.isVisible then
                item.isVisible = false
                item.button:disable()
            end
        end
    end
    
    self:mouseResponse()
end

function GameStartShopState:render()
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