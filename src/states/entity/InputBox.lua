local utf8 = require('utf8')

InputBox = class {__includes = BaseEntity}

suit.theme.color = {
    normal  = { bg = gColors['black'], fg = gColors['white']},
    hovered = { bg = gColors['black'], fg = gColors['white']},
    active  = { bg = gColors['black'], fg = gColors['white']}
}
suit.theme.cornerRadius = 0

-- Helper function to strip invalid UTF-8 sequences before SUIT renders
local function sanitizeUTF8(str)
    if not str or str == "" then return "" end
    if utf8.len(str) then return str end -- Valid string

    -- If corrupted, rebuild string with valid UTF-8 characters only
    local clean = ""
    for i = 1, #str do
        local sub = str:sub(1, i)
        if utf8.len(sub) then
            clean = sub
        end
    end
    return clean
end

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

    -- Clean buffer before SUIT processes
    self.input.text = sanitizeUTF8(self.input.text)

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

    -- Clean buffer after SUIT processes input
    self.input.text = sanitizeUTF8(self.input.text)

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
    -- Ensure input text is valid UTF-8 before suit.draw() calls font:getWidth()
    self.input.text = sanitizeUTF8(self.input.text)
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

function InputBox.textinput(t) 
    if t and t ~= "" then
        suit.textinput(t) 
    end
end

function InputBox.textedited(text, start, length) 
    -- Protect against OS window focus/resize composition updates
    if text then
        suit.textedited(text, start, length) 
    end
end

function InputBox.keypressed(key) 
    -- Filter out system & function hotkeys so F11 / Alt toggles aren't sent to SUIT
    if key and (key:match("^f%d+$") or key == "lalt" or key == "ralt" or key == "tab") then
        return
    end
    suit.keypressed(key) 
end