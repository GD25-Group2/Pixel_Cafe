PlateManager = class {__includes = BaseEntity}

local buffer = 2
local MAX_UPGRADE_LEVEL = 3

function PlateManager:init()
    BaseEntity.init(self, PLATE_MANAGER_CONFIG)

    self.type = 'PlateManager'
    
    local currentLevel = StockManager:getLevel(self.type) or 0
    if currentLevel == 0 then currentLevel = 1 end
    self.level = currentLevel
    
    print('Plate Manager Active Level:', self.level)
    self.plates = {}

    for i = 1, MAX_UPGRADE_LEVEL do
        local startActive = (i <= self.level)
        self:addPlate(i, startActive)
    end

    local addPlate = function ()
        self.upgradedLevel = StockManager:getLevel(self.type)
    end

    Signal:register('plate-manager-plate-add', addPlate)
end

function PlateManager:addPlate(index, isActive)
    local plate = Plate({
        x = self.x + ((index - 1) * (32 + buffer)),
        y = self.y + buffer,
        desired_width = 32,
        desired_height = 32,
        activated = isActive,
    })
    local plate2 = Plate({
        x = self.x + ((index - 1) * (32 + buffer)),
        y = self.y + 32 + buffer * 2,
        desired_width = 32,
        desired_height = 32,
        activated = isActive,
    })
    
    table.insert(self.plates, plate)
    table.insert(self.plates, plate2)
    gStateStack:push(plate)
    gStateStack:push(plate2)
    
    if isActive then
        Signal:emit('plate-manager-plate-added', plate)
        Signal:emit('plate-manager-plate-added', plate2)
    end
end

function PlateManager:update(dt)
    if self.upgradedLevel and self.upgradedLevel > self.level then
        for l = self.level + 1, self.upgradedLevel do
            local idx1 = (l - 1) * 2 + 1
            local idx2 = (l - 1) * 2 + 2

            if self.plates[idx1] then
                self.plates[idx1]:activate()
                Signal:emit('plate-manager-plate-added', self.plates[idx1])
            end
            if self.plates[idx2] then
                self.plates[idx2]:activate()
                Signal:emit('plate-manager-plate-added', self.plates[idx2])
            end
        end

        self.level = self.upgradedLevel
    end
end

function PlateManager:render()
    love.graphics.setColor(gColors['red'])
    love.graphics.rectangle('line', self.x, self.y, self.desired_width, self.desired_height)
end