SaveSlotStateCard = class{__includes = BaseState}

function SaveSlotStateCard:init(params)
    self.isGUI = true
    self.slotsData = params.slotsData
    self.panelW = params.panelW
    self.panelH = params.panelH
    self.panelX = params.panelX
    self.panelY = params.panelY
    self.backgroundFrame = gFrames['SaveSlotBackground']
end

function SaveSlotStateCard:render()
    love.graphics.setColor(gColors['white'])
    love.graphics.draw(self.backgroundFrame, 0, 0, 0, VIRTUAL_WIDTH / self.backgroundFrame:getWidth(), VIRTUAL_HEIGHT / self.backgroundFrame:getHeight())

    love.graphics.setColor(0.14, 0.16, 0.22, 0.5)
    love.graphics.rectangle('fill', self.panelX, self.panelY, self.panelW, self.panelH, 4)
    love.graphics.setColor(0.4, 0.5, 0.6, 1)
    love.graphics.rectangle('line', self.panelX, self.panelY, self.panelW, self.panelH, 4)

    for i = 1, 3 do
        local startY = self.panelY + 20 + (i - 1) * 42
        love.graphics.setColor(gColors['white'])
        love.graphics.print('SLOT ' .. i .. ':', self.panelX + 15, startY)

        if self.slotsData[i] then
            local data = self.slotsData[i]
            love.graphics.print(tostring(data.name), self.panelX + 75, startY)
            love.graphics.setColor(gColors['yellow'])
            love.graphics.print('Day ' .. tostring(data.currentDate), self.panelX + 150, startY)
            love.graphics.setColor(gColors['green'])
            love.graphics.print('$' .. tostring(data.totalMoney), self.panelX + 205, startY)
        else
            love.graphics.setColor(gColors['gray'])
            love.graphics.print('- EMPTY SAVE SLOT -', self.panelX + 75, startY)
        end
    end
end