CoffeeMachine = class {__includes = BaseEntity}

function CoffeeMachine:init(params)
    BaseEntity.init(self, params)

    self.counter = 0
    self.duration = 5
    self.productionStage = 'Void'
    self.isMachine = true
    self.type = 'CoffeeMachine'

    self.animation = Animation(self.animation)
    self.frame = self.animation:getFrame() or self.frame
end

function CoffeeMachine:getHitbox()
    local scale = 0.7 -- Reduce width by 30%
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
        if self.counter >= self.duration then
            self.productionStage = 'Ready'
            self.counter = 0
        end
    end

    BaseEntity.update(self, dt)
end

function CoffeeMachine:render()
    BaseEntity.render(self)

    if self.productionStage == 'Producing' then
        love.graphics.setColor(gColors['green'])
        love.graphics.arc('line', 'open', self.x + self.desired_width / 2, self.y + self.desired_height / 2, self.desired_width / 2, -math.pi / 2, -math.pi / 2 + (self.counter / self.duration) * (2 * math.pi))
        love.graphics.setColor(gColors['white'])
    elseif self.productionStage == 'Ready' and self.frame == gFrames['CoffeeMachineAnimation'][10] then -- Only draw the rectangle if it's not the 11th frame (which means it hasn't been picked up and dropped yet). Or actually maybe we can just remove this yellow rectangle. Let's keep the yellow rectangle but maybe it's not needed now with proper frames. Let's keep it as is.
        love.graphics.setColor(gColors['yellow'])
        local hx, hy, hw, hh = self:getHitbox()
        love.graphics.rectangle('line', hx, hy, hw, hh)
        love.graphics.setColor(gColors['white'])
    end
end

function CoffeeMachine:produce()
    self.productionStage = 'Producing'
    self.counter = 0
    self.animation:play()
end

function CoffeeMachine:drag()
    self.productionStage = 'Holding'
    self.frame = gFrames['CoffeeMachineHold']
    self.animation.frame = self.frame
end

function CoffeeMachine:taken()
    self.productionStage = 'Void'
    self.counter = 0
    self.frame = gFrames['CoffeeMachineAnimation'][1]
    self.animation.frame = self.frame
    self.animation:stop()
end

function CoffeeMachine:undrag()
    self.productionStage = 'Ready'
    self.frame = gFrames['CoffeeMachineAnimation'][11]
    self.animation.frame = self.frame
end