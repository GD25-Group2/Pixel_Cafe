PopupWindow = class {__includes = BaseState}

function PopupWindow:init(type, slotIndex)
    self.priority = 0
    self.type = type
    self.slotIndex = slotIndex or 1

    self.text = gTexts[self.type] or 'None'

    self.card = PopupWindowCard(self.text)
    gStateStack:push(self.card)

    self.xButton = Button(BUTTON_PARAMS['PopupX'])
    gStateStack:push(self.xButton)

    self.interactables = {
        self.xButton,
    }

    if self.type == 'DataLossAsk' then
        self.okButton = Button(BUTTON_PARAMS['OkButton'])
        table.insert(self.interactables, self.okButton)
        gStateStack:push(self.okButton)
    elseif self.type == 'Dev' or self.type == 'NameGive' then
        --[[self.okButton = Button(BUTTON_PARAMS['OkNameGive'])
        table.insert(self.interactables, self.okButton)
        gStateStack:push(self.okButton)]]
        self.inputBox = InputBox(POPUP_INPUT_BOX)
        self.inputBox:clear()

        table.insert(self.interactables, self.inputBox)
        gStateStack:push(self.inputBox)
        suit.setActive('inputBox')
    end
end

function PopupWindow:update(dt)
    self:mouseResponse()
    
    -- Ensure the inputBox exists before attempting to read from it
    if not self.inputBox then return end

    -- 1. Handle Name Giving
    if self.type == 'NameGive' and self.inputBox.submittedRaw then
        local name = self.inputBox.submittedRaw
        self.inputBox.submittedRaw = nil -- Consume the submission
        
        SAVE_FILE = DataManager.currentSlotFile or 'slot1.json'
        DataManager:getDefaultData()
        DataManager:set('name', name)
        DataManager:create()
        
        StockManager:load()
        print(DataManager:getData('name'))
        
        gStateStack:clear()
        gStateStack:popupDelete()
        gStateStack:clear()
        gStateStack:push(PlayState())

    -- 2. Handle Developer Commands
    elseif self.type == 'Dev' and self.inputBox.submittedTokens then
        local tokens = self.inputBox.submittedTokens
        self.inputBox.submittedTokens = nil -- Consume the submission
        
        if string.lower(tostring(tokens[1])) == '\\dev' then
            if string.lower(tostring(tokens[2])) == 'skip' and tokens[3] then
                local targetDay = tonumber(tokens[3])
                if targetDay then
                    DataManager:modify('currentDate', targetDay - 1)
                    DataManager:ensureUnlocks(targetDay - 1)
                    gStateStack:clear()
                    gStateStack:popupDelete()
                    gStateStack:clear()
                    gStateStack:push(DayEndState())
                else
                    DataManager:modify('currentDate', tonumber(tokens[3]))
                    gStateStack:clear()
                    gStateStack:popupDelete()
                    gStateStack:clear()
                    gStateStack:push(DayEndState())
                end
            elseif string.lower(tostring(tokens[2])) == 'money' and tokens[3] then
                local amount = tonumber(tokens[3]) or 0
                gMoney = (gMoney or 0) + amount
                Signal:emit('dev-money-add', amount)
                gStateStack:clear()
                gStateStack:popupDelete()
            end
        end
    end
end

function PopupWindow:render()
end