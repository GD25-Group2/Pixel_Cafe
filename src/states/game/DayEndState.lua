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
    local currentDate = DataManager:getData('currentDate')
    DataManager:setAll({
        ['totalMoney'] = self._finalTotal,
        ['todayMoney'] = self._earnedToday,
        ['currentDate'] = currentDate + 1,
    })
    DataManager:autoUnlockMachine()
    DataManager:create(SAVE_FILE)

    self.card = DayEndStateCard({earnedToday = self._earnedToday, finalTotal = self._finalTotal, currentDate = currentDate})
    gStateStack:push(self.card)
    for _, btn in ipairs(self.interactables) do
        gStateStack:push(btn)
    end

    self.particleBurst = ParticleBurst()
    gStateStack:push(self.particleBurst)

    -- Celebratory Day-Win green burst pop!
    Signal:emit('trigger_burst', VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, {0.2, 0.95, 0.35, 1}, 80)
    Signal:emit('trigger_burst', VIRTUAL_WIDTH / 2 - 80, VIRTUAL_HEIGHT / 2 + 20, {0.3, 0.9, 0.4, 0.8}, 40)
    Signal:emit('trigger_burst', VIRTUAL_WIDTH / 2 + 80, VIRTUAL_HEIGHT / 2 + 20, {0.3, 0.9, 0.4, 0.8}, 40)

    if gSounds then
        for _, source in pairs(gSounds) do
            source:stop()
        end
    end
end

function DayEndState:update(dt)
    self:mouseResponse()
end

function DayEndState:exit()
    if self.particleBurst then
        self.particleBurst:exit()
    end
end