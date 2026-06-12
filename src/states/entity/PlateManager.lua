PlateManager = class {__includes = BaseEntity}

local buffer = 2

function PlateManager:addPlate(index)
    local plate = Plate({
        x = self.x + ((index - 1) * (32 + buffer)),
        y = self.y + buffer,
        desired_width = 32,
        desired_height = 32,
    })
    local plate2 = Plate({
        x = self.x + ((index - 1) * (32 + buffer)),
        y = self.y + 32 + buffer * 2,
        desired_width = 32,
        desired_height = 32,
    })
    table.insert(self.plates, plate)
    table.insert(self.plates, plate2)
    gStateStack:push(plate)
    gStateStack:push(plate2)
    Signal:emit('plate-manager-plate-added', plate)
    Signal:emit('plate-manager-plate-added', plate2)
end

function PlateManager:init()
    BaseEntity.init(self, PLATE_MANAGER_CONFIG)

    self.type = 'PlateManager'
    self.level = StockManager:getLevel(self.type)
    print('Plate Manager Level:', self.level)
    self.plates = {}

    for i = 1, self.level do
        self:addPlate(i)
    end

    local addPlate = function ()
        local updatedLevel = StockManager:getLevel(self.type)
        if updatedLevel > self.level then
            self:addPlate(updatedLevel)
        end
    end

    Signal:register('plate-manager-plate-add', addPlate)
end

function PlateManager:render()
    love.graphics.setColor(gColors['red'])
    love.graphics.rectangle('line', self.x, self.y, self.desired_width, self.desired_height)
end