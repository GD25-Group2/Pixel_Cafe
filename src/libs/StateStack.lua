--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
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
    if self.isPopup then
        self.popupTable = {}
    elseif self.paused then
        self.pausedTable = {}
    else
        self.states = {}
    end
end

function StateStack:push(state)
    if self.isPopup then
        table.insert(self.popupTable, state)
    elseif self.paused then
        table.insert(self.pausedTable, state)
    else
        table.insert(self.states, state)
    end
    state:enter()
end

function StateStack:pop(target)
    local popTable
    if self.isPopup then popTable = self.popupTable
    elseif self.paused then popTable = self.pausedTable
    else popTable = self.states end

    if #popTable > 0 then
        if target then
            for i = #popTable, 1, -1 do
                local current = popTable[i]
                
                if current == target or 
                   getmetatable(current) == target or 
                   current.type == target then
                   
                    current:exit()
                    table.remove(popTable, i)
                    break
                end
            end
        else
            popTable[#popTable]:exit()
            table.remove(popTable)
        end
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