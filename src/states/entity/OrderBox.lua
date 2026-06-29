OrderBox = class{__includes = BaseEntity}

local ORDER_COLORS = {
    ['CoffeeCup']       = {0.15, 0.55, 0.75, 1},
    ['SliceOfBread'] = {0.75, 0.55, 0.15, 1},
    ['FreeSandwich'] = {0.45, 0.25, 0.65, 1},
    ['MeatSandwich'] = gColors['brown'],
    ['LoafOfBread']  = {0.85, 0.45, 0.15, 1},
    ['VegeSandwich'] = gColors['red'],
    ['DeluxeSandwich'] = {0.95, 0.65, 0.15, 1},
}

function OrderBox:init(params)
    BaseEntity.init(self, params)

    self.orderType = AVAILABLE_ITEMS[math.random(#AVAILABLE_ITEMS)]
    self.order = ORDER_TYPES[self.orderType]

    self.width   = 44
    self.height  = 44
    self.offsetX = -6
    self.offsetY = -42
    self.tailH   = 5

    self.patience    = CUSTOMER_CONFIG.patienceMax
    self.maxPatience = CUSTOMER_CONFIG.patienceMax

    self.isActive = true
end

function OrderBox:update(dt)
    if not self.isActive or not self.customer then return end

    self.patience = self.patience - CUSTOMER_CONFIG.patienceDecayRate * dt
    if self.patience < 0 then self.patience = 0 end

    if self.patience <= 0 then
        self.isActive = false
        self.customer:leaveImpatient()
    end
end

function OrderBox:render()
    if not self.isActive or not self.customer then return end

    local bx = self.customer.x + self.offsetX
    local by = self.customer.y + self.offsetY
    local bw = self.width
    local bh = self.height

    -- 1. Drop Shadow
    love.graphics.setColor(0, 0, 0, 0.35)
    love.graphics.rectangle('fill', bx + 2, by + 2, bw, bh, 2, 2)

    -- 2. Bubble Background
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle('fill', bx, by, bw, bh, 2, 2)

    -- 3. Top Category Color Accent Strip (Replaces full text header block)
    local hdrH     = 5
    local hdrColor = ORDER_COLORS[self.orderType] or {0.4, 0.4, 0.4, 1}
    love.graphics.setColor(hdrColor)
    love.graphics.rectangle('fill', bx, by, bw, hdrH, 2, 2)
    love.graphics.rectangle('fill', bx, by + 2, bw, hdrH - 2) -- Flattens inner rounded edge

    local img = gFrames[self.orderType]
    if img then
        local iw, ih = img:getDimensions()
        -- Max boundary size available within the bubble slots
        local maxW = bw - 8
        local maxH = bh - hdrH - 12
        local scale = math.min(maxW / iw, maxH / ih, 1) -- Prevents upscaling artifacts

        -- Center item sprite coordinates inside target space
        local imgX = bx + (bw - iw * scale) / 2
        local imgY = by + hdrH + (maxH - ih * scale) / 2

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(img, imgX, imgY, 0, scale, scale)
    end

    -- 5. Patience Bar
    local pct  = self.patience / self.maxPatience
    local barW = bw - 8
    local barH = 4
    local barX = bx + 4
    local barY = by + bh - barH - 4

    love.graphics.setColor(0.25, 0.25, 0.25, 1)
    love.graphics.rectangle('fill', barX, barY, barW, barH)

    local r, g, b
    if pct > 0.5 then
        r, g, b = 0.2, 0.85, 0.3
    elseif pct > 0.25 then
        r, g, b = 0.95, 0.75, 0.1
    else
        r, g, b = 0.9, 0.2, 0.2
    end
    love.graphics.setColor(r, g, b, 1)
    love.graphics.rectangle('fill', barX, barY, math.max(0, barW * pct), barH)

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle('line', barX, barY, barW, barH)

    -- 6. Outer Bubble Border Outline
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle('line', bx, by, bw, bh, 2, 2)

    local tx = bx + bw / 2
    local ty = by + bh
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.polygon('fill', tx - 4, ty, tx + 4, ty, tx, ty + self.tailH)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.polygon('line', tx - 4, ty, tx + 4, ty, tx, ty + self.tailH)

    love.graphics.setColor(1, 1, 1, 1)
end

function OrderBox:getPatience()
    return self.patience / self.maxPatience
end

function OrderBox:deactivate()
    self.isActive = false
end

function OrderBox:decreasePatience(amount)
    self.patience = self.patience - amount
    if self.patience <= 0 then
        self.patience = 0
        self.isActive = false
        self.customer:leaveImpatient()
    end
end