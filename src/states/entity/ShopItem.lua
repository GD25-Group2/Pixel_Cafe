ShopItem = class {__includes = BaseEntity}

local buffer = 5

function ShopItem:init(data)
    BaseEntity.init(self, ITEM_LOG_CONFIG)

    if data then
        self.frame = data.frame
        self.id = data.id
        self.name = data.name
        self.price = data.price
        self.stock = data.stock
        self.purchasable = data.purchasable
    end

    self.changeY = 0
    self.isVisible = true

    self.y = (self.id * (self.desired_height + buffer)) + 20 + buffer

    self.button = Button({
        text = 'Purchase',
        x = self.buttonX,
        y = self.y + buffer * 2,
        desired_width = 48,
        desired_height = 16,
        action = function()
            return
        end,
        clickable = self.purchasable,
        defaultColor = gColors['white'],
        hoverColor = gColors['yellow'],
        coordinateChange = true,
    })
end

function ShopItem:update(dt)
    self.y = (self.id * (self.desired_height + buffer)) + 20 - self.changeY
end

function ShopItem:updateY(y)
    self.changeY = y
end

function ShopItem:render()
    love.graphics.setColor(gColors['scarlet'])
    love.graphics.rectangle('fill', self.x, self.y, self.desired_width, self.desired_height)
    love.graphics.setColor(gColors['black'])
    love.graphics.rectangle('line', self.x, self.y, self.desired_width, self.desired_height)

    love.graphics.setColor(gColors['white'])
    love.graphics.rectangle('fill', self.frameX, self.y + buffer, self.frameWidth, self.frameHeight)
    love.graphics.setColor(gColors['black'])
    love.graphics.rectangle('line', self.frameX, self.y + buffer, self.frameWidth, self.frameHeight)
    if self.frame then
        love.graphics.setColor(gColors['white'])
        love.graphics.draw(self.frame, self.frameX, self.y + buffer, 0, 
            self.frameWidth / self.frame:getWidth(), self.frameHeight / self.frame:getHeight())
    end

    love.graphics.setColor(gColors['black'])
    love.graphics.printf('Name: ' .. self.name .. '\nPrice: ' .. tostring(self.price) 
        .. '\nStock: ' .. tostring(self.stock), self.infoX, self.y + buffer, self.infoWidth, 'left')
end

function ShopItem:getButton()
    return self.button
end

function ShopItem:getBottom()
    return self.y + self.desired_height
end

function ShopItem:getHeight()
    return self.desired_height
end