CoffeeMachine = class {__includes = BaseEntity}

local levelPerformance = {
    {
        duration = 5,
    },
    {
        duration = 4,
    },
    {
        duration = 3,
    },
}

function CoffeeMachine:init(params)
    BaseEntity.init(self, params)

    self.counter = 0
    self.productionStage = 'Ready'
    self.volume = 0
    self.isMachine = true
    self.type = 'CoffeeMachine'
    self.level = StockManager:getLevel(self.type)
    self.duration = levelPerformance[self.level].duration
    self.stockType = 'CoffeeSeed'
    self.stock = StockManager:getStockTotal()[self.stockType]
    self.bubbleColor = gColors['brown']
    self.bubble = Bubble({
        x = self.x,
        y = self.y,
        desired_width = self.desired_width,
        desired_height = self.desired_height,
        bubbleColor = self.bubbleColor,
    })
    gStateStack:push(self.bubble)

    self.animation = Animation(self.animation)
    self:updateFrame()
end

function CoffeeMachine:updateFrame()
    if self.productionStage == 'Producing' then
        -- FIXED: Changed getFrame() to getCurrentFrame()
        self.frame = (self.animation and self.animation:getCurrentFrame()) or self.frame
    elseif self.productionStage == 'Holding' then
        self.frame = gFrames['CoffeeMachineHold']
    else
        if self.volume == 4 then
            self.frame = gFrames['CoffeeMachinesFillStages4']  -- fullest
        elseif self.volume == 3 then
            self.frame = gFrames['CoffeeMachinesFillStages3']
        elseif self.volume == 2 then
            self.frame = gFrames['CoffeeMachinesFillStages2']
        elseif self.volume == 1 then
            self.frame = gFrames['CoffeeMachinesFillStages1']  -- nearly empty
        else
            self.frame = gFrames['CoffeeMachineAnimation'][1]  -- empty
        end
    end
end

function CoffeeMachine:getHitbox()
    local scale = 0.7
    local w = self.desired_width * scale
    local h = self.desired_height
    local x = self.x + (self.desired_width - w) / 2 - 1 -- Move left by 1 pixel
    local y = self.y
    return x, y, w, h
end

function CoffeeMachine:isMouseOver()
    local x, y, w, h = self:getHitbox()
    return mouseX > x and mouseX < x + w and
           mouseY > y and mouseY < y + h
end

function CoffeeMachine:update(dt)
    if self.productionStage == 'Producing' then
        self.counter = self.counter + dt
        
        if self.animation then 
            self.animation:update(dt) 
        end

        if gSounds and gSounds['coffee-machine'] and not gSounds['coffee-machine']:isPlaying() then
            gSounds['coffee-machine']:setVolume(gSettings.sfxVolume)
            gSounds['coffee-machine']:setLooping(true)
            gSounds['coffee-machine']:play()
        end

        if self.counter >= self.duration then
            self.productionStage = 'Ready'
            self.volume = 4
            self.counter = 0

            if self.animation then
                self.animation:refresh()
            end
        end
    else
        if gSounds and gSounds['coffee-machine'] and gSounds['coffee-machine']:isPlaying() then
            gSounds['coffee-machine']:stop()
        end
    end

    self.level = StockManager:getLevel(self.type)
    
    if self.volume > 0 and self.productionStage ~= 'Holding' then
        self.bubble:activate()
    else
        self.bubble:deactivate()
    end

    BaseEntity.update(self, dt)
    self:updateFrame()
end

function CoffeeMachine:render()
    BaseEntity.render(self)

    --[[if self.productionStage == 'Producing' then
        love.graphics.setColor(gColors['green'])
        love.graphics.arc('line', 'open', self.x + self.desired_width / 2, self.y + self.desired_height / 2, self.desired_width / 2, -math.pi / 2, -math.pi / 2 + (self.counter / self.duration) * (2 * math.pi))
        love.graphics.setColor(gColors['white'])
    end]]

    if self.level then love.graphics.printf(tostring(self.level), self.x, self.y, self.desired_width, 'left') end
end

function CoffeeMachine:produce()
    if self.volume < 4 and self.productionStage ~= 'Producing' and self.stock > 0 then --add another condition for stock
        -- 1.25 seconds per missing 1/4 unit of coffee
        self.duration = (4 - self.volume) * 1.25
        self.productionStage = 'Producing'
        self.counter = 0

        self.stock = StockManager:consume(self.stockType)
        
        -- Start coffee-machine sound
        if gSounds and gSounds['coffee-machine'] then
            gSounds['coffee-machine']:setVolume(gSettings.sfxVolume)
            gSounds['coffee-machine']:setLooping(true)
            gSounds['coffee-machine']:stop()
            gSounds['coffee-machine']:play()
        end
        
        -- FIXED: Use refresh() instead of play() to reset the GD50 animation
        if self.animation then
            self.animation:refresh()

            -- Start animation at the frame matching current volume so it blends smoothly
            local volumeToFrame = { [0]=1, [1]=5, [2]=7, [3]=10 }
            local startIndex = volumeToFrame[self.volume] or 1
            
            -- FIXED: Changed frameIndex to currentFrame for GD50 compatibility
            self.animation.currentFrame = startIndex
            self.animation.timer = 0
        end
    end
end

function CoffeeMachine:drag()
    self.productionStage = 'Holding'
    self:updateFrame()
end

function CoffeeMachine:taken()
    self.productionStage = 'Ready'
    self:updateFrame()
end

function CoffeeMachine:undrag()
    self.productionStage = 'Ready'
    self:updateFrame()
end