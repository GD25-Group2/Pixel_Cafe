ParticleBurst = class {__includes = BaseEntity}

function ParticleBurst:init(params)
    BaseEntity.init(self, params or {})
    self.priority = 98
    self.type = 'ParticleBurst'
    self.isGui = true
    
    -- Create a 2x2 white runtime image texture for particles (no external assets needed)
    local imageData = love.image.newImageData(2, 2)
    for y = 0, 1 do
        for x = 0, 1 do
            imageData:setPixel(x, y, 1, 1, 1, 1)
        end
    end
    self.particleTexture = love.graphics.newImage(imageData)
    
    -- Initialize standard particle system for snappy serve/hit bursts
    self.ps_standard = love.graphics.newParticleSystem(self.particleTexture, 1000)
    self.ps_standard:setParticleLifetime(0.2, 0.45) -- snappy, tight lifetime
    self.ps_standard:setEmissionRate(0) -- emit on demand
    self.ps_standard:setSpeed(120, 260) -- explosive launch speed
    self.ps_standard:setLinearDamping(4.5) -- linear friction so particles slow down smoothly
    self.ps_standard:setDirection(0)
    self.ps_standard:setSpread(math.pi * 2) -- full 360-degree spread
    self.ps_standard:setSizeVariation(0.4)
    self.ps_standard:setSizes(2.5, 0.5) -- scale down from 2.5px to 0.5px
    
    --fireworks particle system for Day End celebration
    self.ps_fireworks = love.graphics.newParticleSystem(self.particleTexture, 5000)
    self.ps_fireworks:setParticleLifetime(0.8, 1.5) -- lingering lifetime for arcs
    self.ps_fireworks:setEmissionRate(0)
    self.ps_fireworks:setSpeed(80, 240) -- wider speed range for grand spread
    self.ps_fireworks:setLinearDamping(0.8) -- low damping so they glide outward
    self.ps_fireworks:setLinearAcceleration(-10, 60, 10, 100) -- downward gravity/wind arc
    self.ps_fireworks:setDirection(0)
    self.ps_fireworks:setSpread(math.pi * 2)
    self.ps_fireworks:setSizeVariation(0.5)
    self.ps_fireworks:setSizes(3.5, 1.5, 0) -- start slightly larger and fade/shrink to zero
    
    -- color table 
    self.celebratoryColors = {
        {0.0, 1.0, 0.8, 1},   -- Neon Teal
        {1.0, 0.85, 0.0, 1},  -- Bright Gold
        {1.0, 0.6, 0.8, 1},   -- Pastel Pink
        {0.6, 0.2, 1.0, 1},   -- Electric Purple
        {0.4, 1.0, 0.0, 1}    -- Lime Green
    }
    
    self.scheduledBursts = {}
    
    
    self.signalCallback = function(x, y, color, count, lifetime, speed, damping)
        self:trigger(x, y, color, count, lifetime, speed, damping)
    end
    
    self.fireworksCallback = function()
        self:startFireworkShow()
    end
    
    Signal:register('trigger_burst', self.signalCallback)
    Signal:register('customer_hit', self.signalCallback)
    Signal:register('day_won', self.fireworksCallback)
    Signal:register('victory_fireworks', self.fireworksCallback)
end

function ParticleBurst:trigger(x, y, color, count, lifetime, speed, damping)
    count = count or 20
    color = color or {1, 1, 1, 1}
    
    if lifetime then
        if type(lifetime) == "table" then
            self.ps_standard:setParticleLifetime(unpack(lifetime))
        else
            self.ps_standard:setParticleLifetime(lifetime * 0.8, lifetime * 1.2)
        end
    else
        self.ps_standard:setParticleLifetime(0.2, 0.45)
    end
    
    if speed then
        if type(speed) == "table" then
            self.ps_standard:setSpeed(unpack(speed))
        else
            self.ps_standard:setSpeed(speed * 0.7, speed * 1.3)
        end
    else
        self.ps_standard:setSpeed(120, 260)
    end
    
    if damping then
        self.ps_standard:setLinearDamping(damping)
    else
        self.ps_standard:setLinearDamping(4.5)
    end
    
    self.ps_standard:moveTo(x, y)
    
    local r, g, b, a = unpack(color)
    self.ps_standard:setColors(r, g, b, a or 1, r, g, b, 0)
    self.ps_standard:emit(count)
end

function ParticleBurst:startFireworkShow()
    self.scheduledBursts = {}
    
    local count = love.math.random(4, 6)
    for i = 1, count do
        local x = love.math.random(math.floor(VIRTUAL_WIDTH * 0.1), math.floor(VIRTUAL_WIDTH * 0.9))
        local y = love.math.random(math.floor(VIRTUAL_HEIGHT * 0.15), math.floor(VIRTUAL_HEIGHT * 0.55))
        local color = self.celebratoryColors[love.math.random(#self.celebratoryColors)]
        local delay = love.math.random() * 1.5 -- spread over 1.5 seconds (we can increase later )
        
        table.insert(self.scheduledBursts, {
            x = x,
            y = y,
            color = color,
            delay = delay,
            particleCount = love.math.random(80, 120)
        })
    end
end

function ParticleBurst:triggerFirework(x, y, color, count)
    self.ps_fireworks:moveTo(x, y)
    
    local r, g, b, a = unpack(color)
    self.ps_fireworks:setColors(r, g, b, a or 1, r, g, b, 0.8, r, g, b, 0)
    self.ps_fireworks:emit(count)
end

function ParticleBurst:update(dt)
    BaseEntity.update(self, dt)
    self.ps_standard:update(dt)
    self.ps_fireworks:update(dt)

    for i = #self.scheduledBursts, 1, -1 do
        local burst = self.scheduledBursts[i]
        burst.delay = burst.delay - dt
        if burst.delay <= 0 then
            self:triggerFirework(burst.x, burst.y, burst.color, burst.particleCount)
            table.remove(self.scheduledBursts, i)
        end
    end
end

function ParticleBurst:render()
    local r, g, b, a = love.graphics.getColor()
    local blendMode, alphaMode = love.graphics.getBlendMode()
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.ps_standard, 0, 0)
    love.graphics.draw(self.ps_fireworks, 0, 0)
    
    love.graphics.setColor(r, g, b, a)
    love.graphics.setBlendMode(blendMode, alphaMode)
end

function ParticleBurst:exit()
    Signal:remove('trigger_burst', self.signalCallback)
    Signal:remove('customer_hit', self.signalCallback)
    Signal:remove('day_won', self.fireworksCallback)
    Signal:remove('victory_fireworks', self.fireworksCallback)
end
