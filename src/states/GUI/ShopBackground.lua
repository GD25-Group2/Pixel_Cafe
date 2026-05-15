ShopBackground = class {__includes = BaseState}

function ShopBackground:init()
    self.isGUI = true
end

function ShopBackground:render()
    love.graphics.setColor(gColors['curtain'])
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    love.graphics.setColor(gColors['white'])
end