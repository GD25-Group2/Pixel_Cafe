SaveSlotState = class{__includes = BaseState}

function SaveSlotState:init()
    self.slotsData = {}
    self.interactables = {}

    local panelW = 320
    local panelH = 170
    local panelX = math.floor(VIRTUAL_WIDTH / 2 - panelW / 2) --56
    local panelY = math.floor(VIRTUAL_HEIGHT / 2 - panelH / 2) --36

    for i = 1, 3 do
        local filename = 'slot' .. i .. '.json'
        local meta = DataManager:getSlotMetadata(filename)
        self.slotsData[i] = meta

        if meta then
            local loadBtn = Button({
                text = 'LOAD',
                x = panelX + panelW - 95,
                y = panelY + 18 + (i - 1) * 42,
                desired_width = 40,
                desired_height = 16,
                clickable = true,
                defaultColor = gColors['white'],
                hoverColor = gColors['yellow'],
                action = function()
                    DataManager.currentSlotFile = filename
                    SAVE_FILE = filename 
                    DataManager:load(filename)
                    if StockManager and StockManager.load then
                        StockManager:load()
                    end
                    gStateStack:clear()
                    gStateStack:push(PlayState())
                end
            })
            table.insert(self.interactables, loadBtn)

            local deleteBtn = Button({
                text = 'DEL',
                x = panelX + panelW - 50,
                y = panelY + 18 + (i - 1) * 42,
                desired_width = 40,
                desired_height = 16,
                clickable = true,
                defaultColor = gColors['red'],
                hoverColor = gColors['scarlet'],
                action = function()
                    love.filesystem.remove(filename)
                    
                    if DataManager.currentSlotFile == filename then
                        DataManager.currentSlotFile = nil
                    end
                    if SAVE_FILE == filename then
                        SAVE_FILE = nil
                    end

                    gStateStack:clear()
                    gStateStack:push(SaveSlotState())
                end
            })
            table.insert(self.interactables, deleteBtn)
        end
    end

    self.backButton = Button(BUTTON_PARAMS['SlotsBack'])
    table.insert(self.interactables, self.backButton)

    self.card = SaveSlotStateCard({
        slotsData = self.slotsData,
        panelW = panelW,
        panelH = panelH,
        panelX = panelX,
        panelY = panelY
    })
    gStateStack:push(self.card)

    for _, btn in ipairs(self.interactables) do
        gStateStack:push(btn)
    end
end

function SaveSlotState:update(dt)
    self:mouseResponse()
end