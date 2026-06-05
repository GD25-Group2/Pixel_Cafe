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
        ['levelMachine'] = 11, --[Coffee Machine, Bread Plate] from right to left
        ['stock'] = {
            ['CoffeeSeed'] = 2,
            ['Bread'] = 1,
            ['PaperCup'] = 10,
        },
        ['reputation'] = 50, --out of 100
    }
end

function DataManager:load()
    if love.filesystem.getInfo(SAVE_FILE) then
        local contents, message = love.filesystem.read(SAVE_FILE)
        if contents then 
            self.data = json.decode(contents)
            self:ensureUnlocks(self.data['currentDate'])
        else print(message) end
    end
end

function DataManager:create()
    local contents = json.encode(self.data)
    local success, message = love.filesystem.write(SAVE_FILE, contents)
    if success then print(message) end
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
    'BreadPlate',
    false,
    'SandwichPlate',
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

return DataManager