CustomerState = class{__includes = BaseState}

function CustomerState:init(params)
    for k, v in pairs(params) do
        self[k] = v
    end
    local frameIndex = math.random(#gFrames.customers)
    self.frame = gFrames.customers[frameIndex]
    self.receivedOrder = false
end

function CustomerState:update(dt)
    if self.receivedOrder then
        gStateStack:pop(self)
    end
end

function CustomerState:render()
    love.graphics.draw(self.frame, self.x, self.y, 0, 
        self.desired_width / self.frame:getWidth(), self.desired_height / self.frame:getHeight())
end

function CustomerState:receiveOrder()
    self.receivedOrder = true
end
