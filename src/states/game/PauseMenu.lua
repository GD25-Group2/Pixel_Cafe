PauseMenu = class {__includes = BaseState}

function PauseMenu:init()
end

function PauseMenu:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateStack:clear()
        gStateStack:resume()
    end
end

function PauseMenu:render()
    love.graphics.setFont(gFonts['large'])
    love.graphics.print('PauseMenu', 0, 0)
end