TextBox = class {__includes = BaseEntity}

function TextBox:init(params)
    BaseEntity.init(self, params)
    self.priority = 97

    self.desired_width = 32
    self.desired_height = 32

    if self.aboutStock and self.stock and not self.text then
        self.text = tostring(self.stock)
    else
        self.text = ''
    end

    self.counter = 0
end

function TextBox:update(dt)
    local duration = 2
    self.counter = self.counter + dt
    if self.counter >= duration then
        self.counter = 0
        gStateStack:pop(self)
    end
end

function TextBox:render()
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