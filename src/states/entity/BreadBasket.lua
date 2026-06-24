BreadBasket = class {__includes = BaseEntity}

function BreadBasket:init(def)
    BaseEntity.init(self, def)

    self.type = 'BreadBasket'
    self.isMachine = true
    self.stockType = 'Bread'
    self.stock = StockManager:getStockTotal()[self.stockType]
    self.bubbleColor = gColors['yellow']
    self.bubble = Bubble({
        x = self.x,
        y = self.y,
        desired_width = self.desired_width,
        desired_height = self.desired_height,
        bubbleColor = self.bubbleColor,
    })

    if self.stock > 0 then self.bubble:activate()
    else self.bubble:deactivate()
    end

    self.productionStage = 'Ready'
end

function BreadBasket:canDragToPlate(plate)
    if not plate then return false end
    -- Only allow dragging a loaf to the plate if the plate's loaf is finished and the basket has stock
    if plate.loafRemaining == 0 or self.stock > 0 then
        return true
    end
    return false
end

function BreadBasket:taken()
    self.stock = StockManager:consume(self.stockType)
end

function BreadBasket:render()
    BaseEntity.render(self)
end