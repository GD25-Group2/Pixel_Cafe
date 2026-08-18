GameOver = class{__includes = BaseState}

function GameOver:init(type)
    self.priority = 0
    self.todayMoney, self.totalMoney = DataManager:getData('todayMoney'), DataManager:getData('totalMoney')
    self.currentDate = DataManager:getData('currentDate')
    if type then self.type = type end


    self.gameOverButton = Button(BUTTON_PARAMS['GameOver'])

    self.interactables = {
        self.gameOverButton,
    }

    self.card = DayEndStateCard({earnedToday = self.todayMoney, finalTotal = self.totalMoney, currentDate = self.currentDate, gameOver = true, type = self.type})
    gStateStack:push(self.card)
    for _, btn in ipairs(self.interactables) do
        gStateStack:push(btn)
    end
end

function GameOver:update(dt)
    self:mouseResponse()
end