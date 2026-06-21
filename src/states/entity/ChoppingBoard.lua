ChoppingBoard = class{__includes = BaseEntity}

function ChoppingBoard:init(x, y)
    BaseEntity.init(self, CHOPPING_BOARD_CONFIG)

    self.productionStage = 'Void' -- void, ready, selected
    self.type = 'ChoppingBoard'
    self.isClicker = true
    self.hasIngredient = false
    self.frames = gFrames['ChoppingBoardQuads']
    self.frame = self.frames[1]
end

local chop_table = {
    ['Meat'] = 'ChoppedMeat',
    ['Lettuce'] = 'ChoppedLettuce',
    ['LoafOfBread'] = 'ChoppedBread'
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
    if item == 'Meat' or item == 'Lettuce' or item == 'LoafOfBread' then
        if self.productionStage ~= 'Ready' then
            self.hasIngredient = item
            return true
        end
    end
    return false
end

function ChoppingBoard:frameUpdate()
    if self.productionStage == 'Void'  and not self.hasIngredient then
        self.frame = self.frames[1]
    elseif self.productionStage == 'Void' and self.hasIngredient then
        if self.hasIngredient == 'Meat' then
            self.frame = self.frames[7]
        elseif self.hasIngredient == 'Lettuce' then
            self.frame = self.frames[11]
        elseif self.hasIngredient == 'LoafOfBread' then
            self.frame = self.frames[3]
        end
    elseif self.productionStage == 'Selected' and not self.hasIngredient then
        self.frame = self.frames[2]
    elseif self.productionStage == 'Selected' and self.hasIngredient then
        if self.hasIngredient == 'Meat' then
            self.frame = self.frames[8]
        elseif self.hasIngredient == 'Lettuce' then
            self.frame = self.frames[12]
        elseif self.hasIngredient == 'LoafOfBread' then
            self.frame = self.frames[4]
        end
    elseif self.productionStage == 'Ready' and self.hasIngredient then
        if self.hasIngredient == 'ChoppedMeat' then
            self.frame = self.frames[10]
        elseif self.hasIngredient == 'ChoppedLettuce' then
            self.frame = self.frames[14]
        elseif self.hasIngredient == 'ChoppedBread' then
            self.frame = self.frames[6]
        end
    end
end

function ChoppingBoard:update(dt)
    if self.productionStage == 'Producing' then
        if self.choppingTime >= self.choppingDuration then
            self.productionStage = 'Ready'
        end
    elseif self.productionStage == 'Selected' then
        -- raise the knife and have the ability to click again to start chopping or stab the customer
    end
    self:frameUpdate()
end

function ChoppingBoard:render()
    if self.frame then
        love.graphics.draw(gFrames['ChoppingBoard'], self.frame, self.x, self.y)
    end
    --[[love.graphics.setColor(gColors['brown'])
    love.graphics.rectangle('fill', self.x, self.y, self.desired_width, self.desired_height)
    love.graphics.setColor(gColors['white'])
    love.graphics.printf(self.type, self.x, self.y, self.desired_width, 'center')
    love.graphics.printf(tostring(self.hasIngredient), self.x, self.y + 20, self.desired_width, 'center')
    love.graphics.printf(self.productionStage, self.x, self.y + 40, self.desired_width, 'center')]]
end

function ChoppingBoard:taken()
    self.productionStage = 'Void'
    self.hasIngredient = false
    self:hideBubble()
end

function ChoppingBoard:slash()
    self.productionStage = 'Void'
end