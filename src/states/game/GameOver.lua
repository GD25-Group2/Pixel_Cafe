GameOver = class{__includes = BaseState}

function GameOver:init()
    self.todayMoney, self.totalMoney = DataManager:getData('todayMoney'), DataManager:getData('totalMoney')
    self.currentDate = DataManager:getData('currentDate')

    self.gameOverButton = Button(BUTTON_PARAMS['GameOver'])

    self.interactables = {
        self.gameOverButton,
    }

    self.card = DayEndStateCard({earnedToday = self.todayMoney, finalTotal = self.totalMoney, currentDate = self.currentDate, gameOver = true})
    gStateStack:push(self.card)
    for _, btn in ipairs(self.interactables) do
        gStateStack:push(btn)
    end
end

function GameOver:update(dt)
    self:mouseResponse()
end