Lettuce = class {__includes = BaseEntity}

function Lettuce:init()
    BaseEntity.init(self, LETTUCE_CONFIG)

    self.type = 'Lettuce'
    self.isMachine = true
    self.stockType = 'Lettuce'
    self.stock = StockManager:getStockTotal()[self.stockType]
    self._bubbleColor = gColors['yellow']

    self.productionStage = 'Ready'
    self:showBubble(self._bubbleColor)
end

function Lettuce:canDragToPlate(plate)
    if not plate then return false end
    -- Only allow dragging a loaf to the plate if the plate's loaf is finished and the basket has stock
    if plate.loafRemaining == 0 or self.stock > 0 then
        return true
    end
    return false
end

function Lettuce:taken()
    self.stock = StockManager:consume(self.stockType)
end

function Lettuce:render()
    BaseEntity.render(self)

    love.graphics.setColor(gColors['blue'])
    love.graphics.rectangle('fill', self.x, self.y, self.desired_width, self.desired_height)
end