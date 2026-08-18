--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

--[[
Priority List

game state          -> 0
guide game          -> 1
background          -> 5
non-display entity  -> 10
card                -> 15
shop item           -> 20
customer            -> 25
customer gui        -> 35
counter             -> 50
kitchen ware shadow -> 60
kitchen ware        -> 75
ui showcase entity  -> 85
button              -> 95
guide curtain       -> 96
textbox             -> 97
visual effect       -> 98
guide               -> 99
cursor              -> 100
]]

StateStack = class{}

function StateStack:init()
    self.states = {}
    self.paused = false
    self.pausedTable = {}
    self.isPopup = false
    self.popupTable = {}
end

function StateStack:update(dt)
    local updateTable
    if self.isPopup then updateTable = self.popupTable
    elseif self.paused then updateTable = self.pausedTable
    else updateTable = self.states
    end

    for i = #updateTable, 1, -1 do
        local state = updateTable[i]
        if state then
            state:update(dt)
        end
    end
end

function StateStack:processAI(params, dt)
    -- Only process AI on the active state and only if it defines processAI.
    if #self.states > 0 and self.states[#self.states].processAI then
        self.states[#self.states]:processAI(params, dt)
    end
end

local function renderTable(givenTable)
    for i, state in ipairs(givenTable) do
        love.graphics.setColor(gColors['white'])
        state:render()
    end

    -- Overlay Layer for bubbles 
    for i, state in ipairs(givenTable) do
        if state.renderBubble then
            love.graphics.setColor(gColors['white'])
            state:renderBubble()
        end
    end
end

function StateStack:render()
    renderTable(self.states)

    if self.paused then
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
        love.graphics.setColor(gColors['white'])

        renderTable(self.pausedTable)
    end

    renderTable(self.popupTable)
end

function StateStack:clear()
    local tbl
    if self.isPopup then
        tbl = self.popupTable
    elseif self.paused then
        tbl = self.pausedTable
    else
        tbl = self.states
    end
    for i = #tbl, 1, -1 do
        local state = tbl[i]
        if state and state.exit then
            state:exit()
        end
        tbl[i] = nil
    end
end

local function bubbleSort(arr)
    local n = #arr
    for i = 1, n - 1 do
        for j = 1, n - i do
            local p1 = arr[j].priority or 0
            local p2 = arr[j + 1].priority or 0
            if p1 > p2 then
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
            end
        end
    end
end

function StateStack:push(state)
    local target
    if self.isPopup then
        target = self.popupTable
        table.insert(target, state)
    elseif self.paused then
        target = self.pausedTable
        table.insert(target, state)
    else
        target = self.states
        table.insert(target, state)
    end
    bubbleSort(target)
    state:enter()
end

function StateStack:pop(target, signalName, ...)
    local tablesToSearch = { self.popupTable, self.pausedTable, self.states }
    
    if target then
        local found = false
        for _, popTable in ipairs(tablesToSearch) do
            for i = #popTable, 1, -1 do
                local current = popTable[i]
                if current == target or getmetatable(current) == target or current.type == target then
                    current:exit()
                    table.remove(popTable, i)
                    bubbleSort(popTable)
                    found = true
                    break
                end
            end
            if found then break end
        end
    else
        local popTable = self.isPopup and self.popupTable or (self.paused and self.pausedTable or self.states)
        if #popTable > 0 then
            local state = popTable[#popTable]
            if state and state.exit then state:exit() end
            table.remove(popTable)
            bubbleSort(popTable)
        end
    end

    if signalName then
        Signal:emit(signalName, ...)
    end
end

function StateStack:pause()
    self.paused = true
    print('Pause Stack')
end

function StateStack:resume()
    self.paused = false
    print('Normal Stack')
end

function StateStack:popupCreate()
    self.isPopup = true
    print('Popup Stack')
end

function StateStack:popupDelete()
    self.isPopup = false
end

function StateStack:removeType(targetType)
    local tablesToSearch = { self.popupTable, self.pausedTable, self.states }

    for _, tbl in ipairs(tablesToSearch) do
        for i = #tbl, 1, -1 do
            local current = tbl[i]
            if current and (current == targetType or current.type == targetType) then
                if current.exit then
                    current:exit()
                end
                table.remove(tbl, i)
            end
        end
        bubbleSort(tbl)
    end
end