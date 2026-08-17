Guide = class {__includes = BaseState}

local width, height = 64, 64

local function merge(...)
    local res = {}
    for _, tbl in ipairs({...}) do
        for k, v in pairs(tbl) do
            res[k] = v
        end
    end
    return res
end

local places = {
    ['top-left']      = { x = 50, y = 50 },
    ['top-center']    = { x = VIRTUAL_WIDTH / 2 - width / 2, y = 50 },
    ['top-right']     = { x = VIRTUAL_WIDTH - width - 50, y = 50 },
    ['middle-left']   = { x = 50, y = VIRTUAL_HEIGHT / 2 - height / 2 },
    ['middle-center'] = { x = VIRTUAL_WIDTH / 2 - width / 2, y = VIRTUAL_HEIGHT / 2 - height / 2 },
    ['middle-right']  = { x = VIRTUAL_WIDTH - width - 50, y = VIRTUAL_HEIGHT / 2 - height / 2 },
    ['bottom-left']   = { x = 50, y = VIRTUAL_HEIGHT - height - 50 },
    ['bottom-center'] = { x = VIRTUAL_WIDTH / 2 - width / 2, y = VIRTUAL_HEIGHT - height - 50 },
    ['bottom-right']  = { x = VIRTUAL_WIDTH - width - 50, y = VIRTUAL_HEIGHT - height - 50 },
}

local phaseOrder = {
    'Do you need a GuideMascot?', -- 1
    'Shop Explain',
    'Drag and Drop',
    'Brew',
    'Serve Customer', -- 5
    'Money Explain',
    'Time Explain',
    'Reputation Explain',
    'Equipment Unlock',
    'Knife', -- 9
}

local phases = {
    ['Do you need a GuideMascot?'] = merge(places['middle-center'], {
        preferLeft = true,
        text = "Do you need a Tutorial? Press 'Enter' to continue or 'X' to deny!",
        text_width = 50,
    }),
    ['Shop Explain'] = merge(places['top-right'], {
        preferLeft = true,
        text = "This is the shop where you can buy consumable groceries and upgrade machines. " ..
               "Beware! This shop is only available at the start of the day. Click " ..
               "'Start Shift' to continue your challenge!",
        text_width = 100,
        highlight = {
            x = GAME_START_CONFIG.x + GAME_START_CONFIG.width / 2 - 40,
            y = GAME_START_CONFIG.y + GAME_START_CONFIG.height - 25,
            desired_width = 80,
            desired_height = 20
        },
    }),
    ['Drag and Drop'] = merge(places['top-left'], {
        preferLeft = false,
        text = "Drag the Cup and put it on the Tray. You can put up to 4 cups.",
        text_width = 50,
        signal = 'cup-placed-on-tray',
        highlight = { x = 10, y = 140, desired_width = 82, desired_height = 32 },
    }),
    ['Brew'] = merge(places['middle-center'], {
        preferLeft = true,
        text = "Click Coffee Machine to brew your first coffee. Drag the Coffee Jar to prepared cups.",
        text_width = 50,
        signal = 'jar-placed-on-cup',
        highlight = { x = 10, y = 70, desired_width = 80, desired_height = 80 },
    }),
    ['Equipment Unlock'] = merge(places['middle-center'], {
        preferLeft = true,
        text = 'New machines unlock over time. However, you first need to buy them to use.',
        text_width = 50,
    }),
    ['Serve Customer'] = merge(places['middle-left'], {
        preferLeft = false,
        text = "Customers will come from the right side of the shop. Bring the Coffee Cup to the customer.",
        text_width = 50,
        signal = 'coffee-placed-on-customer',
        highlight = { x = 260, y = 55, desired_width = 64, desired_height = 64 },
    }),
    ['Money Explain'] = merge(places['middle-center'], {
        preferLeft = true,
        text = "This shows your current earnings. Serve customers quickly to earn more bonus.",
        text_width = 50,
        highlight = { x = VIRTUAL_WIDTH - 136, y = 2, desired_width = 52, desired_height = 12 },
    }),
    ['Time Explain'] = merge(places['middle-center'], {
        preferLeft = true,
        text = "Keep an eye on the clock! You have to work from 8:00 A.M. to 8:00 P.M.",
        text_width = 50,
        highlight = { x = VIRTUAL_WIDTH - 80, y = 2, desired_width = 56, desired_height = 12 },
    }),
    ['Reputation Explain'] = merge(places['middle-center'], {
        preferLeft = true,
        text = "Happy customers increase reputation. If customers leave unhappy, reputation decreases.",
        text_width = 50,
        highlight = { x = 210, y = 2, desired_width = 30, desired_height = 12 },
    }),
    ['Knife'] = merge(places['middle-center'], {
        preferLeft = true,
        text = "You can select and kill the customer and loot resources if you lack ingredients. However, it punishes with reduced Reputation.",
        text_width = 50,
        signal = 'slash-customer-guide',
        highlight = { x = VIRTUAL_WIDTH - 130, y = 110, desired_width = 32, desired_height = 32, },
    }),
}

