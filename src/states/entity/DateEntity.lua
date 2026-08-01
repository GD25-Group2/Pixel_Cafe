DateEntity = class {__includes = BaseEntity}

function DateEntity:init(params)
    BaseEntity.init(self, params)
    self.type = 'DateEntity'
    self.priority = 85

    self.currentDate = DataManager:getData('currentDate')
end


function DateEntity:render()
    love.graphics.setFont(gFonts['small'])

    local dateText = 'Day ' .. tostring(self.currentDate)

    local plateX = VIRTUAL_WIDTH - 80 - 4 - 52 - 4 - 42
    local plateY = 2
    local plateW = 42
    local plateH = 12
    local plateR = 3

    love.graphics.setColor(0.12, 0.12, 0.18, 0.75)
    love.graphics.rectangle('fill', plateX, plateY, plateW, plateH, plateR, plateR)
    love.graphics.setColor(0.3, 0.3, 0.4, 0.5)
    love.graphics.rectangle('line', plateX, plateY, plateW, plateH, plateR, plateR)

    love.graphics.setColor(1, 0.85, 0.45, 1)
    love.graphics.printf(dateText, plateX, plateY + 2, plateW, 'center')
    love.graphics.setColor(1, 1, 1, 1)
end