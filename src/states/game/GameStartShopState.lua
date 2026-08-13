GameStartShopState = class{__includes = BaseState}

UPGRADE_PRICES = {
    CoffeeMachine = { 140, 380, 850 },
    Stove = { 160, 450, 1000 },
    PlateManager = { 100, 280, 650 }
}

MAX_MACHINE_LEVEL = 4

function StockManager:getUpgradePrice(machineType, currentLevel)
    currentLevel = currentLevel or self:getLevel(machineType) or 1
    if currentLevel >= MAX_MACHINE_LEVEL then
        return nil
    end
    
    local prices = UPGRADE_PRICES[machineType]
    if prices then
        return prices[currentLevel] or 9999
    end
    
    return 9999
end

local function find(list, name)
    if not list or type(list) ~= 'table' then return false end
    for i = 1, #list do
        if list[i] == name then
            return true
        end
    end
    return false
end

function GameStartShopState:init()
    self.priority = 0
    self.type = 'GameStartShopState'
    self.timer = 15
    
    local data = DataManager:getData() or {}
    self.currentDate = data['currentDate'] or 1
    local unlockedMachines = data['unlockedMachine'] or {}
    
    self.card = GAME_START_CONFIG

    self.cardEntity = GameStartShopStateCard(self)
    gStateStack:push(self.cardEntity)

    local menuItems = {
        { type = 'PaperCup',     name = 'Paper Cup',     price = 2,    category = 'Consumable', minDate = 1, requiredMachine = 'CoffeeMachine' },
        { type = 'CoffeeSeed',   name = 'Rotten Tooth',  price = 10,   category = 'Consumable', minDate = 1, requiredMachine = 'CoffeeMachine' },
        { type = 'Bread',        name = 'Revolting Loaf',price = 7.5,  category = 'Consumable', minDate = 1, requiredMachine = 'BreadBasket' },
        { type = 'Lettuce',      name = 'Lettuce',       price = 6,    category = 'Consumable', minDate = 2, requiredMachine = 'Lettuce' },
        { type = 'Meat',         name = 'Meat',          price = 10.5, category = 'Consumable', minDate = 3, requiredMachine = 'Stove' },
        
        { type = 'CoffeeMachine',name = 'Coffee Machine',category = 'Upgradable', minDate = 1, requiredMachine = 'CoffeeMachine' },
        { type = 'PlateManager', name = 'Plate',         category = 'Upgradable', minDate = 1, requiredMachine = 'BreadBasket' },
        { type = 'Stove',        name = 'Stove',         category = 'Upgradable', minDate = 3, requiredMachine = 'Stove' }
    }

    local validConsumables = {}
    local validUpgrades = {}

    for _, config in ipairs(menuItems) do
        local dateUnlocked = self.currentDate >= config.minDate
        local machineUnlocked = find(unlockedMachines, config.requiredMachine)

        if dateUnlocked and machineUnlocked then
            if config.category == 'Consumable' then
                table.insert(validConsumables, config)
            elseif config.category == 'Upgradable' then
                table.insert(validUpgrades, config)
            end
        end
    end

    local itemsToDisplay = {}
    local currentId = 0

    if #validConsumables > 0 then
        table.insert(itemsToDisplay, { type = 'Label', id = currentId, name = 'Consumable Items List', price = 0, purchasable = false, isConsumable = false })
        currentId = currentId + 1

        for _, item in ipairs(validConsumables) do
            table.insert(itemsToDisplay, {
                type = item.type,
                id = currentId,
                name = item.name,
                price = item.price,
                purchasable = true,
                isConsumable = true
            })
            currentId = currentId + 1
        end
    end

    if #validUpgrades > 0 then
        table.insert(itemsToDisplay, { type = 'Label', id = currentId, name = 'Upgradable Items List', price = 0, purchasable = false, isConsumable = false })
        currentId = currentId + 1

        for _, item in ipairs(validUpgrades) do
            local currentLvl = StockManager:getLevel(item.type) or 1
            table.insert(itemsToDisplay, {
                type = item.type,
                id = currentId,
                name = item.name,
                price = StockManager:getUpgradePrice(item.type, currentLvl),
                purchasable = currentLvl < MAX_MACHINE_LEVEL,
                isConsumable = false,
                level = currentLvl
            })
            currentId = currentId + 1
        end
    end
    
    self.items = {}
    self.interactables = {}
    
    self.scrollY = 0
    self.maxScrollY = math.max(0, #itemsToDisplay * 45 - 90)
    
    local stockTotals = StockManager:getStockTotal() or {}

    for _, itemData in ipairs(itemsToDisplay) do
        local currentData = {
            type = itemData.type,
            id = itemData.id,
            name = itemData.name,
            price = itemData.price,
            purchasable = itemData.purchasable,
            isConsumable = itemData.isConsumable,
            stock = stockTotals[itemData.type] or 0,
            level = itemData.level,
            
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

    self.moneyManager = MoneyManager(data['totalMoney'] or 0, data['todayMoney'] or 0)
    gStateStack:push(self.moneyManager)
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