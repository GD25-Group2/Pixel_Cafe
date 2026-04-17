PlayState = class {__includes = BaseState}

function PlayState:init()
    -- Default to start hour 8 (8:00 AM)
    self.dayTime = 8 * 60
    
    -- 1 real second = 15 game minutes
    self.timeScale = 15

    self.customerStates = {
        CustomerState(CUSTOMER_ENTITIES['left']),
        CustomerState(CUSTOMER_ENTITIES['center']),
        CustomerState(CUSTOMER_ENTITIES['right']),
    }
    self.coffeeMachine = CoffeeMachine(COFFEE_MACHINE_ENTITY)
    self.cursor = Cursor()

    self.currentCustomer = self.customerStates[1]

    gStateStack:push(self.customerStates[1])
    gStateStack:push(self.customerStates[2])
    gStateStack:push(self.customerStates[3])
    gStateStack:push(self.coffeeMachine)
    gStateStack:push(self.cursor)
end

function PlayState:update(dt)
    if love.keyboard.wasPressed('p') then
        -- End PlayState and enters DayEndState
        gStateStack:pause()
        gStateStack:push(PauseMenu())
    end
    
    -- Update timer
    self.dayTime = self.dayTime + self.timeScale * dt
    local currentHour = math.floor(self.dayTime / 60)
    
    -- Night time transition (8:00 PM / 20 hours)
    if currentHour >= 20 then
        gStateStack:clear()
        gStateStack:push(DayEndState())
    end

    if love.mouse.wasPressed(1) then
        if mouseX > self.coffeeMachine.x and mouseX < self.coffeeMachine.x + self.coffeeMachine.desired_width and
           mouseY > self.coffeeMachine.y and mouseY < self.coffeeMachine.y + self.coffeeMachine.desired_height then
            self.cursor:isDragged()
        end
    end

    if love.mouse.wasReleased(1) and self.cursor.isDragging then
        if self:isOverCustomer() then
            self.currentCustomer:receiveOrder()
            self.cursor:isReleased()
        else
            self.cursor:isReleased()
        end
    end

    
    if mouseX < 110 then
        self.currentCustomer = self.customerStates[1]
    elseif mouseX < 210 then
        self.currentCustomer = self.customerStates[2]
    else
        self.currentCustomer = self.customerStates[3]
    end
end

function PlayState:render()
    love.graphics.rectangle('line', 0, 0, VIRTUAL_WIDTH, 20)
    love.graphics.rectangle('line', 0, 0.40 * VIRTUAL_HEIGHT + 20, VIRTUAL_WIDTH, 0.75 * VIRTUAL_HEIGHT)
    
    -- Timer UI
    local hours = math.floor(self.dayTime / 60)
    local minutes = math.floor(self.dayTime % 60)
    
    local period = "A.M."
    local displayHour = hours % 24
    if displayHour >= 12 then
        period = "P.M."
    end
    
    displayHour = displayHour % 12
    if displayHour == 0 then
        displayHour = 12
    end
    
    local timeString = string.format("%02d:%02d %s", displayHour, minutes, period)
    love.graphics.setFont(gFonts['medium'])
    love.graphics.print(timeString, VIRTUAL_WIDTH - 90, 2)
end

function PlayState:isOverCustomer()
    local c = self.currentCustomer
    return mouseX > c.x and mouseX < c.x + c.desired_width and mouseY > c.y and mouseY < c.y + c.desired_height
end