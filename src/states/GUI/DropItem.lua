DropItem = class {__includes = BaseEntity}

function DropItem:init(params, target)
    BaseEntity.init(self, params)
    self.type = 'DropItem'
    self.frame = gFrames[self.type]
    --[[self.id = DropItem_INDEX
    DropItem_INDEX = DropItem_INDEX + 1]]

    self.trailData = {
        list = {},
        lastX = self.x,
        lastY = self.y
    }
    self.process = {
        mode = 'out-quad',
        duration = 0.8,
        --delay = 1,
        birth_duration = 0.35,
        final_delay = 0.35,
        bob_duration = 0.25,
    }

    self.removeSelf = function ()
        gStateStack:pop(self)
        print("DropItem-removeSelf successfully cleared instance")
        Signal:remove('DropItem-remove-' .. tostring(self.order))
    end

    Signal:register('DropItem-remove-' .. tostring(self.order), self.removeSelf)

    MoveToStation.init(self, target, self.process)
end

local function drawSmokeyTail(x, y, trailData)
    local baseRadius = 3          -- Higher = thicker line | Lower = thinner line
    local outlineThickness = 1    -- Higher = thicker border | Lower = thinner border
    local minMoveDistance = 1     -- Higher = disconnected dots | Lower = smoother solid line
    local maxCircles = 35         -- Higher = longer trail length | Lower = shorter trail length
    local maxAge = 0.3            -- Higher = trail lasts longer | Lower = disappears faster
    local fillColor = {1, 1, 1}
    local outlineColor = {0, 0, 0}
    local tailAlphaMax = 0.9      -- Higher = more opaque | Lower = more transparent
    local headAlpha = 1.0

    local useSpeedScaling = true  -- true = dynamically alters shape during fast movement
    local speedStretchFactor = 0.02 -- Higher = grows much longer at high speeds
    local speedThinnerFactor = 0.002 -- Higher = pinches much thinner at high speeds
    local minRadiusLimit = 1.5    -- Lower = line can become thinner when rushing
    local maxCirclesLimit = 80    -- Higher = maximum allowed cap for speed stretching

    local dt = love.timer.getDelta()
    local dx = x - trailData.lastX
    local dy = y - trailData.lastY
    local dist = math.sqrt(dx * dx + dy * dy)
    local currentSpeed = dt > 0 and (dist / dt) or 0

    if useSpeedScaling then
        maxCircles = math.min(maxCirclesLimit, maxCircles + (currentSpeed * speedStretchFactor))
        baseRadius = math.max(minRadiusLimit, baseRadius - (currentSpeed * speedThinnerFactor))
    end

    -- Progressively age all points and delete from furthest (index 1) to nearest
    for i = 1, #trailData.list do
        trailData.list[i].age = (trailData.list[i].age or 0) + dt
    end

    while #trailData.list > 0 and trailData.list[1].age > maxAge do
        table.remove(trailData.list, 1)
    end

    if dist >= minMoveDistance then
        local steps = math.floor(dist / minMoveDistance)
        for i = 1, steps do
            local t = i / steps
            table.insert(trailData.list, {
                x = trailData.lastX + dx * t,
                y = trailData.lastY + dy * t,
                age = 0
            })
        end
        trailData.lastX = x
        trailData.lastY = y
    end

    while #trailData.list > maxCircles do
        table.remove(trailData.list, 1)
    end

    local pointsToDraw = {}
    local count = #trailData.list

    for i = 1, count do
        local pt = trailData.list[i]
        local factor = i / count

        table.insert(pointsToDraw, {
            x = pt.x,
            y = pt.y,
            radius = baseRadius * factor,
            alpha = factor * tailAlphaMax
        })
    end

    table.insert(pointsToDraw, {
        x = x,
        y = y,
        radius = baseRadius,
        alpha = headAlpha
    })

    for _, pt in ipairs(pointsToDraw) do
        love.graphics.setColor(outlineColor[1], outlineColor[2], outlineColor[3], pt.alpha)
        love.graphics.circle('fill', pt.x, pt.y, pt.radius + outlineThickness)
    end

    for _, pt in ipairs(pointsToDraw) do
        love.graphics.setColor(fillColor[1], fillColor[2], fillColor[3], pt.alpha)
        love.graphics.circle('fill', pt.x, pt.y, pt.radius)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function DropItem:render()
    BaseEntity.render(self)
    local radius = 8
    drawSmokeyTail(self.x, self.y, self.trailData)
end