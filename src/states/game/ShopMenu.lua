ShopMenu = class {__includes = BaseState}

function ShopMenu:init()
    self.background = ShopBackground()
    gStateStack:push(self.background)
    self.currentY = 0
    self.scrollState = {value = self.currentY, min = 0, max = 500}
end

function ShopMenu:update(dt)
    suit.Slider(self.scrollState, {vertical = true, x = 400, y = 50, w = 20, h = 150})
    self.currentY = 50 - self.scrollState.value
end

function ShopMenu:render()
end