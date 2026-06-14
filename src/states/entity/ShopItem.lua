ShopItem = class {__includes = BaseEntity}

function ShopItem:init(data, card)
    self.type = data.type
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
    
    self.card = card
    self.innerX = card.x + 10
    self.innerY = card.y + 60
    self.innerW = card.width - 20
    self.innerH = card.height - 90
    self.height = 45
    self.changeY = 0
    self.isVisible = true
    
    self.y = self.innerY + 5 + (self.id * self.height)
    
    if self.type ~= 'Label' then
        local bText = self.purchasable and 'Purchase' or (self.level >= 3 and 'Max' or 'Upgrade')
        
        self.button = Button({
            text = bText,
            x = self.card.x + self.card.width - 80,
            y = self.y + 11,
            desired_width = 60,
            desired_height = 18,
            action = function()
                local totalMoney = DataManager:getData('totalMoney') or 0
                if self.purchasable and totalMoney >= self.price then
                    self.stock = StockManager:purchase(self.type, self.price)
                elseif not self.purchasable and self.level < 3 and totalMoney >= self.price then
                    StockManager:upgrade(self.type, self.price)
                    self.level = self.level + 1
                    self.price = self.price * 2
                    if self.level >= 3 then
                        self.button.clickable = false
                        self.button.text = 'Max'
                    end
                end
            end,
            clickable = self.purchasable or self.level < 3,
            defaultColor = gColors['white'],
            hoverColor = gColors['yellow'],
            coordinateChange = true,
            id = self.id,
            item_height = self.height,
            buffer = 5,
            scrollY = 0
        })
        
        local originalRender = self.button.render
        self.button.render = function(btnSelf)
            if self.isVisible then
                love.graphics.setScissor(self.innerX, self.innerY, self.innerW, self.innerH)
                originalRender(btnSelf)
                love.graphics.setScissor()
            end
        end
    end
end

function ShopItem:update(dt)
    self.y = self.innerY + 5 + (self.id * self.height) - self.changeY
end

function ShopItem:updateY(y)
    self.changeY = y
end

function ShopItem:render()
    if not self.isVisible then return end
    
    love.graphics.setScissor(self.innerX, self.innerY, self.innerW, self.innerH)
    
    if self.type ~= 'Label' then
        love.graphics.setColor(self.purchasable and {0.22, 0.14, 0.16, 1} or {0.14, 0.16, 0.22, 1})
        love.graphics.rectangle('fill', self.innerX + 5, self.y, self.innerW - 10, 40, 4, 4)
        love.graphics.setColor(self.purchasable and gColors['scarlet'] or gColors['blue'])
        love.graphics.rectangle('line', self.innerX + 5, self.y, self.innerW - 10, 40, 4, 4)
        
        love.graphics.setColor(gColors['white'])
        love.graphics.setFont(gFonts['small'])
        love.graphics.printf("Name: " .. self.name, self.innerX + 15, self.y + 5, self.innerW, 'left')
        
        love.graphics.setColor(0.7, 0.7, 0.7, 1)
        if self.purchasable then
            love.graphics.printf("Price: " .. self.price, self.innerX + 15, self.y + 20, self.innerW, 'left')
            love.graphics.printf("Owned: " .. self.stock, self.innerX + 100, self.y + 20, self.innerW, 'left')
        else
            love.graphics.printf("Price: " .. self.price, self.innerX + 15, self.y + 20, self.innerW, 'left')
            love.graphics.printf("Level: " .. self.level, self.innerX + 100, self.y + 20, self.innerW, 'left')
        end
    else
        love.graphics.setColor(gColors['white'])
        love.graphics.line(self.innerX + 10, self.y + self.height / 2, self.innerX + self.innerW - 10, self.y + self.height / 2)
        love.graphics.rectangle('line', self.innerX + self.innerW / 4, self.y + 8, self.innerW / 2, 24, 4, 4)
        love.graphics.setColor(gColors['cyan'])
        love.graphics.rectangle('fill', self.innerX + self.innerW / 4, self.y + 8, self.innerW / 2, 24, 4, 4)
        love.graphics.setColor(gColors['black'])
        love.graphics.setFont(gFonts['small'])
        love.graphics.printf(self.name, self.innerX + self.innerW / 4, self.y + 13, self.innerW / 2, 'center')
    end
    
    love.graphics.setScissor()
end

function ShopItem:getButton()
    return self.button
end

function ShopItem:getBottom()
    return self.y + self.height
end

function ShopItem:getHeight()
    return self.height
end