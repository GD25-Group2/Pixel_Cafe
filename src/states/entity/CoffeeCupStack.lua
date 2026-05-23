CoffeeCupStack = class {__includes = BaseEntity}

function CoffeeCupStack:init(params)
    BaseEntity.init(self, params)

    self.type = 'CoffeeCupStack'
    self.isClicker = false
    self.productionStage = 'Ready'
    self.stockType = 'PaperCup'
    self.stock = StockManager:getStockTotal()[self.stockType] or 0
end

function CoffeeCupStack:drag()
end

function CoffeeCupStack:taken()
    self.stock = StockManager:consume(self.stockType)
end

function CoffeeCupStack:undrag()
end
