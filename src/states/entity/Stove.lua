Stove = class {__includes = BaseEntity}

local levelPerformance = {
    {
        duration = 5,
    },
    {
        duration = 4,
    },
    {
        duration = 3,
    }
}

function Stove:init()
    BaseEntity.init(self, STOVE_CONFIG)
    self.counter = 0
    self.productionStage = 'Ready'
    self.isMachine = true
    self.type = 'Stove'
    self.level = StockManager:getLevel(self.type)
    self.duration = levelPerformance[self.level].duration
    self.stockType = 'Meat'
    self.stock = StockManager:getStockTotal()[self.stockType]
    self._bubbleColor = gColors['purple']
end

function Stove:update(dt)
    if self.productionStage == 'Producing' then
        self.counter = self.counter + dt

        if self.counter >= self.duration then
            self.counter = 0
            self.productionStage = 'Ready'
        end
    end
end

function Stove:render()
    love.graphics.setColor(gColors['purple'])
    love.graphics.rectangle('fill', self.x, self.y, self.desired_width, self.desired_height)
    love.graphics.setColor(gColors['white'])
    love.graphics.printf(self.type, self.x, self.y + 20, self.desired_width, 'center')
end

function Stove:produce()
    if self.productionStage ~= 'Producing' then
        self.productionStage = 'Producing'
        self.counter = 0
        self.stock = StockManager:consume(self.stockType)
        self:showBubble()
    end
end

function Stove:drag()
    self.productionStage = 'Holding'
    --self:updateFrame()
    self:hideBubble()
end

function Stove:taken()
    self.productionStage = 'Ready'
    --[[self:updateFrame()
    if self.volume > 0 then
        self:showBubble(self._bubbleColor)
    else
        self:hideBubble()
    end]]
end

function Stove:undrag()
    self.productionStage = 'Ready'
    --[[self:updateFrame()
    if self.volume > 0 then
        self:showBubble(self._bubbleColor)
    end]]
end