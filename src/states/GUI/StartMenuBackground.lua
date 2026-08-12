StartMenuBackground = class {__includes = BaseState}

function StartMenuBackground:init()
    self.priority = 5
    self.isGUI = true
    self.backgroundFrame = gFrames['StartMenuBackground']
    self.timer = 0
end

function StartMenuBackground:update(dt)
    self.timer = self.timer + dt
end

function StartMenuBackground:render()
    love.graphics.draw(
        self.backgroundFrame, 
        0, 0, 0, 
        VIRTUAL_WIDTH / self.backgroundFrame:getWidth(), 
        VIRTUAL_HEIGHT / self.backgroundFrame:getHeight()
    )

    local text = "Pixel Cafe"

    local floatY = math.sin(self.timer * 3) * 5
    local y = 30 + floatY

    love.graphics.setFont(gFonts['large'])
    love.graphics.setColor(0.06, 0.06, 0.08, 0.85)
    for dx = -2, 2 do
        for dy = -2, 2 do
            if math.abs(dx) + math.abs(dy) > 0 then
                love.graphics.printf(text, dx, y + dy + 2, VIRTUAL_WIDTH, 'center')
            end
        end
    end

    love.graphics.setColor(gColors['scarlet'])
    for dx = -1, 1 do
        for dy = -1, 1 do
            love.graphics.printf(text, dx, y + dy, VIRTUAL_WIDTH, 'center')
        end
    end

    love.graphics.setColor(gColors['white'])
    love.graphics.printf(text, 0, y - 1, VIRTUAL_WIDTH, 'center')

    if gFonts['small'] then
        local subtitle = "- SURVIVAL & BREWS -"
        love.graphics.setFont(gFonts['small'])
        
        love.graphics.setColor(gColors['curtain'])
        love.graphics.printf(subtitle, 0, y + 27, VIRTUAL_WIDTH, 'center')
        
        love.graphics.setColor(gColors['brown'])
        love.graphics.printf(subtitle, 0, y + 26, VIRTUAL_WIDTH, 'center')
    end
end