CoffeeTray = class {__includes = BaseEntity}

function CoffeeTray:init(params)
    BaseEntity.init(self, params)

    self.type = 'CoffeeTray'
    self.isClicker = false
    self.productionStage = 'Ready'

    self.emptyCups = 0
    self.filledCups = 0
    self:updateFrame()
end

function CoffeeTray:updateFrame()
    if self.filledCups > 0 then
        -- Wait, if it has 4 filled cups, it's TrayWithCupsFilled1.
        -- Let's stick to the prompt:
        -- Drag CoffeeMachine to TrayWithEmptyCups4 -> becomes TrayWithCupsFilled1
        -- Drag from TrayWithCupsFilled1 -> becomes TrayWithCupsFilled2
        -- Drag from TrayWithCupsFilled2 -> becomes TrayWithCupsFilled3
        -- Drag from TrayWithCupsFilled3 -> becomes TrayWithCupsFilled4
        -- Drag from TrayWithCupsFilled4 -> becomes EmptyTray
        if self.filledCups == 4 then
            self.frame = gFrames['TrayWithCupsFilled1']
        elseif self.filledCups == 3 then
            self.frame = gFrames['TrayWithCupsFilled2']
        elseif self.filledCups == 2 then
            self.frame = gFrames['TrayWithCupsFilled3']
        elseif self.filledCups == 1 then
            self.frame = gFrames['TrayWithCupsFilled4']
        end
    else
        if self.emptyCups == 0 then
            self.frame = gFrames['EmptyTray']
        elseif self.emptyCups == 1 then
            self.frame = gFrames['TrayWithEmptyCups1']
        elseif self.emptyCups == 2 then
            self.frame = gFrames['TrayWithEmptyCups2']
        elseif self.emptyCups == 3 then
            self.frame = gFrames['TrayWithEmptyCups3']
        elseif self.emptyCups == 4 then
            self.frame = gFrames['TrayWithEmptyCups4']
        end
    end
end

function CoffeeTray:receiveItem(item)
    if item == 'DisposableCoffeeCup' then
        if self.emptyCups < 4 and self.filledCups == 0 then
            self.emptyCups = self.emptyCups + 1
            self:updateFrame()
            return true
        end
    elseif item == 'CoffeeMachine' then
        if self.emptyCups == 4 then
            self.emptyCups = 0
            self.filledCups = 4
            self:updateFrame()
            return true
        end
    end
    return false
end

function CoffeeTray:drag()
    if self.filledCups > 0 then
        -- Temporarily decrease visually, as if the cup is lifted
        self.filledCups = self.filledCups - 1
        self:updateFrame()
    end
end

function CoffeeTray:taken()
    -- Successfully delivered the cup to a customer. We already decremented in drag().
    -- Just ensure frame is updated.
    self:updateFrame()
end

function CoffeeTray:undrag()
    -- Cancelled drag, put the cup back on the tray.
    -- Wait, if we are undragging, we must have had a filled cup.
    self.filledCups = self.filledCups + 1
    self:updateFrame()
end
