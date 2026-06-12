ShopItem = class {__includes = BaseEntity}

local buffer = 5

function ShopItem:init(data)
    BaseEntity.init(self, ITEM_LOG_CONFIG)

    if data then
        self.type = data.type
        self.frame = data.frame
        self.id = data.id
        self.name = data.name
        self.stock = data.stock
        self.purchasable = data.purchasable
        if data.level then
            self.level = data.level
            self.price = data.price * (2 ^ (self.level - 1))
        else
            self.price = data.price
        end
    end

    self.changeY = 0
    self.isVisible = true

    self.y = (self.id * (self.desired_height + buffer)) + 20 + buffer

    local bText = self.purchasable and 'Purchase' or 'Upgrade'

    if self.type ~= 'Label' then
        self.button = Button({
            text = bText,
            x = self.buttonX,
            y = self.y + buffer * 2,
            desired_width = 48,
            desired_height = 16,
            action = function()
                if self.purchasable and DataManager:getData('totalMoney') >= self.price then
                    self.stock = StockManager:purchase(self.type, self.price)
                elseif not self.purchasable and self.level < 3 and DataManager:getData('totalMoney') >= self.price then
                    StockManager:upgrade(self.type, self.price)
                    self.level = self.level + 1
                    self.price = self.price * 2
                end
            end,
            clickable = self.purchasable or self.level < 3,
            defaultColor = gColors['white'],
            hoverColor = gColors['yellow'],
            coordinateChange = true,
        })
    end
end

function ShopItem:update(dt)
    self.y = (self.id * (self.desired_height + buffer)) + 20 - self.changeY
end

function ShopItem:updateY(y)
    self.changeY = y
end

function ShopItem:render()
    if self.type ~= 'Label' then
        love.graphics.setColor(self.purchasable and gColors['scarlet'] or gColors['blue'])
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
        if self.purchasable then
            love.graphics.printf('Name: ' .. self.name .. '\nPrice: ' .. tostring(self.price) 
                .. '\nOwned: ' .. tostring(self.stock), self.infoX, self.y + buffer, self.infoWidth, 'left')
        else
            love.graphics.printf('Name: ' .. self.name .. '\nPrice: ' .. tostring(self.price) 
                .. '\nCurrent Level: ' .. tostring(self.level), self.infoX, self.y + buffer, self.infoWidth, 'left')
        end
    else
        love.graphics.setColor(gColors['white'])
        love.graphics.line(self.x, self.y + self.desired_height / 2, self.x + self.desired_width, self.y + self.desired_height / 2)
        love.graphics.rectangle('line', self.x + self.desired_width / 4, self.y + buffer, self.desired_width / 2, self.desired_height - buffer * 2)
        love.graphics.setColor(gColors['cyan'])
        love.graphics.rectangle('fill', self.x + self.desired_width / 4, self.y + buffer, self.desired_width / 2, self.desired_height - buffer * 2)
        love.graphics.setColor(gColors['black'])
        love.graphics.printf(self.name, self.x + self.desired_width / 4, self.y + self.desired_height / 2 - buffer, self.desired_width / 2, 'center')
    end
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