BreadBasket = class {__includes = BaseEntity}

function BreadBasket:init(def)
    BaseEntity.init(self, def)

    self.type = 'BreadBasket'
    self.isMachine = true

    self.productionStage = 'Ready'
    self:showBubble(gColors['yellow'])
end

function BreadBasket:canDragToPlate(plate)
    if not plate then return false end
    -- Only allow dragging a loaf to the plate if the plate's loaf is finished
    if plate.loafRemaining == 0 then
        return true
    end
    return false
end

function BreadBasket:render()
    BaseEntity.render(self)
end