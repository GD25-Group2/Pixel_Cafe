GameWinBackground = class {__includes = BaseEntity}

function GameWinBackground:init()
    self.priority = 5
    self.isGUI = true
    self.backgroundFrame = gFrames['DayEndBackground']
end

function GameWinBackground:render()
    love.graphics.draw(self.backgroundFrame, 0, 0, 0, 
        VIRTUAL_WIDTH / self.backgroundFrame:getWidth(), VIRTUAL_HEIGHT / self.backgroundFrame:getHeight())
end