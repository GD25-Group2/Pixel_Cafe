DimBackground = class {__includes = BaseEntity}

function DimBackground:init(params)
    BaseEntity.init(self, params)  --contains mascot and hightlight entity configurations
    self.priority = 99
    print('DimBackground - initiated')

    self.destruct = function ()
        Signal:remove('destroy-DimBackground', self.destruct)
        gStateStack:pop(self)
    end
    Signal:register('destroy-DimBackground', self.destruct)
end

function DimBackground:render()
    love.graphics.stencil(function()
        if self.mascot and self.mascot.frame then
            love.graphics.draw(self.mascot.frame, self.mascot.x, self.mascot.y)
        end
        if self.highlight then
            love.graphics.rectangle('fill', self.highlight.x, self.highlight.y, self.highlight.desired_width, self.highlight.desired_height)
        end
        if self.textBox then
            local paddingX = 8
            love.graphics.rectangle('fill', self.textBox.x, self.textBox.y, self.textBox.desired_width + paddingX, self.textBox.desired_height)
        end
    end, 'replace', 1)
    love.graphics.setStencilTest('notequal', 1)

    love.graphics.setColor(gColors['curtain'])
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    love.graphics.setStencilTest()
end