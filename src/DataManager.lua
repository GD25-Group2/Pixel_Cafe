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

function DataManager:getDefaultData()
    self.data = {
        ['totalMoney'] = MONEY_CONFIG.startingMoney,
        ['todayMoney'] = 0,
        ['currentDate'] = 1,
        ['unlockedMachine'] = {
            'CoffeeMachine',
        },
        ['name'] = 'None',
        ['levelMachine'] = 1111, --[Coffee Machine, Bread Plate, Stove, PlateManager] from right to left
        ['stock'] = {
            ['CoffeeSeed'] = 2,
            ['Bread'] = 0,
            ['PaperCup'] = 10,
            ['Meat'] = 2,
            ['Lettuce'] = 1,
        },
        ['reputation'] = 50, --out of 100
    }
end

function DataManager:load(file)
    self.currentSlotFile = file or self.currentSlotFile or 'slot1.json'
    
    if love.filesystem.getInfo(self.currentSlotFile) then
        local contents, message = love.filesystem.read(self.currentSlotFile)
        if contents then 
            self.data = json.decode(contents)
            self:ensureUnlocks(self.data['currentDate'])
        else print(message) end
    end
end

function DataManager:create(file)
    self.currentSlotFile = file or self.currentSlotFile or 'slot1.json'
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

--[[function DataManager:moneyDataSave(totalMoney, todayMoney)
    self.data['totalMoney'] = totalMoney
    self.data['todayMoney'] = todayMoney
    print('DataManager - Today Money: ' .. tostring(self.data['todayMoney']) .. ' Total Money: ' .. tostring(self.data['totalMoney']))
end

function DataManager:dateDataSave(currentDate)
    self.data['currentDate'] = currentDate
end

function DataManager:nameDataSave(name)
    self.data['name'] = name
end]]

function DataManager:set(key, value)
    if self.data[key] ~= nil or type(key) == "string" then
        self.data[key] = value
    end
end

function DataManager:setAll(dataDict)
    for k, v in pairs(dataDict) do
        self.data[k] = v
    end
end

function DataManager:getData(requestedData)
    if requestedData then
        if type(requestedData) == "table" then
            local returnData = {}
            for i, key in ipairs(requestedData) do
                if self.data[key] ~= nil then
                    returnData[key] = self.data[key]
                end
            end
            return returnData
        else
            if self.data[requestedData] ~= nil then
                return self.data[requestedData]
            end
        end
    end
    return self.data
end

local dateDependentUnlock = {
    false,
    'BreadBasket',
    false,
    'Lettuce',
    false,
    'Stove'
}

function DataManager:autoUnlockMachine(day)
    local targetDay = day or self.data['currentDate']
    local machine = dateDependentUnlock[targetDay]
    print('Unlocked Machine:' .. tostring(machine))
    if machine then
        -- Check if already unlocked to avoid duplicates
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
    if self.data[variable] ~= nil then
        self.data[variable] = value
    end
end

function DataManager:saveOldData(data)
    self.oldData = data
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