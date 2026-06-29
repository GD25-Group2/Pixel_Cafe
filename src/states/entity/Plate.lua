Plate = class{__includes = BaseEntity}

local supply_yield_table = {
    ['ChoppedBread']   = 'SliceOfBread',
    ['ChoppedMeat']    = 'ChoppedMeatPortion',
    ['ChoppedLettuce'] = 'ChoppedLettucePortion',
}

local storage_items = {
    ['LoafOfBread'] = true,
    ['Lettuce'] = true,
    ['Meat'] = true
}

local valid_assembly_items = {
    ['SliceOfBread'] = true, 
    ['ChoppedBread'] = true,
    ['ChoppedMeat'] = true,
    ['ChoppedMeatPortion'] = true,
    ['ChoppedLettuce'] = true,
    ['ChoppedLettucePortion'] = true,
    ['ChoppedMeatLettuce'] = true
}

local finished_products = {
    ['MeatSandwich'] = true,
    ['DeluxeSandwich'] = true,
    ['FreeSandwich'] = true,
    ['VegeSandwich'] = true,
    ['ChoppedMeat'] = true,
    ['ChoppedMeatPortion'] = true,
    ['ChoppedLettuce'] = true,
    ['ChoppedLettucePortion'] = true,
    ['ChoppedMeatLettuce'] = true,
}

function Plate:init(params)
    BaseEntity.init(self, params)

    -- Safe lazy-loading to prevent 'nil graphics' crash on LÖVE startup
    if not gFrames['choppedPlatet'] then
        gFrames['choppedPlatet'] = love.graphics.newImage('assets/choppedPlatet.png')
        gFrames['choppedPlatetQuads'] = GenerateQuads(gFrames['choppedPlatet'], 32, 32)
    end

    self.type = 'Plate'
    self.productionStage = 'Void'
    self.mode = 'Empty'
    self.heldItems = {}
    self.supplySourceItem = nil
    self.count = 0
    self.maxCapacity = 4
    self.heldItem = 'None'
    self.color = gColors['green']
    self.bubbleColor = gColors['green']
    self.bubble = Bubble({
        x = self.x,
        y = self.y,
        desired_width = self.desired_width,
        desired_height = self.desired_height,
        bubbleColor = self.bubbleColor,
    }
    )
    gStateStack:push(self.bubble)

    self.activated = params.activated or false
end

function Plate:evaluateRecipes()
    local hasSliceOfBread = false
    local hasChoppedBread = false
    local hasChoppedMeat = false
    local hasLettuce = false -- leftover check from old code
    local hasChoppedLettuce = false

    for _, v in ipairs(self.heldItems) do
        if v == 'SliceOfBread' then hasSliceOfBread = true end
        if v == 'ChoppedBread' then hasChoppedBread = true end
        if v == 'ChoppedMeat' or v == 'ChoppedMeatPortion' then hasChoppedMeat = true end
        if v == 'ChoppedLettuce' or v == 'ChoppedLettucePortion' then hasChoppedLettuce = true end
        if v == 'ChoppedMeatLettuce' then
            hasChoppedMeat = true
            hasChoppedLettuce = true
        end
    end

    local bread = hasSliceOfBread or hasChoppedBread

    if bread and hasChoppedMeat and hasChoppedLettuce then
        self.currentOutput = 'DeluxeSandwich'
    elseif bread and hasChoppedMeat then
        self.currentOutput = 'MeatSandwich'
    elseif bread and hasChoppedLettuce then
        self.currentOutput = 'VegeSandwich' 
    elseif bread then
        self.currentOutput = 'FreeSandwich'
    elseif hasChoppedMeat and hasChoppedLettuce then
        self.currentOutput = 'ChoppedMeatLettuce'
    elseif hasChoppedMeat then
        self.currentOutput = 'ChoppedMeatPortion'
    elseif hasChoppedLettuce then
        self.currentOutput = 'ChoppedLettucePortion'
    else
        self.currentOutput = nil
    end

    if not self.currentOutput then return end

    self.productionStage = 'Ready'
    self.heldItem = self.currentOutput
