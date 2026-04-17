CoffeeMachine = class {__includes = BaseState}

function CoffeeMachine:init(params)
    for k, v in pairs(params) do
        self[k] = v
    end
end

function CoffeeMachine:update(dt)
    
end

function CoffeeMachine:render()
    love.graphics.draw(self.frame, self.x, self.y, 0, 
        self.desired_width / self.frame:getWidth(), self.desired_height / self.frame:getHeight())
end