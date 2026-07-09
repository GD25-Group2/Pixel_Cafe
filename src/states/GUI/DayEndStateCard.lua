DayEndStateCard = class {__includes = BaseState}

function DayEndStateCard:init(params)
    self.isGUI = true
    self.earnedToday = 0 
    self.finalTotal = params.finalTotal
    self.currentDate = params.currentDate
    self.gameOver = params.gameOver or false
    self.backgroundFrame = gFrames['DayEndBackground']
    self.text = ''
    self.amount = false

    self.transReceipt = params.transReceipt or {}
    self.history = {}
    self.counter = 0
    self.duration = 1
    self.done = false
end

function DayEndStateCard:update(dt)
    if not self.done then
        self.counter = self.counter + dt
        if self.counter >= self.duration then
            if #self.transReceipt > 0 then
                self.counter = 0
                local v = table.remove(self.transReceipt, 1)
                
                self.text = v[1]   
                self.amount = v[2] 
                
                if self.amount then 
                    local numericAmount = tonumber(self.amount) or 0
                    self.earnedToday = self.earnedToday + numericAmount 
                end
                
                table.insert(self.history, {text = self.text, amount = self.amount})
                
                if gSounds and gSounds['receipt-tick'] then
                    gSounds['receipt-tick']:stop()
                    gSounds['receipt-tick']:play()
                end
            end

            if #self.transReceipt == 0 then
                self.done = true
                self.text = ''
                self.amount = false
            end
        end
    end
end

function DayEndStateCard:render()
    love.graphics.setColor(gColors['white'])
    love.graphics.draw(self.backgroundFrame, 0, 0, 0, VIRTUAL_WIDTH / self.backgroundFrame:getWidth(), VIRTUAL_HEIGHT / self.backgroundFrame:getHeight())
    local card = UI_CARD
    
    card.height = 195 

    love.graphics.setColor(card.color)
    love.graphics.rectangle('fill', card.x, card.y, card.width, card.height, 6, 6)

    love.graphics.setColor(card.border)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle('line', card.x, card.y, card.width, card.height, 6, 6)

    love.graphics.setColor(gColors['white'])
    love.graphics.setFont(gFonts['large'])
    local text = self.gameOver and 'GAME OVER' or 'DAY END'
    love.graphics.printf(text, card.x, card.y + 6, card.width, 'center')

    love.graphics.setFont(gFonts['medium'])
    local line1Y = card.y + 42
    local line2Y = card.y + 60
    local labelOffset = 20
    local radius = 25
    
    -- Line 1: Total
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf('Total', card.x + labelOffset, line1Y, card.width - labelOffset, 'left')
    love.graphics.setColor(0.2, 0.8, 0.2, 1)
    love.graphics.printf(string.format('$%.2f', self.finalTotal), card.x, line1Y, card.width - labelOffset, 'right')
    
    -- Line 2: Earned
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf('Earned', card.x + labelOffset, line2Y, card.width - labelOffset, 'left')
    love.graphics.setColor(0.2, 0.8, 0.2, 1)
    love.graphics.printf(string.format('$%.2f', self.earnedToday), card.x, line2Y, card.width - labelOffset, 'right')
    
    -- ─── Dynamic Itemized Transaction Receipt Table ───
    if not self.gameOver then
        local tableX = card.x + labelOffset
        local tableY = card.y + 85
        local tableW = card.width - (labelOffset * 2)
        local tableH = 95
        
        love.graphics.setColor(0.05, 0.05, 0.07, 0.85)
        love.graphics.rectangle('fill', tableX, tableY, tableW, tableH, 4, 4)
        love.graphics.setColor(card.border)
        love.graphics.rectangle('line', tableX, tableY, tableW, tableH, 4, 4)
        
        local maxLines = 6
        local startIdx = math.max(1, #self.history - maxLines + 1)
        local drawCount = 0
        
        love.graphics.setFont(gFonts['small'])
        
        for i = startIdx, #self.history do
            local item = self.history[i]
            local itemY = tableY + 6 + (drawCount * 14)
            
            if i == #self.history and not self.done then
                local flashAlpha = 0.4 + math.sin(love.timer.getTime() * 15) * 0.6
                love.graphics.setColor(1, 1, 0.4, flashAlpha)
            else
                love.graphics.setColor(0.9, 0.9, 0.9, 1)
            end
            
            love.graphics.printf(tostring(item.text), tableX + 6, itemY, tableW, 'left')
            
            if i == #self.history and not self.done then
                local flashAlpha = 0.4 + math.sin(love.timer.getTime() * 15) * 0.6
                love.graphics.setColor(0.4, 1, 0.4, flashAlpha)
            else
                love.graphics.setColor(0.2, 0.8, 0.2, 1)
            end
            love.graphics.printf(string.format('+$%.2f', tonumber(item.amount) or 0), tableX, itemY, tableW - 6, 'right')
            
            drawCount = drawCount + 1
        end
        
        if #self.history == 0 then
            love.graphics.setColor(0.4, 0.4, 0.4, 1)
            love.graphics.printf('(Awaiting Ledger Receipts...)', tableX, tableY + (tableH / 2) + 20, tableW, 'center')
        end
    end

    -- Line 3: Date Stamp Badge
    love.graphics.setColor(gColors['white'])
    love.graphics.circle('fill', card.x, card.y, radius)
    love.graphics.setLineWidth(3)
    love.graphics.setColor(gColors['yellow'])
    love.graphics.circle('line', card.x, card.y, radius)
    love.graphics.setLineWidth(1)
    love.graphics.setFont(gFonts['large'])
    love.graphics.setColor(gColors['black'])
    love.graphics.printf(tostring(self.currentDate), card.x - radius, card.y - radius / 2, radius * 2, 'center')
    love.graphics.setColor(gColors['white'])
end