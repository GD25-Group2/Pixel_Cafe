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

    if not self.aboutStock then self.enableHint = true end

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

    self.destruct = function ()
        Signal:remove('destroy-TextBox', self.destruct)
        gStateStack:pop(self)
    end
    Signal:register('destroy-TextBox', self.destruct)

    print('TextBox - left: ' .. self.x .. ' right: ' .. self.x + self.desired_width)

    self.guidePhase = DataManager:getData('guidePhase') or 1
    if self.guidePhase == 2 then
        self.proceedText = "Click 'Start Shift' button to proceed!"
    elseif self.guidePhase == 3 then
        self.proceedText = "Drag a cup from the stack of cup to proceed!"
    elseif self.guidePhase == 4 then
        self.proceedText = "Click the coffee brewer and drag a jar of coffee to cup, to proceed!"
    elseif self.guidePhase == 5 then
        self.proceedText = "Give the newly brewed cup of coffee to waiting customer, to proceed!"
    elseif self.guidePhase == 10 then
        self.proceedText = "Click the knife and then click the customer to proceed!"
    else
        self.proceedText = "Press 'Enter' to proceed!"
    end
end

function TextBox:update(dt)
    if not self.counterDisable then
        local duration = 2
        self.counter = self.counter + dt
        if self.counter >= duration then
            self.counter = 0
            gStateStack:pop(self)
        end
    elseif self.enableHint then
        local duration = 3
        self.counter = self.counter + dt
        if self.counter >= duration then
            self.counter = 0
            self.displayHint = true
            self.enableHint = false
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

        love.graphics.setColor(gColors['orange'])
        love.graphics.rectangle('line', 
            self.x, 
            self.y, 
            self.desired_width + (self.paddingX * 2), 
            self.desired_height
        )

        love.graphics.setColor(gColors['white'])
        love.graphics.printf(
            self.text, 
            self.x + self.paddingX, 
            self.y + self.paddingY, 
            self.desired_width, 
            'left'
        )

        if self.displayHint then
            local rightBound = 205
            local minX = 20
            local textWidth = self.font:getWidth(self.proceedText)
            local drawX = math.max(minX, rightBound - textWidth)
            local limitWidth = rightBound - drawX
            love.graphics.printf(self.proceedText, drawX, 2, limitWidth, 'center')
        end
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