PlayState = class {__includes = BaseState}

local function find(list, name)
    for i = 1, #list do
        if list[i] == name then
            return true
        end
    end
    return false
end

function PlayState:init()
    self.priority = 0
    self.type = 'PlayState'
    self.interactables = {}
    self.stockOwners = {}

    self.data = DataManager:getData()
    if self.data['name'] ~= 'special' then DataManager:ensureUnlocks(DataManager:getData('currentDate')) end
    DataManager:saveOldData()
    self.currentDate = self.data['currentDate'] or 1
    print('Current Date: ' .. tostring(self.data['currentDate']))
    print('PlayState - Today Money: ' .. tostring(self.data['todayMoney']) .. ' Total Money: ' .. tostring(self.data['totalMoney']))

    -- we can insert more item here
    for k, v in pairs(AVAILABLE_ITEMS) do AVAILABLE_ITEMS[k] = nil end
    if find(self.data['unlockedMachine'], 'CoffeeMachine') then
        table.insert(AVAILABLE_ITEMS, 'CoffeeCup')
    end
    if find(self.data['unlockedMachine'], 'BreadBasket') then
        print('PlayState - lettuce unlocked')
        table.insert(AVAILABLE_ITEMS, 'VegeSandwich')

        if find(self.data['unlockedMachine'], 'Stove') then
            print('PlayState - stove unlocked')
            table.insert(AVAILABLE_ITEMS, 'MeatSandwich')
            table.insert(AVAILABLE_ITEMS, 'DeluxeSandwich')
        end
    end
    
    for k, v in pairs(AVAILABLE_ITEMS) do print('PlayState - ', AVAILABLE_ITEMS[k]) end

    self.cityBackground = CityBackground()
    gStateStack:push(self.cityBackground)

    self.customerManager = CustomerManager()
    gStateStack:push(self.customerManager)

    self.counterBackground = CounterBackground() -- 16 116
    gStateStack:push(self.counterBackground)

    self.moneyManager    = MoneyManager(self.data['totalMoney'], self.data['todayMoney'])
    gStateStack:push(self.moneyManager)

    self.timeManager     = TimeManager(self.data['currentDate'], self.customerManager)
    gStateStack:push(self.timeManager)

    self.dateManager     = DateEntity()
    gStateStack:push(self.dateManager)

    self.reputationBar = ReputationBar()
    gStateStack:push(self.reputationBar)

    self.pauseButton     = Button(BUTTON_PARAMS['Pause'])
    gStateStack:push(self.pauseButton)
    table.insert(self.interactables, self.pauseButton)

    if not DataManager:getData('specialFreeze') then
        self.unFreezeButton = Button(BUTTON_PARAMS['tutorialComplete'])
        gStateStack:push(self.unFreezeButton)
        table.insert(self.interactables, self.unFreezeButton)
    end

    self.plateManagerPlateAdded = function(plate)
        table.insert(self.interactables, plate)
    end

    self.gameOver = function()
        gStateStack:clear()
        gStateStack:push(GameOver())
    end

    self.dropItemGetParams = function (order)
        local owner
        if order == nil then print('PlayState-order is nil')
        else print('PlayState-order is ' .. tostring(order)) end
        for i = #self.stockOwners, 1, -1 do
            local holder = self.stockOwners[i]
            if holder and holder.stockType then print('PlayState- holder is ' .. tostring(holder.stockType)) end
            if holder.stockType == order then
                owner = {
                    x = holder.x + holder.desired_width / 2,
                    y = holder.y + holder.desired_height / 2,
                    desired_width = holder.desired_width / 4,
                    desired_height = holder.desired_height / 4,
                }
                if owner then print('PlayState - owner exists') end
            end
        end
        return owner
    end

    Signal:register('plate-manager-plate-added', self.plateManagerPlateAdded)
    Signal:register('game-over', self.gameOver)
    Signal:register('drop-item-target-params-take', self.dropItemGetParams)

    if find(self.data['unlockedMachine'], 'BreadBasket') then
        self.breadBasket = BreadBasket(BREAD_BASKET_CONFIG)
        gStateStack:push(self.breadBasket)
        table.insert(self.interactables, self.breadBasket)
        table.insert(self.stockOwners, self.breadBasket)

        self.plateManager = PlateManager()
        gStateStack:push(self.plateManager)

        self.lettuce = Lettuce()
        gStateStack:push(self.lettuce)
        table.insert(self.interactables, self.lettuce)
        table.insert(self.stockOwners, self.lettuce)
    end

    if find(self.data['unlockedMachine'], 'ChoppingBoard') then
        self.choppingBoard = ChoppingBoard()
        gStateStack:push(self.choppingBoard)
        table.insert(self.interactables, self.choppingBoard)
    end

    if find(self.data['unlockedMachine'], 'CoffeeMachine') then
        self.coffeeMachine   = CoffeeMachine(COFFEE_MACHINE_ENTITY)
        gStateStack:push(self.coffeeMachine)
        table.insert(self.interactables, self.coffeeMachine)
        table.insert(self.stockOwners, self.coffeeMachine)
        
        self.coffeeCupStack  = CoffeeCupStack(COFFEE_CUP_STACK_CONFIG)
        gStateStack:push(self.coffeeCupStack)
        table.insert(self.interactables, self.coffeeCupStack)
        table.insert(self.stockOwners, self.coffeeCupStack)
        
        self.coffeeTray      = CoffeeTray(COFFEE_TRAY_CONFIG)
        gStateStack:push(self.coffeeTray)
        table.insert(self.interactables, self.coffeeTray)
    end
    
    if find(self.data['unlockedMachine'], 'Stove') then
        self.stove = Stove()
        gStateStack:push(self.stove)
        table.insert(self.interactables, self.stove)
        table.insert(self.stockOwners, self.stove)
    end

    self.particleBurst   = ParticleBurst()
    gStateStack:push(self.particleBurst)

    self.cursor          = Cursor()
    gStateStack:push(self.cursor)

    if gSounds and gSounds['time-ticking'] then
        gSounds['time-ticking']:stop()
    end

    self.guideCallback = function (stepKey)
        gStateStack:removeType('Guide')
        gStateStack:removeType('DimBackground')
        gStateStack:removeType('Mascot')
        local found = false
        for i = #gStateStack.states, 1, -1 do
            local type = gStateStack.states[i].type
            if type == 'Guide' then
                if not found then
                    found = true
                elseif found then
                    gStateStack:pop(gStateStack.states[i])
                end
            end
        end
        if not found then gStateStack:push(Guide({stepKey = stepKey})) end
    end
    Signal:register('guide-summon', self.guideCallback)

    local summonShop
    summonShop = function ()
        Signal:remove('summonShop', summonShop)
        if not DataManager:getData('shopDone') then
            DataManager:set('shopDone', true)
            gStateStack:pause()
            gStateStack:push(GameStartShopState())
        else
            gStateStack:resume()
        end
    end
    Signal:register('summonShop', summonShop)
