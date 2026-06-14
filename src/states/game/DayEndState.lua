DayEndState = class{__includes = BaseState}

function DayEndState:init()
    self._dailySalesAmount = gDailySales or 0
    self._dailyTipsAmount = gDailyTips or 0
    self._startingBalance = gStartingBalance or (gMoney or 0) --gMoney will be saved as persistent data

    self._earnedToday = self._dailySalesAmount + self._dailyTipsAmount --this variable will be saved
    self._finalTotal = self._startingBalance + self._earnedToday

    --[[local card = UI_CARD
    -- Ensure card stays fixed size (restoring original height)
    card.height = 140 ]] --comment out this block assuming to be of no use

    self.nextDayButton = Button(BUTTON_PARAMS['NextDay'])
    self.quitButton = Button(BUTTON_PARAMS['DayEndQuit'])

    self.interactables = {
        self.nextDayButton,
        self.quitButton
    }

    print('DayEndState - Today Money: ' .. tostring(self._earnedToday) .. ' Total Money: ' .. tostring(self._finalTotal))
    DataManager:moneyDataSave(self._finalTotal, self._earnedToday)
    local currentDate = DataManager:getData('currentDate')
    DataManager:dateDataSave(currentDate + 1)
    DataManager:autoUnlockMachine() 
    DataManager:create()

    self.card = DayEndStateCard({earnedToday = self._earnedToday, finalTotal = self._finalTotal, currentDate = currentDate})
    gStateStack:push(self.card)
    for _, btn in ipairs(self.interactables) do
        gStateStack:push(btn)
    end

    if gSounds then
        for _, source in pairs(gSounds) do
            source:stop()
        end
    end
end

function DayEndState:update(dt)
    self:mouseResponse()
end