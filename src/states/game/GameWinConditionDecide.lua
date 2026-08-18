GameWinConditionDecide = class {__includes = BaseState}

function GameWinConditionDecide:init(params)
    BaseEntity.init(self, params)
    self.type = 'GameWinConditionDecide'
    self.priority = 0
    self.interactables = {}

    self.background = GameWinBackground()
    gStateStack:push(self.background)
    self.card = GameWinCard(self.hasWon)
    gStateStack:push(self.card)
    self.quitButton = Button(BUTTON_PARAMS['GameOver'])
    gStateStack:push(self.quitButton)
    table.insert(self.interactables, self.quitButton)
end

function GameWinConditionDecide:update(dt)
    self:mouseResponse()
end