SandwichPlate = class {__includes = BaseEntity}

function SandwichPlate:init(params)
    BaseEntity.init(self, params)

    self.type = 'SandwichPlate'
    self.isClicker = true

    self.productionStage = 'Void'
    self.color = gColors['transparent']
    self._bubbleColor = gColors['green']
    self.sandwichType = 'None'
end

function SandwichPlate:render()
    BaseEntity.render(self)
end

function SandwichPlate:action()
    -- No action; the sandwich plate is just a delivery point for now.
end

function SandwichPlate:taken()
    self.productionStage = 'Void'
    self.color = gColors['transparent']
    self:hideBubble()
end

function SandwichPlate:receiveItem(item)
    if item then
        if item == 'SliceOfBread' and self.sandwichType == 'None' then
            self.sandwichType = 'FreeSandwich'
        elseif item == 'SliceOfBread' and self.sandwichType == 'OnlyMeat' then
            self.sandwichType = 'MeatSandwich'
        elseif item == 'Meat' and self.sandwichType == 'FreeSandwich' then
            self.sandwichType = 'MeatSandwich'
        elseif item == 'Meat' and self.sandwichType == 'None' then
            self.sandwichType = 'Meat'
        end
        self.productionStage = 'Ready'
        self.color = gColors['green']
        self:showBubble(self._bubbleColor)
    end

    return false
end