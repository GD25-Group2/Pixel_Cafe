CoffeeCupStack = class {__includes = BaseEntity}

function CoffeeCupStack:init(params)
    BaseEntity.init(self, params)

    self.type = 'CoffeeCupStack'
    self.isClicker = false
    self.productionStage = 'Ready'
end

function CoffeeCupStack:drag()
end

function CoffeeCupStack:taken()
end

function CoffeeCupStack:undrag()
end
