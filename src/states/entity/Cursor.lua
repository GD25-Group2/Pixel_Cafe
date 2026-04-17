Cursor = class {__includes = BaseState}

function Cursor:init()
    self.isDragging = false
end

function Cursor:update(dt)
end

function Cursor:render()
    if self.isDragging then
        love.graphics.circle('fill', mouseX, mouseY, 5, 5)
    end
end

function Cursor:isDragged()
    self.isDragging = true
end

function Cursor:isReleased()
    self.isDragging = false
end