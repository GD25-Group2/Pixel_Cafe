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
    elseif self.productionStage == 'Ready' then
        love.graphics.setColor(gColors['yellow'])
        love.graphics.rectangle('line', self.x, self.y, self.desired_width, self.desired_height)
        love.graphics.setColor(gColors['white'])
    end
end

function CoffeeMachine:produce()
    self.productionStage = 'Producing'
    self.counter = 0
    self.animation:play()
end

function CoffeeMachine:taken()
    self.productionStage = 'Void'
    self.counter = 0
    self.animation:stop()
end