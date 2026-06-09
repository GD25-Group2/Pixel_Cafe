KnifeAndBoard = class {__includes = BaseEntity}

function KnifeAndBoard:init()
    BaseEntity.init(self, KNIFE_BOARD_CONFIG)
    self.type = 'KnifeAndBoard'
end

function KnifeAndBoard:update(dt)

end

function KnifeAndBoard:render()
    love.graphics.setColor(gColors['cyan'])
    love.graphics.rectangle('fill', self.x, self.y, self.desired_width, self.desired_height)
    love.graphics.setColor(gColors['white'])
    love.graphics.printf(self.type, self.x, self.y + 20, self.desired_width, 'center')
end