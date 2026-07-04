Coin = class {__includes = BaseEntity}

local target = {
    x = VIRTUAL_WIDTH - 80 - 4 - 52,
    y = 2,
    desired_width = 16,
    desired_height = 16,
}

function Coin:init(params)
    BaseEntity.init(self, params)
    self.type = 'Coin'
    self.frame = gFrames[self.type]
    self.id = COIN_INDEX
    COIN_INDEX = COIN_INDEX + 1
    --self.x = self.x + math.random(-15, 15)

    self.process = {
        mode = 'out-elastic',
        duration = 0.8,
        --delay = 1,
        birth_duration = 0.35,
        final_delay = 0.35,
        bob_duration = 0.25,
    }

    self.removeSelf = function ()
        gStateStack:pop(self)
        print("Coin-removeSelf successfully cleared instance")
        Signal:remove('coin-remove-' .. tostring(self.id))
    end

    Signal:register('coin-remove-' .. tostring(self.id), self.removeSelf)

    MoveToStation.init(self, target, self.process)
end

function Coin:render()
    BaseEntity.render(self)
end