end

function Plate:receiveItem(item, source)
    if not self.activated then return false end
    if source == self then return false end

    local actual_item = item
    if item == 'FreeSandwich' then actual_item = 'SliceOfBread' end

    local incoming_base = supply_yield_table[actual_item] or actual_item
    local incoming_bulk = supply_yield_table[actual_item] and actual_item or nil
    if not incoming_bulk then
        for bulk, yield in pairs(supply_yield_table) do
            if yield == incoming_base then incoming_bulk = bulk; break end
        end
    end

    if self.mode == 'Empty' then
        if supply_yield_table[actual_item] then
            self.mode = 'Supply'
            self.supplySourceItem = actual_item
            self.count = 3
            self.productionStage = 'Ready'
            self.heldItem = supply_yield_table[actual_item]
            return true
        elseif valid_assembly_items[actual_item] then
            self.mode = 'Assembly'
            table.insert(self.heldItems, actual_item)
            self:evaluateRecipes()
            return true
        end
        return false
    end

    if self.mode == 'Supply' then
        local current_base = supply_yield_table[self.supplySourceItem] or self.supplySourceItem
        local current_bulk = supply_yield_table[self.supplySourceItem] and self.supplySourceItem or nil
        if not current_bulk then
            for bulk, yield in pairs(supply_yield_table) do
                if yield == current_base then current_bulk = bulk; break end
            end
        end

        if current_base == incoming_base then
            local max_count = 1
            if current_bulk or incoming_bulk then max_count = 3 end
            
            if self.count < max_count then
                self.count = self.count + 1
                if current_bulk then
                    self.supplySourceItem = current_bulk
                elseif incoming_bulk then
                    self.supplySourceItem = incoming_bulk
                end
                self.heldItem = current_base
                self.productionStage = 'Ready'
                return true
            end
        end
        return false
    end

    if self.mode == 'Assembly' then
        if finished_products[item] and #self.heldItems == 0 then
            self.heldItem = item
            self.currentOutput = item
            self.productionStage = 'Ready'
            return true
        end

        if #self.heldItems == 1 then
            local current_item = self.heldItems[1]
            local current_base = supply_yield_table[current_item] or current_item
            
            if current_base == incoming_base then
                local bulk_item = incoming_bulk
                if not bulk_item then
                    for bulk, yield in pairs(supply_yield_table) do
                        if yield == current_base then bulk_item = bulk; break end
                    end
                end
                if bulk_item then
                    self.mode = 'Supply'
                    self.supplySourceItem = bulk_item
                    self.count = 2
                    self.productionStage = 'Ready'
                    self.heldItem = current_base
                    self.heldItems = {}
                    return true
                end
            end
        end

        if #self.heldItems < self.maxCapacity and valid_assembly_items[actual_item] then
            table.insert(self.heldItems, actual_item)
            self:evaluateRecipes()
            return true
        end
    end

    return false
end

