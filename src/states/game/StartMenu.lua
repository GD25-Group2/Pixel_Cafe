StartMenu = class{__includes = BaseState}

function StartMenu:init()
    self.type = 'StartMenu'

    self.playButton = Button(BUTTON_PARAMS['Play'])
    self.newButton = Button(BUTTON_PARAMS['New'])
    self.settingsButton = Button(BUTTON_PARAMS['StartSettings'])
    self.quitButton = Button(BUTTON_PARAMS['MenuQuit'])
    self.background = StartMenuBackground()
    self.popup = PopupWindow(POPUP_WINDOW_CONFIG)

    local hasSaveData = false
    for i = 1, 3 do
        if love.filesystem.getInfo('slot' .. i .. '.json') then
            hasSaveData = true
            break
        end
    end
    
    if hasSaveData then
        self.playButton:enable()
    end

    if love.filesystem.getInfo(SETTING_FILE) then
        DataManager:loadSettings(SETTING_FILE)
    end

    self.interactables = {
        self.playButton,
        self.newButton,
        self.settingsButton,
        self.quitButton
    }

    gStateStack:push(self.background)
    gStateStack:push(self.playButton)
    gStateStack:push(self.newButton)
    gStateStack:push(self.settingsButton)
    gStateStack:push(self.quitButton)
    gStateStack:push(self.popup)

    -- Start music when the window opens
    if gMusic and not gMusic:isPlaying() then
        gMusic:setVolume(gSettings.musicVolume)
        gMusic:play()
    end
end

function StartMenu:update(dt)
    self:mouseResponse()
end