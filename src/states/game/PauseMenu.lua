PauseMenu = class {__includes = BaseState}

function PauseMenu:init()

end

function PauseMenu:update(dt)
    if love.keyboard.wasPressed('p') then
        gStateStack:pop()
        gStateStack:push(PlayState())
    end
end

function PauseMenu:render()
    love.graphics.print("Pause Menu", 0, 0)
end