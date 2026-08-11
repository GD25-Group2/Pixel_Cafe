DayEndState = class{__includes = BaseState}

function DayEndState:init()
    self.priority = 0
    local rawReceipt = DataManager:getData('receipt') or {}

    DataManager:set('shopDone', false)
    
    self.transReceipt = {}
    for i, v in ipairs(rawReceipt) do
        self.transReceipt[i] = v
    end

    self._dailySalesAmount = gDailySales or 0
    self._dailyTipsAmount = gDailyTips or 0
    self._startingBalance = gStartingBalance or (gMoney or 0)

    self._earnedToday = self._dailySalesAmount + self._dailyTipsAmount 
    self._finalTotal = self._startingBalance + self._earnedToday

    self.nextDayButton = Button(BUTTON_PARAMS['NextDay'])
    self.quitButton = Button(BUTTON_PARAMS['DayEndQuit'])

    print('DayEndState - Today Money: ' .. tostring(self._earnedToday) .. ' Total Money: ' .. tostring(self._finalTotal))
    local currentDate = DataManager:getData('currentDate')
    
    DataManager:setAll({
        ['totalMoney'] = self._finalTotal,
        ['todayMoney'] = self._earnedToday,
        ['currentDate'] = currentDate + 1,
        ['receipt'] = {} 
    })
    DataManager:autoUnlockMachine()
    DataManager:create(SAVE_FILE)
    
    self.card = DayEndStateCard({
        finalTotal = self._finalTotal, 
        currentDate = currentDate,
        transReceipt = self.transReceipt
    })
    gStateStack:push(self.card)

    self.particleBurst = ParticleBurst()
    gStateStack:push(self.particleBurst)

    Signal:emit('victory_fireworks')

    if gSounds then
        for _, source in pairs(gSounds) do
            source:stop()
        end
    end

    self.buttonsPushed = false
end

local function push(buttons)
    for _, btn in ipairs(buttons) do
        gStateStack:push(btn)
    end
end

function DayEndState:update(dt)
    if self.card.done and not self.buttonsPushed then
        self.interactables = {
            self.nextDayButton,
            self.quitButton
        }
        push(self.interactables)
        self.buttonsPushed = true
    end
    
    self:mouseResponse()
end

function DayEndState:exit()
    if self.particleBurst then
        self.particleBurst:exit()
    end
end