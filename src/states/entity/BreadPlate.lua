BreadPlate = class {__includes = BaseEntity}

function BreadPlate:init(params)
    BaseEntity.init(self, params)

    self.type = 'BreadPlate'
    self.isClicker = true

    self.productionStage = 'Void'
    self.slices = 0
    self.loafRemaining = 0
    self.color = gColors['transparent']
    self._bubbleColor = gColors['yellow']
end

function BreadPlate:update(dt)
    --[[if self.productionStage == 'Producing' then
        if self.slices > 0 then
            self.productionStage = 'Ready'
            self:showBubble(self._bubbleColor)
        end
    elseif self.productionStage == 'Ready' then
        if self.slices == 0 then
            -- if there is still loaf remaining, go back to Producing, otherwise Void
            if self.loafRemaining > 0 then
                self.productionStage = 'Producing'
            else
                self.productionStage = 'Void'
            end
            self:hideBubble()
        end
    end]]

    if self.productionStage == 'Void' then
        self.color = gColors['transparent']
    elseif self.productionStage == 'Producing' then
        self.color = gColors['green']
    elseif self.productionStage == 'Ready' then
        if self.slices == 1 then
            self.color = gColors['yellow']
        elseif self.slices == 2 then
            self.color = gColors['orange']
        elseif self.slices >= 3 then
            self.color = gColors['red']
        end
    end

    BaseEntity.update(self, dt)
end

function BreadPlate:render()
    BaseEntity.render(self)


    love.graphics.setFont(gFonts['small'])
    local label = 'Slices: ' .. self.slices
    local font = gFonts['small']
    local tw = font:getWidth(label)
    local fh = font:getHeight()
    love.graphics.setFont(font)
    love.graphics.setColor(gColors['white'])
    love.graphics.print(label, self.x + self.desired_width / 2 - tw / 2, self.y + self.desired_height + 4)
end

function BreadPlate:action()
    --[[if self.loafRemaining > 0 then
        self.slices = self.slices + 1
        self.loafRemaining = self.loafRemaining - 1
        if self.productionStage ~= 'Ready' then
            self.productionStage = 'Ready'
            self:showBubble(self._bubbleColor)
        end
    end]]
end

function BreadPlate:receiveItem(item)
    if item == 'SlicedBread' then
        -- Only accept a new loaf when the previous loaf is finished
        if self.slices == 0 then
            self.productionStage = 'Ready'
            self.slices = 3
            self:hideBubble() -- ensure hidden when starting new loaf
            return true
        end
    end

    return false
end

function BreadPlate:drag()
    self.productionStage = 'Holding'
    self:hideBubble()
end

function BreadPlate:undrag()
    if self.slices > 0 then
        self.productionStage = 'Ready'
        self:showBubble(self._bubbleColor)
    elseif self.loafRemaining > 0 then
        self.productionStage = 'Producing'
    else
        self.productionStage = 'Void'
    end
end

function BreadPlate:taken()
    print('BreadPlate - taken')
    self.slices = self.slices - 1
    if self.slices < 0 then
        self.slices = 0
    elseif self.slices > 0 then
        self.productionStage = 'Ready'
        self:showBubble(self._bubbleColor)
    end

    --[[if self.slices == 0 then
        if self.loafRemaining > 0 then
            self.productionStage = 'Producing'
        else
            self.productionStage = 'Void'
        end
        self:hideBubble()
    else
        self.productionStage = 'Ready'
        self:showBubble(self._bubbleColor)
    end]]
end