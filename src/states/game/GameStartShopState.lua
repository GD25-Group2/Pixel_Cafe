GameStartShopState = class{__includes = BaseState}

UPGRADE_PRICES = {
    CoffeeMachine = { 140, 380, 850, },
    Stove = { 160, 450, 1000, },
    PlateManager = { 100, 280, 650, }
}

MAX_MACHINE_LEVEL = 4

local function GetUpgradePrice(machineType, currentLevel)
    if currentLevel >= MAX_MACHINE_LEVEL then
        return nil
    end
    
    local machinePrices = UPGRADE_PRICES[machineType]
    if machinePrices then
        return machinePrices[currentLevel] or 9999
    end
    
    return 9999
end

local function find(list, name)
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
    
    local data = DataManager:getData()
    self.currentDate = data and data['currentDate'] or 1
    
    self.card = GAME_START_CONFIG

    self.cardEntity = GameStartShopStateCard(self)
    gStateStack:push(self.cardEntity)

    local coffeeLvl = StockManager:getLevel('CoffeeMachine') or 1
    local stoveLvl  = StockManager:getLevel('Stove') or 1
    local plateLvl  = StockManager:getLevel('PlateManager') or 1

    local menuItems = {
        { type = 'PaperCup', name = 'Paper Cup', price = 2, category = 'Consumable', minDate = 1, requiredMachine = 'CoffeeMachine' },
        { type = 'CoffeeSeed', name = 'Rotten Tooth', price = 10, category = 'Consumable', minDate = 1, requiredMachine = 'CoffeeMachine' },
        { type = 'Bread', name = 'Revolting Loaf', price = 7.5, category = 'Consumable', minDate = 1, requiredMachine = 'BreadBasket' },
        { type = 'Lettuce', name = 'Lettuce', price = 6, category = 'Consumable', minDate = 2, requiredMachine = 'Lettuce' },
        { type = 'Meat', name = 'Meat', price = 10.5, category = 'Consumable', minDate = 3, requiredMachine = 'Stove' },
        { type = 'CoffeeMachine', name = 'Coffee Machine', category = 'Upgradable', minDate = 1, requiredMachine = 'CoffeeMachine' },
        { type = 'PlateManager', name = 'Plate', category = 'Upgradable', minDate = 1, requiredMachine = 'BreadBasket' },
        { type = 'Stove', name = 'Stove', category = 'Upgradable', minDate = 3, requiredMachine = 'Stove' }
    }

    local validConsumables = {}
    local validUpgrades = {}

    for _, config in ipairs(menuItems) do
        local dateUnlocked = self.currentDate >= config.minDate
        local machineUnlocked = find(data['unlockedMachine'], config.requiredMachine)

        if dateUnlocked and machineUnlocked then
            if config.category == 'Consumable' then
                table.insert(validConsumables, config)
            elseif config.category == 'Upgradable' then
                table.insert(validUpgrades, config)
            end
        end
    end

    local menuItems = {}
    local currentId = 0

    if #validConsumables > 0 then
        table.insert(menuItems, { type = 'Label', id = currentId, name = 'Consumable Items List', price = 0, purchasable = false })
        currentId = currentId + 1

        for _, item in ipairs(validConsumables) do
            table.insert(menuItems, {
                type = item.type,
                id = currentId,
                name = item.name,
                price = item.price,
                purchasable = true
            })
            currentId = currentId + 1
        end
    end

    if #validUpgrades > 0 then
        table.insert(menuItems, { type = 'Label', id = currentId, name = 'Upgradable Items List', price = 0, purchasable = false })
        currentId = currentId + 1

        for _, item in ipairs(validUpgrades) do
            local currentLvl = StockManager:getLevel(item.type) or 1
            table.insert(menuItems, {
                type = item.type,
                id = currentId,
                name = item.name,
                price = GetUpgradePrice(item.type, currentLvl),
                purchasable = currentLvl < MAX_MACHINE_LEVEL,
                level = currentLvl
            })
            currentId = currentId + 1
        end
    end
    
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