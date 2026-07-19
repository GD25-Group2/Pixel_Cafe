CoffeeCupStack = class {__includes = BaseEntity}

function CoffeeCupStack:init(params)
    BaseEntity.init(self, params)
    self.priority = 75

    self.type = 'CoffeeCupStack'
    self.isClicker = false
    self.productionStage = 'Ready'
    self.stockType = 'PaperCup'
    self.stock = StockManager:getStockTotal()[self.stockType] or 0
    
    self.shadow = Shadow({
        x = self.x,
        y = self.y + self.desired_height,
        desired_width = self.desired_width,
        desired_height = self.desired_height,
        frame = self.frame,
        xBuffer = 0,
        yBuffer = -3,
    })
    gStateStack:push(self.shadow)
end

function CoffeeCupStack:drag()
end

function CoffeeCupStack:taken()
    self.stock = StockManager:consume(self.stockType)
end

function CoffeeCupStack:undrag()
end
