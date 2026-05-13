CityBackground = class {__includes = BaseState}

function CityBackground:init()
    self.isGUI = true
    self.backgroundFrame = gFrames['CityBackground']
end

function CityBackground:render()
    love.graphics.draw(self.backgroundFrame, 0, 0, 0, 
        VIRTUAL_WIDTH / self.backgroundFrame:getWidth(), VIRTUAL_HEIGHT / self.backgroundFrame:getHeight())
end