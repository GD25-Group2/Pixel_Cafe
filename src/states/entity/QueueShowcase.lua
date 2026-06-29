QueueShowcase = class {__includes = BaseEntity}

local config = {
    x = VIRTUAL_WIDTH + 40,
    y = VIRTUAL_HEIGHT / 2 - 80 - 20 - 2,
    buffer = 2,
    width = 20,
    height = 80,
    desired_width = 16,
    desired_height = 16,
    expandedX = VIRTUAL_WIDTH - 32, 
}

local slots = {
    config.y + config.buffer,
    config.y + config.buffer + (config.desired_height + config.buffer) * 1,
    config.y + config.buffer + (config.desired_height + config.buffer) * 2,
    config.y + config.buffer + (config.desired_height + config.buffer) * 3,
}

function QueueShowcase:signalQueue()
    Signal:register('queue-count', self.getQCount)
    Signal:register('queue-customers', self.getQCustomers)
end

function QueueShowcase:init(direction)
    BaseEntity.init(self, config)
    self.direction = direction
    self.move = true
    
    self.queue = {}
    self.queueCount = 0

    self.getQCount = function(amount) self.queueCount = amount end
    self.getQCustomers = function(customers) self.queue = customers end

    self:signalQueue()
end

function QueueShowcase:update(dt)
    if self.move then self:moving(dt) end
end

function QueueShowcase:render()
    love.graphics.setColor(gColors['curtain'] or {0.1, 0.1, 0.1, 0.8})
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

    if self.queue and #self.queue > 0 then
        local currentSlotX = self.x + self.buffer
        
        for i = 1, 4 do
            local qCustomer = self.queue[i]
            
            if qCustomer then
                qCustomer:renderMini(currentSlotX, slots[i], config.desired_width)
            end
        end
        
        if self.queueCount > 4 then
            love.graphics.setColor(0, 0, 0, 0.6)
            love.graphics.rectangle('fill', currentSlotX, slots[4], config.desired_width, config.desired_height)
            
            love.graphics.setColor(gColors['white'])
            love.graphics.setFont(gFonts['small'] or love.graphics.getFont())
            love.graphics.print('+' .. tostring(self.queueCount - 4), currentSlotX + 2, slots[4] + 3)
        end
    end
    love.graphics.setColor(gColors['white'])
end

function QueueShowcase:moving(dt)
    local distanceLeft = self.expandedX - self.x
    local smoothFactor = 5

    self.x = self.x + (distanceLeft * smoothFactor * dt)

    if math.abs(distanceLeft) < 0.5 then
        self.x = self.expandedX
        self.move = false
    end
end