function Plate:update(dt)
    if not self.activated then return end

    if gFrames then
        if gFrames['ChoppedLettuce'] and not gFrames['ChoppedLettucePortion'] then
            gFrames['ChoppedLettucePortion'] = gFrames['ChoppedLettuce']
        end
        if gFrames['ChoppedMeat'] and not gFrames['ChoppedMeatPortion'] then
            gFrames['ChoppedMeatPortion'] = gFrames['ChoppedMeat']
        end
    end

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
    if not self.activated then return end

    BaseEntity.render(self)

    local frameIndex = 1

    if self.mode == 'Supply' and self.count > 0 then
        local base = 0
        if self.heldItem == 'Meat' or self.heldItem == 'ChoppedMeat' or self.heldItem == 'ChoppedMeatPortion' then
            base = 1  
        elseif self.heldItem == 'Lettuce' or self.heldItem == 'ChoppedLettuce' or self.heldItem == 'ChoppedLettucePortion' or self.heldItem == 'Vegetable' then
            base = 4  
        elseif self.heldItem == 'SliceOfBread' or self.heldItem == 'ChoppedBread' then
            base = 7  
        end
        
        if base > 0 then
            frameIndex = base + math.min(self.count, 3)
        end

    elseif self.mode == 'Assembly' then
        local hasSliceOfBread = false
        local hasChoppedBread = false
        local hasMeat = false
        local hasChoppedMeat = false
        local hasLettuce = false
        local hasChoppedLettuce = false

        for _, v in ipairs(self.heldItems) do
            if v == 'SliceOfBread' then hasSliceOfBread = true end
            if v == 'ChoppedBread' then hasChoppedBread = true end
            if v == 'Meat' then hasMeat = true end
            if v == 'ChoppedMeat' or v == 'ChoppedMeatPortion' then hasChoppedMeat = true end
            if v == 'Lettuce' or v == 'Vegetable' then hasLettuce = true end
            if v == 'ChoppedLettuce' or v == 'ChoppedLettucePortion' then hasChoppedLettuce = true end
            if v == 'ChoppedMeatLettuce' then
                hasChoppedMeat = true
                hasChoppedLettuce = true
            end
        end

        local bread = hasSliceOfBread or hasChoppedBread

        if bread and hasChoppedMeat and hasChoppedLettuce then
            frameIndex = 14  
        elseif bread and hasChoppedLettuce then
            frameIndex = 13  
        elseif bread and hasChoppedMeat then
            frameIndex = 12  
        elseif hasChoppedMeat and hasChoppedLettuce then
            frameIndex = 11  
        elseif bread then
            frameIndex = 8   
        elseif hasChoppedLettuce then
            frameIndex = 5   
        elseif hasLettuce then
            frameIndex = 4   
        elseif hasMeat or hasChoppedMeat then
            frameIndex = 2   
        else
            frameIndex = 1   
        end
    end

    if gFrames['choppedPlatet'] and gFrames['choppedPlatetQuads'] then
        love.graphics.setColor(gColors['white'] or {1, 1, 1, 1})
        local safeFrame = math.min(frameIndex, #gFrames['choppedPlatetQuads'])
        love.graphics.draw(gFrames['choppedPlatet'], gFrames['choppedPlatetQuads'][safeFrame], self.x, self.y)
    else
        love.graphics.setColor(self.color)
        love.graphics.rectangle('fill', self.x, self.y, self.desired_width, self.desired_height)
    end

    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(gColors['white'])
    
    --[[local text = ""
    if self.mode == 'Supply' and self.count > 0 then
        if self.count > 1 then
            if self.heldItem == 'SliceOfBread' then
                text = string.format("Slices: %d", self.count)
            elseif self.heldItem == 'ChoppedMeat' or self.heldItem == 'ChoppedMeatPortion' then
                text = string.format("Patties: %d", self.count)
            else
                text = string.format("Portions: %d", self.count)
            end
        else
            text = self.heldItem
        end
    elseif self.mode == 'Assembly' and self.productionStage == 'Ready' then
        text = self.currentOutput or "Assembling..."
    end

    if text ~= "" then
        local tw = gFonts['small']:getWidth(text)
        love.graphics.print(text, self.x + self.desired_width / 2 - tw / 2, self.y + self.desired_height / 2)
    end]]
end

function Plate:drag()
    if not self.activated then return end
    self.productionStage = 'Holding'
    if self.mode == 'Supply' then
        self.heldItem = supply_yield_table[self.supplySourceItem] or self.supplySourceItem
    elseif self.mode == 'Assembly' then
        self.heldItem = self.currentOutput or self.heldItem
    end
end

function Plate:undrag()
    if not self.activated then return end
    if self.count > 0 or #self.heldItems > 0 then
        self.productionStage = 'Ready'
        if self.mode == 'Supply' then
            self.heldItem = supply_yield_table[self.supplySourceItem] or self.supplySourceItem
        elseif self.mode == 'Assembly' then
            self.heldItem = self.currentOutput
        end
    else
        self:resetPlate()
    end
end

function Plate:taken()
    if not self.activated then return end
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
end

function Plate:activate()
    self.activated = true
end