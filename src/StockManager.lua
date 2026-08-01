local StockManager = {}
setmetatable(StockManager, StockManager)

function StockManager:load()
    self.stock = DataManager:getData('stock')
    self.levelMachine = DataManager:getData('levelMachine')
end

local function deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = deepCopy(orig_value)
        end
    else -- primitive types like numbers, strings, booleans
        copy = orig
    end
    return copy
end

function StockManager:saveOldData()
    self.oldData = {deepCopy(self.stock), deepCopy(self.levelMachine)}
end

function StockManager:restart()
    self.stock = deepCopy(self.oldData[1])
    self.levelMachine = deepCopy(self.oldData[2])
end

local countingTable = {
    'CoffeeMachine',
    'BreadPlate',
    'Stove',
    'PlateManager',
}

local function getDigit(number, placeholder)
    local digitPlace = 1
    for i = 1, placeholder - 1 do
        digitPlace = digitPlace * 10
    end

    return math.floor((number / digitPlace) % 10)
end

function StockManager:getLevel(machine)
    if machine then
        local placeholder
        for index, value in pairs(countingTable) do
            if machine == value then placeholder = index end
        end

        if placeholder then
            return getDigit(self.levelMachine, placeholder)
        end
    end
end

function StockManager:upgrade(machine, price)
    if machine then
        local placeholder
        for index, value in pairs(countingTable) do
            if machine == value then placeholder = index end
        end

        if placeholder then
            local currentLevel = getDigit(self.levelMachine, placeholder)
            if currentLevel < 3 then
                local currentMoney = DataManager:getData('totalMoney')
                if currentMoney and price and currentMoney >= price then
                    DataManager:modify('totalMoney', currentMoney - price)
                end
                self.levelMachine = self.levelMachine + (1 * (10 ^ (placeholder - 1)))
                DataManager:modify('levelMachine', self.levelMachine)
                if machine == 'PlateManager' then Signal:emit('plate-manager-plate-add') end
            end
        end
    end
end

function StockManager:getStockTotal()
    return self.stock
end

function StockManager:consume(consumable)
    if consumable then
        if self.stock[consumable] and self.stock[consumable] > 0 then
            self.stock[consumable] = self.stock[consumable] - 1
            DataManager:modify('stock', self.stock)
            return self.stock[consumable]
        end
    end
end

function StockManager:purchase(consumable, price)
    if consumable then
        if self.stock[consumable] ~= nil then
            self.stock[consumable] = self.stock[consumable] + 1
            local currentMoney = DataManager:getData('totalMoney')
            if currentMoney and price and currentMoney >= price then
                DataManager:modify('totalMoney', currentMoney - price)
            end
            DataManager:modify('stock', self.stock)
            return self.stock[consumable]
        end
    end
end

function StockManager:loot(consumable)
    if self.stock[consumable] ~= nil then
        self.stock[consumable] = self.stock[consumable] + 1
        DataManager:modify('stock', self.stock)
    end
end

return StockManager