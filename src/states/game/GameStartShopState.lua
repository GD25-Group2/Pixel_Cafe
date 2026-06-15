GameStartShopState = class{__includes = BaseState}

local menuItems = {
    { type = 'Label', id = 0, name = 'Consumable Items List', price = 0, purchasable = false },
    { type = 'PaperCup', id = 1, name = 'Paper Cup', price = 2, purchasable = true },
    { type = 'CoffeeSeed', id = 2, name = 'Rotten Tooth', price = 10, purchasable = true },
    { type = 'Bread', id = 3, name = 'Revolting Loaf', price = 5, purchasable = true },
    { type = 'Meat', id = 4, name = 'Meat', price = 5, purchasable = true },
    { type = 'Lettuce', id = 5, name = 'Lettuce', price = 5, purchasable = true },
    { type = 'Label', id = 6, name = 'Upgradable Items List', price = 0, purchasable = false },
    { type = 'CoffeeMachine', id = 7, name = 'Coffee Machine', price = 50, purchasable = false, level = 1 },
    { type = 'Stove', id = 8, name = 'Stove', price = 50, purchasable = false, level = 1 },
    { type = 'PlateManager', id = 9, name = 'Plate', price = 50, purchasable = false, level = 1 }
}

function GameStartShopState:init()
    self.type = 'GameStartShopState'
    self.timer = 15
    
    local data = DataManager:getData()
    self.currentDate = data and data['currentDate'] or 1
    
    self.card = GAME_START_CONFIG

    self.cardEntity = GameStartShopStateCard(self)
    gStateStack:push(self.cardEntity)
    
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
            level = data.level and (StockManager:getLevel(data.type) or 1) or nil,
            
            innerX = self.card.x + 10,
            innerY = self.card.y + 60,
            innerW = self.card.width - 20,
            innerH = self.card.height - 90
        }
        
        local item = ShopItem(currentData)
        table.insert(self.items, item)
        gStateStack:push(item)
        
        if item.type ~= 'Label' then
            local btn = item:getButton()
            gStateStack:push(btn)
            table.insert(self.interactables, btn)
        end
    end
    
    self.startShiftButton = Button(BUTTON_PARAMS['StartShift'])
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
    self.cardEntity:updateTimer(self.timer)
    
    if gWheelY and gWheelY ~= 0 then
        self.scrollY = math.max(0, math.min(self.maxScrollY, self.scrollY - gWheelY * 15))
        gWheelY = 0
    end
    
    local topLimit = self.card.y + 60
    local buffer = 5
    
    for i = 1, #self.items do
        local item = self.items[i]
        item:updateY(self.scrollY)
        
        if item.type ~= 'Label' then
            item:getButton():updateY(self.scrollY, item.id, item:getHeight(), buffer)
        end
        
        if item:getBottom() < topLimit and item.isVisible then
            item.isVisible = false
        elseif item:getBottom() >= topLimit and not item.isVisible then
            item.isVisible = true
        end
    end
    
    self:mouseResponse()
end