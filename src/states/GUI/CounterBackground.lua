CounterBackground = class {__includes = BaseState}

function CounterBackground:init()
    self.isGUI = true
    self.backgroundFrame = gFrames['CounterBackground']
end

function CounterBackground:render()
    love.graphics.draw(self.backgroundFrame, 0, 0, 0, 
        VIRTUAL_WIDTH / self.backgroundFrame:getWidth(), VIRTUAL_HEIGHT / self.backgroundFrame:getHeight())
end