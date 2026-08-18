--[[
How to use manual

When adding new data to store, just add a new function with the current convention (e.g; moneyDataSave, dateDataSave,..).
If in the later updates, the current storing function is deemed inflexible, noted that it might be changed to a unify one.

You can use getData function from anywhere starting from constants dependency level.
To use getData function, if you call it with no argument, you will get the whole table of self.data.
If you pass a table as an argument (such as {'totalMoney', 'todayMoney'}), you will get only that value.
If you pass a single string, you will get only that value.

By updating, dateDependentUnlock table, new machines can be added easily to create more content.
]]
local DataManager = {}
setmetatable(DataManager, DataManager)

local dateDependentUnlock = {
    false,
    'ChoppingBoard',
    'BreadBasket',
    false,
    false,
    'Stove'
}

function DataManager:getDefaultData()
    return {
        ['totalMoney'] = MONEY_CONFIG and MONEY_CONFIG.startingMoney or 50,
        ['todayMoney'] = 0,
        ['currentDate'] = 1,
        ['unlockedMachine'] = {
            'CoffeeMachine',
        },
        ['name'] = 'None',
        ['levelMachine'] = 11111, -- [Coffee Machine, Bread Plate, Stove, PlateManager, Chopping Board] from right to left
        ['stock'] = {
            ['CoffeeSeed'] = 2,
            ['Bread'] = 2,
            ['PaperCup'] = 10,
            ['Meat'] = 2,
            ['Lettuce'] = 1,
        },
        ['reputation'] = 50, -- out of 100
        ['guidePhase'] = 1,
        ['shopDone'] = false,
        ['specialFreeze'] = true
    }
end

function DataManager:initDefaults()
    self.data = self:getDefaultData()
end

function DataManager:ensureDefaults()
    if not self.data then
        self:initDefaults()
        return
    end

    local defaults = self:getDefaultData()
    for k, v in pairs(defaults) do
        if self.data[k] == nil then
            self.data[k] = v
        end
    end
end

function DataManager:load(file)
    self.currentSlotFile = file or self.currentSlotFile or 'slot1.json'
    
    if love.filesystem.getInfo(self.currentSlotFile) then
        local contents, message = love.filesystem.read(self.currentSlotFile)
        if contents then 
            self.data = json.decode(contents)
            self:ensureDefaults() -- Automatically patch missing fields from old save files
            self:ensureUnlocks(self.data['currentDate'])
        else 
            print(message) 
        end
    else
        self:initDefaults()
    end
end

function DataManager:create(file)
    self.currentSlotFile = file or self.currentSlotFile or 'slot1.json'
    if not self.data then self:initDefaults() end
    
    local contents = json.encode(self.data)
    local success, message = love.filesystem.write(self.currentSlotFile, contents)
    if success then print(message) end
end

function DataManager:loadSettings(file)
    local targetFile = file or SETTING_FILE
    if love.filesystem.getInfo(targetFile) then
        local contents, message = love.filesystem.read(targetFile)
        if contents then
            local loadedSettings = json.decode(contents)
            if loadedSettings then
                for k, v in pairs(loadedSettings) do
                    gSettings[k] = v
                end
                print("Settings loaded successfully.")
            end
        else print(message) end
    else
        self:saveSettings(targetFile)
    end
end

function DataManager:saveSettings(file)
    local targetFile = file or SETTING_FILE
    local contents = json.encode(gSettings)
    love.filesystem.write(targetFile, contents)
    print("Settings saved permanently.")
end

function DataManager:set(key, value)
    if not self.data then self:initDefaults() end
    self.data[key] = value
end

function DataManager:setAll(dataDict)
    if not self.data then self:initDefaults() end
    for k, v in pairs(dataDict) do
        self.data[k] = v
    end
end

function DataManager:getData(requestedData)
    if not self.data then self:initDefaults() end

    if requestedData ~= nil then
        if type(requestedData) == "table" then
            local returnData = {}
            for _, key in ipairs(requestedData) do
                returnData[key] = self.data[key]
            end
            return returnData
        else
            return self.data[requestedData]
        end
    end
    return self.data
end

function DataManager:autoUnlockMachine(day)
    local targetDay = day or self.data['currentDate']
    local machine = dateDependentUnlock[targetDay]
    if machine then
        local alreadyUnlocked = false
        for _, m in ipairs(self.data['unlockedMachine']) do
            if m == machine then
                alreadyUnlocked = true
                break
            end
        end
        
        if not alreadyUnlocked then
            table.insert(self.data['unlockedMachine'], machine)
        end
    end
end

function DataManager:ensureUnlocks(targetDay)
    for i = 1, targetDay do
        self:autoUnlockMachine(i)
    end
end

function DataManager:modify(variable, value)
    if not self.data then self:initDefaults() end
    if self.data[variable] ~= nil then
        self.data[variable] = value
    end
end

local function deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = deepCopy(orig_value)
        end
    else
        copy = orig
    end
    return copy
end

function DataManager:saveOldData()
    self.oldData = deepCopy(self.data)
    if StockManager and StockManager.saveOldData then
        StockManager:saveOldData()
    end
end

function DataManager:restart()
    local phase = self.data and self.data['guidePhase'] == -1 and -1 or (self.data and self.data['guidePhase'] or 1)
    self.data = deepCopy(self.oldData or self:getDefaultData())
    self.data['guidePhase'] = phase
    if StockManager and StockManager.restart then
        StockManager:restart()
    end
end

function DataManager:destroy()
    local fileToDelete = self.currentSlotFile or 'slot1.json'
    love.filesystem.remove(fileToDelete)
end

function DataManager:getSlotMetadata(file)
    if love.filesystem.getInfo(file) then
        local contents = love.filesystem.read(file)
        if contents then
            local decoded = json.decode(contents)
            if decoded then
                return {
                    name = decoded.name or 'None',
                    currentDate = decoded.currentDate or 1,
                    totalMoney = decoded.totalMoney or 0
                }
            end
        end
    end
    return nil
end

return DataManager