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
    self.bubbleColor = gColors['purple']
    self.bubble = Bubble({
        x = self.x,
        y = self.y,
        desired_width = self.desired_width,
        desired_height = self.desired_height,
        bubbleColor = self.bubbleColor,
    })

    self.animationCounter = 0

    self.isAvail = false
    gStateStack:push(self.bubble)
end

function Stove:update(dt)
    if self.productionStage == 'Producing' then
        self.counter = self.counter + dt

        if self.counter >= self.duration then
            self.counter = 0
            self.productionStage = 'Ready'
            self.isAvail = true
        end
    end

    if self.isAvail and self.productionStage ~= 'Holding' then
        self.bubble:activate()
    else
        self.bubble:deactivate()
    end

    self:updateFrame()
end


function Stove:updateFrame()
    if self.isAvail then
        self.frame = self.frames[12]
    elseif self.productionStage ~= 'Producing' then
        self.frame = self.frames[1]
    else
        local frameDuration = self.duration / 10
        for i = 2, 11 do
            if self.counter > frameDuration * i then
                self.frame = self.frames[i]
            end
        end
    end
end

function Stove:render()
    if self.frame then
        love.graphics.draw(self.texture, self.frame, self.x, self.y)
    end
end

function Stove:produce()
    if self.productionStage ~= 'Producing' then
        self.productionStage = 'Producing'
        self.counter = 0
        self.stock = StockManager:consume(self.stockType)
    end
end

function Stove:drag()
    self.productionStage = 'Holding'
    self:updateFrame()
end

function Stove:taken()
    self.productionStage = 'Ready'
    self:updateFrame()
    self.isAvail = false
end

function Stove:undrag()
    self.productionStage = 'Ready'
    self:updateFrame()
end