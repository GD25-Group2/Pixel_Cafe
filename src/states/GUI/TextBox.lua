TextBox = class {__includes = BaseEntity}

function TextBox:init(params)
    BaseEntity.init(self, params)
    self.priority = 97

    self.desired_width = self.desired_width or 32

    if self.aboutStock and self.stock and not self.text then
        self.text = tostring(self.stock)
    elseif self.text then
        self.text = self.text
    else
        self.text = ''
    end

    self.font = self.font or (gFonts and gFonts['small']) or love.graphics.getFont()

    self.paddingX = params and params.paddingX or (self.forGuide and 4 or 0)
    self.paddingY = params and params.paddingY or (self.forGuide and 4 or 0)

    if self.text and self.text ~= '' and self.font then
        local _, lines = self.font:getWrap(self.text, self.desired_width)
        local lineH = self.font:getHeight() * self.font:getLineHeight()
        
        local calculatedHeight = (#lines * lineH) + (self.paddingY * 2)

        if self.forGuide or not (params and params.desired_height) then
            self.desired_height = math.max(calculatedHeight, params and params.desired_height or 0)
        else
            self.desired_height = self.desired_height or 32
        end
    else
        self.desired_height = self.desired_height or 32
    end

    self.counter = 0
end

function TextBox:update(dt)
    if not self.counterDisable then
        local duration = 2
        self.counter = self.counter + dt
        if self.counter >= duration then
            self.counter = 0
            gStateStack:pop(self)
        end
    end
end

function TextBox:render()
    if self.forGuide then
        if self.font then love.graphics.setFont(self.font) end

        love.graphics.setColor(gColors['curtain'])
        love.graphics.rectangle('fill', 
            self.x, 
            self.y, 
            self.desired_width + (self.paddingX * 2), 
            self.desired_height
        )

        -- MODIFIED: Print text offset by padding so it stays inset inside the box
        love.graphics.setColor(gColors['white'])
        love.graphics.printf(
            self.text, 
            self.x + self.paddingX, 
            self.y + self.paddingY, 
            self.desired_width, 
            'left'
        )
    else
        local buffer = 1
        if self.aboutStock then
            love.graphics.setColor(gColors['white'])
            love.graphics.rectangle('fill', self.x, self.y, self.desired_width, self.desired_height)
            love.graphics.setColor(gColors['orange'])
            love.graphics.rectangle('line', self.x, self.y, self.desired_width, self.desired_height)
            love.graphics.setColor(gColors['black'])
            love.graphics.printf('Stock: ' .. self.text, self.x + buffer, self.y, self.desired_width - buffer * 2, 'center')
        end
    end
end