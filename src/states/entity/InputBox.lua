InputBox = class {__includes = BaseEntity}

suit.theme.color = {
    normal = { bg = gColors['black'], fg = gColors['white']},
    hovered = { bg = gColors['black'], fg = gColors['white']},
    active = { bg = gColors['black'], fg = gColors['white']}
}
suit.theme.cornerRadius = 0

function InputBox:init(params)
    BaseEntity.init(self, params)
    self.priority = 95
    self.isHovering = false
    self.isGUI = true
    self.clickable = true
    self.id = params.id or tostring(self)
    
    self.input = { text = "" }
    
    self.focusFrames = 3
end

function InputBox:clear()
    self.input.text = ""
    suit.textinput("")
    suit.keypressed(nil)
end

function InputBox:update(dt)
    if self.clickable then
        self.isHovering = self:isMouseOver()
    end

    if self.focusFrames > 0 then
        suit.setActive(self.id)
        love.keyboard.setTextInput(true)
    end

    local state = suit.Input(
        self.input,
        { id = self.id },
        self.x or 0,
        self.y or 0,
        self.desired_width or self.width or 120,
        self.desired_height or self.height or 30
    )

    if self.focusFrames > 0 then
        suit.setActive(self.id)
        
        if not love.mouse.isDown(1) then
            self.focusFrames = self.focusFrames - 1
        end
    end

    if state.submitted then 
        local raw = self.input.text
        self.input.text = '' 

        if raw ~= '' then
            self.submittedRaw = raw
            self.submittedTokens = {}
            for token in raw:gmatch("%S+") do 
                table.insert(self.submittedTokens, token) 
            end
        else
            self.submittedRaw = nil
            self.submittedTokens = nil
        end
    end
end

function InputBox:render()
    suit.draw()
end

function InputBox:clicked()
    if self.clickable then
        if gSounds['click'] then
            gSounds['click']:setVolume(gSettings.sfxVolume)
            gSounds['click']:stop()
            gSounds['click']:play()
        end
        suit.setActive(self.id)
    end
end

function InputBox.textinput(t) suit.textinput(t) end
function InputBox.textedited(text, start, length) suit.textedited(text, start, length) end
function InputBox.keypressed(key) suit.keypressed(key) end