end

function PlayState:enter()
    if gMusic and gSettings.musicVolume > 0 then
        gMusic:setVolume(gSettings.musicVolume)
        gMusic:play()
    end

    --Signal:emit('guide-summon')

    gStateStack:pause()

    local guidePhase = tonumber(DataManager:getData('guidePhase')) or 1

    if guidePhase == 1 then
        Signal:emit('guide-summon', 1)
    else
        Signal:emit('summonShop')
    end
end

function PlayState:exit()
    if self.particleBurst then
        self.particleBurst:exit()
    end
    if gSounds then
        if gSounds['time-ticking'] then gSounds['time-ticking']:stop() end
        if gSounds['walking-song1'] then gSounds['walking-song1']:stop() end
        if gSounds['walking-song2'] then gSounds['walking-song2']:stop() end
        if gSounds['coffee-machine'] then gSounds['coffee-machine']:stop() end
    end
end

function PlayState:update(dt)
    if love.keyboard.wasPressed('escape') or love.keyboard.wasPressed('p') then
        gStateStack:pause()
        gStateStack:push(PauseMenu())
    end
    self:mouseResponse()
end

function PlayState:deliverItem(target)
    local success = target:receiveItem(self.cursor.heldItem, self.cursor.dragSource)
    if success then
        -- Only customers generate payments; other entities simply accept the item
        if target.type == 'CustomerState' and target.orderBox then
            Signal:emit('coffee-placed-on-customer')
            local amount, base, tip = self.moneyManager:calculatePayment(target)
            target.totalPayment = amount
            self.moneyManager:addPayment(amount, base, tip)
            self.moneyManager:spawnFloatingMoney(
                target.x + target.desired_width / 2,
                target.y,
                amount
            )
        end
    end
    return success
end

--to overwrite the function in BaseState
function PlayState:getInteractables()
    for i = #self.interactables, 1, -1 do
        if self.interactables[i].type == 'CustomerState' then
            table.remove(self.interactables, i)
        end
    end

    if self.customerManager then
        for _, customer in ipairs(self.customerManager:getAllCustomers()) do
            table.insert(self.interactables, customer)
        end
    end
end