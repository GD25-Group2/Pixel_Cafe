ChoppingBoard = class{__includes = BaseEntity}

function ChoppingBoard:init(x, y)
    BaseEntity.init(self, CHOPPING_BOARD_CONFIG)

    self.productionStage = 'Void' -- void, ready, selected
    self.type = 'ChoppingBoard'
    self.isClicker = true
    self.hasIngredient = false
end

local chop_table = {
    ['Meat'] = 'ChoppedMeat',
    ['Vegetable'] = 'ChoppedVegetable',
    ['LoafOfBread'] = 'SlicedBread'
}

function ChoppingBoard:action()
    if self.productionStage == 'Void' then
        self.productionStage = 'Selected'
    elseif self.productionStage == 'Selected' then
        if self.hasIngredient then
            self.productionStage = 'Ready'
            self.hasIngredient = chop_table[self.hasIngredient]
        else
            self.productionStage = 'Void'
        end
    end
end

function ChoppingBoard:receiveItem(item, source)
    if item == 'Meat' or item == 'Vegetable' or item == 'LoafOfBread' then
        if self.productionStage ~= 'Ready' then
            self.hasIngredient = item
            return true
        end
    end
    return false
end

function ChoppingBoard:update(dt)
    if self.productionStage == 'Producing' then
        if self.choppingTime >= self.choppingDuration then
            self.productionStage = 'Ready'
        end
    elseif self.productionStage == 'Selected' then
        -- raise the knife and have the ability to click again to start chopping or stab the customer
    end
end

function ChoppingBoard:render()
    love.graphics.setColor(gColors['brown'])
    love.graphics.rectangle('fill', self.x, self.y, self.desired_width, self.desired_height)
    love.graphics.setColor(gColors['white'])
    love.graphics.printf(self.type, self.x, self.y, self.desired_width, 'center')
    love.graphics.printf(tostring(self.hasIngredient), self.x, self.y + 20, self.desired_width, 'center')
    love.graphics.printf(self.productionStage, self.x, self.y + 40, self.desired_width, 'center')
end

function ChoppingBoard:taken()
    self.productionStage = 'Void'
    self.hasIngredient = false
    self:hideBubble()
end

function ChoppingBoard:slash()
    self.productionStage = 'Void'
end