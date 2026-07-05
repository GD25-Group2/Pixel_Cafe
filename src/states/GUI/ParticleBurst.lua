ParticleBurst = class {__includes = BaseEntity}

function ParticleBurst:init(params)
    BaseEntity.init(self, params or {})
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
    
    -- Initialize the persistent LÖVE particle system with a large buffer size
    self.ps = love.graphics.newParticleSystem(self.particleTexture, 2000)
    
    -- Default configurations for a punchy, energetic burst
    self.ps:setParticleLifetime(0.2, 0.45) -- snappy, tight lifetime
    self.ps:setEmissionRate(0) -- emit on demand (emit() calls)
    self.ps:setSpeed(120, 260) -- explosive launch speed
    self.ps:setLinearDamping(4.5) -- linear friction so particles slow down smoothly
    self.ps:setDirection(0)
    self.ps:setSpread(math.pi * 2) -- full 360-degree spread
    self.ps:setSizeVariation(0.4) -- add size variation for organic look
    self.ps:setSizes(2.5, 0.5) -- scale down from 5px down to 1px as they fade/die
    
    -- Register to listen to the specific trigger signal
    self.signalCallback = function(x, y, color, count, lifetime, speed, damping)
        self:trigger(x, y, color, count, lifetime, speed, damping)
    end
    Signal:register('trigger_burst', self.signalCallback)
end

function ParticleBurst:trigger(x, y, color, count, lifetime, speed, damping)
    -- Fallback configurations
    count = count or 20
    color = color or {1, 1, 1, 1}
    
    -- Set dynamic burst properties if supplied, otherwise revert to default
    if lifetime then
        if type(lifetime) == "table" then
            self.ps:setParticleLifetime(unpack(lifetime))
        else
            self.ps:setParticleLifetime(lifetime * 0.8, lifetime * 1.2)
        end
    else
        self.ps:setParticleLifetime(0.2, 0.45)
    end
    
    if speed then
        if type(speed) == "table" then
            self.ps:setSpeed(unpack(speed))
        else
            self.ps:setSpeed(speed * 0.7, speed * 1.3)
        end
    else
        self.ps:setSpeed(120, 260)
    end
    
    if damping then
        self.ps:setLinearDamping(damping)
    else
        self.ps:setLinearDamping(4.5)
    end
    
    -- Move the system's emitter to the target coordinates
    self.ps:moveTo(x, y)
    
    -- Set dynamic color progression (fade gracefully from full color to zero alpha)
    local r, g, b, a = unpack(color)
    self.ps:setColors(r, g, b, a or 1, r, g, b, 0)
    
    -- Emit the particles!
    self.ps:emit(count)
end

function ParticleBurst:update(dt)
    BaseEntity.update(self, dt)
    self.ps:update(dt)
end

function ParticleBurst:render()
    -- Render safely: capture current color and blend mode
    local r, g, b, a = love.graphics.getColor()
    local blendMode, alphaMode = love.graphics.getBlendMode()
    
    -- Draw at (0, 0) since particle coordinates are absolute in screen space
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.ps, 0, 0)
    
    -- Restore previous draw states to avoid leaking tints
    love.graphics.setColor(r, g, b, a)
    love.graphics.setBlendMode(blendMode, alphaMode)
end

function ParticleBurst:exit()
    -- Clean up signal listener to prevent memory leaks on state clear/pop
    Signal:remove('trigger_burst', self.signalCallback)
end
