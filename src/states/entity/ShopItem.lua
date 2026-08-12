ShopItem = class {__includes = BaseEntity}

function ShopItem:init(data)
    BaseEntity.init(self, data)
    self.priority = 20
    self.type = data.type
    self.id = data.id
    self.name = data.name
    self.stock = data.stock or 0
    self.purchasable = data.purchasable
    self.isConsumable = data.isConsumable
    self.level = data.level
    self.price = data.price

    self.innerX = data.innerX or 10
    self.innerY = data.innerY or 60
    self.innerW = data.innerW or (VIRTUAL_WIDTH - 20)
    self.innerH = data.innerH or (VIRTUAL_HEIGHT - 90)
    self.height = 45
    self.changeY = 0
    self.isVisible = true
    
    self.y = self.innerY + 5 + (self.id * self.height)
    
    if self.type ~= 'Label' then
        local bText = 'Purchase'
        local isClickable = self.purchasable

        if not self.isConsumable then
            if not self.level or self.level >= MAX_MACHINE_LEVEL or not self.price then
                bText = 'Max'
                isClickable = false
            else
                bText = 'Upgrade'
            end
        end
        
        self.button = Button({
            text = bText,
            x = self.innerX + self.innerW - 75,
            y = self.y + 11,
            desired_width = 60,
            desired_height = 18,
            action = function()
                local totalMoney = DataManager:getData('totalMoney') or 0
                
                if self.isConsumable then
                    -- Consumable Purchase
                    if self.purchasable and totalMoney >= self.price then
                        local newStock = StockManager:purchase(self.type, self.price)
                        if type(newStock) == "number" then
                            self.stock = newStock
                        else
                            local totals = StockManager:getStockTotal()
                            self.stock = (totals and totals[self.type]) or (self.stock + 1)
                        end
                    end
                else
                    -- Machine Upgrade
                    if self.level and self.level < MAX_MACHINE_LEVEL and self.price and totalMoney >= self.price then
                        StockManager:upgrade(self.type, self.price)
                        self.level = self.level + 1
                        self.price = StockManager:getUpgradePrice(self.type, self.level)
                        
                        if self.level >= MAX_MACHINE_LEVEL or not self.price then
                            self.button.clickable = false
                            self.button.text = 'Max'
                        end
                    end
                end
            end,
            clickable = isClickable,
            defaultColor = gColors['white'],
            hoverColor = gColors['yellow'],
            coordinateChange = true,
            id = self.id,
            item_height = self.height,
            buffer = 5,
            scrollY = 0,
            changeY = 0 
        })
        
        local originalRender = self.button.render
        self.button.render = function(btnSelf)
            if self.isVisible then
                love.graphics.setScissor(self.innerX, self.innerY, self.innerW, self.innerH)
                originalRender(btnSelf)
                love.graphics.setScissor()
            end
        end
        
        local originalUpdate = self.button.update
        self.button.update = function(btnSelf, dt)
            if originalUpdate then originalUpdate(btnSelf, dt) end
            btnSelf.x = self.innerX + self.innerW - 75
            btnSelf.y = self.y + 11
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
        love.graphics.setColor(self.isConsumable and {0.22, 0.14, 0.16, 1} or {0.14, 0.16, 0.22, 1})
        love.graphics.rectangle('fill', self.innerX + 5, self.y, self.innerW - 10, 40, 4, 4)
        love.graphics.setColor(self.isConsumable and gColors['scarlet'] or gColors['blue'])
        love.graphics.rectangle('line', self.innerX + 5, self.y, self.innerW - 10, 40, 4, 4)
        
        love.graphics.setColor(gColors['white'])
        love.graphics.setFont(gFonts['small'])
        love.graphics.printf("Name: " .. self.name, self.innerX + 15, self.y + 5, self.innerW, 'left')
        
        love.graphics.setColor(0.7, 0.7, 0.7, 1)
        if self.isConsumable then
            love.graphics.printf("Price: " .. self.price, self.innerX + 15, self.y + 20, self.innerW, 'left')
            love.graphics.printf("Owned: " .. (self.stock or 0), self.innerX + 100, self.y + 20, self.innerW, 'left')
        else
            local priceStr = self.price and tostring(self.price) or "MAX"
            love.graphics.printf("Price: " .. priceStr, self.innerX + 15, self.y + 20, self.innerW, 'left')
            love.graphics.printf("Level: " .. tostring(self.level or 1), self.innerX + 100, self.y + 20, self.innerW, 'left')
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