function Guide:init(params)
    BaseEntity.init(self, params)
    self.priority = 1
    self.type = 'Guide'
    
    for i = #gStateStack.states, 1, -1 do
        local entity = gStateStack.states[i]
        if entity.type == 'DimBackground' or entity.type == 'Mascot' then
            table.remove(gStateStack.states, i)
        end
    end

    if DataManager:getData('guidePhase') == 0 then return end
    self.stepKey = self.stepKey or tonumber(DataManager:getData('guidePhase')) or 1
    if self.stepKey < DataManager:getData('guidePhase') then
        gStateStack:pop(self)
        return
    end
    
    if self.stepKey <= 0 or self.stepKey > #phaseOrder then
        print('Guide - isFinished', self.stepKey)
        self.isFinished = true
        return
    end

    self.phase = phases[phaseOrder[self.stepKey]]

    local left, right = - self.phase.text_width - 10, self.phase.text_width + 10

    self.mascot = GuideMascot({x = self.phase.x, y = self.phase.y})
    local textBox_x = self.phase.x + (self.phase.preferLeft and left or right)
    self.textBox = TextBox({
        x = textBox_x,
        y = self.phase.y, 
        text = self.phase.text, 
        forGuide = true, 
        counterDisable = true, 
        desired_width = self.phase.text_width
    })
    print('Guide- left: ' .. self.textBox.x .. ' right: ' .. self.textBox.x + self.textBox.desired_width)
    self.background = DimBackground({mascot = self.mascot, highlight = self.phase.highlight, textBox = self.textBox})

    gStateStack:push(self.background)
    gStateStack:push(self.mascot)
    gStateStack:push(self.textBox)

    if self.phase.signal then
        self.signalCallback = function()
            self:dismiss()
        end
        Signal:register(self.phase.signal, self.signalCallback)
    end

    local returnStep
    returnStep = function ()
        Signal:remove('ask-guide-stepKey', returnStep)
        return self.stepKey
    end
    Signal:register('ask-guide-stepKey', returnStep)
end

function Guide:update(dt)
    if self.isFinished or (not self.phase) then
        Signal:emit('destroy-GuideMascot')
        Signal:emit('destroy-DimBackground')
        Signal:emit('destroy-TextBox')
        gStateStack:pop(self)
        return
    end

    if self.stepKey == 1 then
        if love.keyboard.wasPressed('x') or love.keyboard.wasPressed('X') then
            self.stepKey = -1
            self:dismiss()
        elseif love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
            self:dismiss()
        end
    else
        if not self.phase.signal and (love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return')) then
            self:dismiss()
        end
    end
end

function Guide:dismiss()
    if self.phase and self.phase.signal and self.signalCallback then
        Signal:remove(self.phase.signal, self.signalCallback)
    end

    if self.textBox then gStateStack:pop(self.textBox) end
    if self.mascot then gStateStack:pop(self.mascot) end
    if self.background then gStateStack:pop(self.background) end

    self.stepKey = self.stepKey + 1
    DataManager:set('guidePhase', self.stepKey)

    local key = self.stepKey - 1
    if key == 1 or key <= 0 or key == 10 then
        self.action = function ()
            Signal:emit('guide-summon')
            Signal:emit('summonShop')
        end
    elseif key == 3 or key == 4 or key == 5 or key == 6 or key == 7 or key == 9 then
        self.action = function ()
            Signal:emit('guide-summon', self.stepKey)
        end
    end

    if self.action then
        Signal:remove('guide-last-move')
        Signal:register('guide-last-move', self.action)
    end
    
    gStateStack:pop(self, self.action and 'guide-last-move')
end