-- src/states/entity/Plate.lua
Plate = class{__includes = BaseEntity}

local supply_yield_table = {
    ['ChoppedBread']   = 'SliceOfBread',
    ['ChoppedMeat']    = 'Meat',
    ['ChoppedLettuce'] = 'Lettuce',
}

-- Raw ingredients
local valid_assembly_items = {
    ['SliceOfBread'] = true, 
    ['ChoppedBread'] = true,
    ['Meat'] = true,
    ['ChoppedMeat'] = true,
    ['Lettuce'] = true,
    ['ChoppedLettuce'] = true,
    ['Vegetable'] = true
}

-- Finished items that can be placed on plates
local finished_products = {
    ['MeatSandwich'] = true,
    ['DeluxeSandwich'] = true,
    ['FreeSandwich'] = true,
    ['Meat'] = true, -- Meat is both a product and an ingredient
    ['Lettuce'] = true
}

local storage_items = {
    ['LoafOfBread'] = true,
    ['Lettuce'] = true,
    ['Meat'] = true
}

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
        -- If it's a bulk supply, show count. If it's single storage, just show the item name.
        if self.count > 1 then
            text = string.format("Slices: %d", self.count)
        else
            text = self.heldItem
        end
    elseif self.mode == 'Assembly' and self.productionStage == 'Ready' then
        text = self.currentOutput or "Assembling..."
    end

    if text ~= "" then
        local tw = gFonts['small']:getWidth(text)
        love.graphics.print(text, self.x + self.desired_width / 2 - tw / 2, self.y + self.desired_height / 2)
    end
end

function Plate:receiveItem(item, source)
    if source == self then return false end

    -- Normalize for 'FreeSandwich' (for backwards compatibility)
    local actual_item = item
    if item == 'FreeSandwich' then actual_item = 'SliceOfBread' end

    -- 1. If plate is empty: Decide to become Supply or Assembly
    if self.mode == 'Empty' then
        if supply_yield_table[actual_item] then
            self.mode = 'Supply'
            self.supplySourceItem = actual_item
            self.count = 3
            self.productionStage = 'Ready'
            self.heldItem = supply_yield_table[actual_item]
            return true
        elseif storage_items[actual_item] then
            self.mode = 'Supply'
            self.supplySourceItem = actual_item
            self.count = 1
            self.productionStage = 'Ready'
            self.heldItem = actual_item
            return true
        elseif valid_assembly_items[actual_item] then
            self.mode = 'Assembly'
            table.insert(self.heldItems, actual_item)
            self:evaluateRecipes()
            return true
        end
        return false
    end

    -- 2. If Supply Plate: Handle restocking
    if self.mode == 'Supply' then
        local max_count = supply_yield_table[self.supplySourceItem] and 3 or 1
        if actual_item == self.heldItem and self.count < max_count then
            self.count = self.count + 1
            return true
        end
        return false
    end

    -- 3. If Assembly Plate: Handle Ingredients vs Finished Products
    if self.mode == 'Assembly' then
        
        -- NEW: If item is a Finished Product, just hold it (don't add to recipe list)
        if finished_products[item] and #self.heldItems == 0 then
            self.heldItem = item
            self.currentOutput = item
            self.productionStage = 'Ready'
            return true
        end

        -- Handle conversion from 1 ingredient to Supply stack
        if #self.heldItems == 1 and actual_item == self.heldItems[1] then
            local sourceItem = nil
            for src, yield in pairs(supply_yield_table) do
                if yield == actual_item then sourceItem = src; break end
            end
            if sourceItem then
                self.mode = 'Supply'; self.supplySourceItem = sourceItem; self.count = 2;
                self.productionStage = 'Ready'; self.heldItem = actual_item; self.heldItems = {}; return true
            end
        end

        -- Add to sandwich assembly
        if #self.heldItems < self.maxCapacity and valid_assembly_items[actual_item] then
            table.insert(self.heldItems, actual_item)
            self:evaluateRecipes()
            return true
        end
    end

    return false
end

function Plate:drag()
    self.productionStage = 'Holding'

    if self.mode == 'Supply' then
        -- Fallback to the source item if it's a storage item (which yields nil in the table)
        self.heldItem = supply_yield_table[self.supplySourceItem] or self.supplySourceItem
    elseif self.mode == 'Assembly' then
        self.heldItem = self.currentOutput
    end
    
    self:hideBubble()
end

function Plate:undrag()
    if self.count > 0 or #self.heldItems > 0 then
        self.productionStage = 'Ready'

        if self.mode == 'Supply' then
            self.heldItem = supply_yield_table[self.supplySourceItem] or self.supplySourceItem
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
            self.heldItem = supply_yield_table[self.supplySourceItem] or self.supplySourceItem
        end
    elseif self.mode == 'Assembly' then
        self:resetPlate()
    end
end

function Plate:resetPlate()
    self.mode = 'Empty'
    self.productionStage = 'Void'
    self.heldItems = {}
    self.supplySourceItem = nil
    self.count = 0
    self.currentOutput = nil
    self.heldItem = 'None'
    self:hideBubble()
end