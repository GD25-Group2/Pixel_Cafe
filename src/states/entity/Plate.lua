-- src/states/entity/Plate.lua
Plate = class{__includes = BaseEntity}

local supply_yield_table = {
    ['SlicedBread']      = 'SliceOfBread',
    ['ChoppedMeat']      = 'Meat',
    ['ChoppedVegetable'] = 'Vegetable'
}

--[[
'DisposableCoffeeCup'
'Coffee'
'LoafOfBread'
'SlicedBread'
'Meat'
'ChoppedMeat'
'Vegetable'
'ChoppedVegetable'
'FreeSandwich'
'Meat'
'MeatSandwich'
'DeluxeSandwich'
]]

function Plate:init(params)
    BaseEntity.init(self, params)

    self.type = 'Plate'
    self.productionStage = 'Void'

    self.mode = 'Empty'
    self.heldItems = {}
    self.supplySourceItem = nil
    self.count = 0
    self.maxCapacity = 4

    self.heldItem = 'None'
    self.color = gColors['green']
    self._bubbleColor = gColors['green']
end

function Plate:update(dt)
    if self.productionStage == 'Void' then
        self.color = gColors['green']
    elseif self.productionStage == 'Holding' then
        self.color = gColors['blue']
    elseif self.productionStage == 'Ready' then
        self.color = gColors['green']
    end

    BaseEntity.update(self, dt)

    if self.heldItem == nil then self.heldItem = 'None' end
end

function Plate:render()
    BaseEntity.render(self)

    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', self.x, self.y, self.desired_width, self.desired_height)

    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(gColors['white'])
    
    local text = ""
    if self.mode == 'Supply' and self.count > 0 then
        text = string.format("Slices: %d", self.count)
    elseif self.mode == 'Assembly' and self.productionStage == 'Ready' then
        text = self.currentOutput or "Assembling..."
    end

    if text ~= "" then
        local tw = gFonts['small']:getWidth(text)
        love.graphics.print(text, self.x + self.desired_width / 2 - tw / 2, self.y + self.desired_height / 2)
    end
end

function Plate:receiveItem(item, source)
    if self.mode == 'Empty' then
        if supply_yield_table[item] then
            self.mode = 'Supply'
            self.supplySourceItem = item
            self.count = 3
            self.productionStage = 'Ready'
            self.heldItem = supply_yield_table[item]
            return true
        else
            self.mode = 'Assembly'
            table.insert(self.heldItems, item)
            self:evaluateRecipes()
            return true
        end
    end

    if self.mode == 'Assembly' and #self.heldItems < self.maxCapacity then
        table.insert(self.heldItems, item)
        self:evaluateRecipes()
        return true
    end

    return false
end

function Plate:evaluateRecipes()
    local hasBread = false
    local hasMeat = false
    local hasVeg = false

    for _, v in ipairs(self.heldItems) do
        if v == 'SliceOfBread'     then hasBread = true end
        if v == 'Meat' or v == 'ChoppedMeat' then hasMeat = true end
        if v == 'Vegetable'        then hasVeg = true end
    end

    if hasBread and hasMeat and hasVeg then
        self.currentOutput = 'DeluxeSandwich'
    elseif hasBread and hasMeat then
        self.currentOutput = 'MeatSandwich'
    elseif hasBread then
        self.currentOutput = 'FreeSandwich'
    elseif hasMeat then
        self.currentOutput = 'Meat'
    end

    if not self.currentOutput then return end

    self.productionStage = 'Ready'
    self.heldItem = self.currentOutput
end

function Plate:drag()
    self.productionStage = 'Holding'

    if self.mode == 'Supply' then
        self.heldItem = supply_yield_table[self.supplySourceItem]
    elseif self.mode == 'Assembly' then
        self.heldItem = self.currentOutput
    end
    
    self:hideBubble()
end

function Plate:undrag()
    if self.count > 0 or #self.heldItems > 0 then
        self.productionStage = 'Ready'

        if self.mode == 'Supply' then
            self.heldItem = supply_yield_table[self.supplySourceItem]
        elseif self.mode == 'Assembly' then
            self.heldItem = self.currentOutput
        end
    else
        self.productionStage = 'Void'
        self.heldItem = 'None'
    end
end

function Plate:taken()
    if self.mode == 'Supply' then
        self.count = self.count - 1
        if self.count <= 0 then
            self:resetPlate()
        else
            self.productionStage = 'Ready'
            self.heldItem = supply_yield_table[self.supplySourceItem]
        end
    elseif self.mode == 'Assembly' then
        self.productionStage = 'Void'
        self:resetPlate()
    end
end

function Plate:resetPlate()
    self.mode = 'Empty'
    self.heldItems = {}
    self.supplySourceItem = nil
    self.count = 0
    self.currentOutput = nil
    self.heldItem = 'None'
    self:hideBubble()
end