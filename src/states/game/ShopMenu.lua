ShopMenu = class {__includes = BaseState}

local items = {
    ['ItemLabel'] = {
        type = 'Label',
        frame = nil,
        id = 0,
        name = 'Consumable Items List',
        price = 0,
        stock = 0,
        purchasable = false,
    },
    ['PaperCup'] = {
        type = 'PaperCup',
        frame = nil,
        id = 1,
        name = 'Paper Cup',
        price = 2,
        stock = 0,
        purchasable = true, --if not purchasable, it is upragable
    },
    ['CoffeeSeed'] = {
        type = 'CoffeeSeed',
        frame = nil,
        id = 2,
        name = 'Rotten Tooth',
        price = 10,
        stock = 0,
        purchasable = true,
    },
    ['Bread'] = {
        type = 'Bread',
        frame = nil,
        id = 3,
        name = 'Revolting Loaf',
        price = 5,
        stock = 0,
        purchasable = true,
    },
    ['Meat'] = {
        type = 'Meat',
        frame = nil,
        id = 4,
        name = 'Meat',
        price = 5,
        stock = 1,
        purchasable = true,
    },
    ['UpgradeLabel'] = {
        type = 'Label',
        frame = nil,
        id = 5,
        name = 'Upgradable Items List',
        price = 0,
        stock = 0,
        purchasable = false,
    },
    ['CoffeeMachine'] = {
        type = 'CoffeeMachine',
        frame = nil,
        id = 6,
        name = 'Coffee Machine',
        price = 50,
        stock = 0,
        purchasable = false,
        level = 1,
    },
    ['Stove'] = {
        type = 'Stove',
        frame = nil,
        id = 7,
        name = 'Stove',
        price = 50,
        stock = 0,
        purchasable = false,
        level = 1,
    },
    ['PlateManager'] = {
        type = 'PlateManager',
        frame = nil,
        id = 8,
        name = 'Plate',
        price = 50,
        stock = 0,
        purchasable = false,
        level = 1,
    },
}

local buffer = 5

function ShopMenu:init()
    self.type = 'ShopMenu'

    self.background = ShopBackground()
    gStateStack:push(self.background)

    self.scrollbar = Scrollbar(SCROLLBAR_CONFIG)
    gStateStack:push(self.scrollbar)

    self.indexY = 0
    self.items = {}
    self.buttons = {}
    self.interactables = { self.scrollbar }

    local i = 1
    for name, data in pairs(items) do
        data.stock = StockManager:getStockTotal()[name] or 0
        if data.level then data.level = StockManager:getLevel(name) end
        local item = ShopItem(data)
        table.insert(self.items, item)
        gStateStack:push(item)
        if item.type ~= 'Label' then
            self.scrollbar:addHeight(item:getHeight() + buffer)
            self.buttons[i] = item:getButton()
            gStateStack:push(self.buttons[i])
            table.insert(self.interactables, self.buttons[i])
        end
        i = i + 1
    end

    self.topBox = ShopTopBox()
    gStateStack:push(self.topBox)

    self.exitButton = Button(BUTTON_PARAMS['FromShop'])
    gStateStack:push(self.exitButton)
    table.insert(self.interactables, self.exitButton)
end

function ShopMenu:update(dt)
    self:mouseResponse()
    self.indexY = self.scrollbar:getY()

    local topLimit = 20

    for i = 1, #self.items do
        local item = self.items[i]
        item:updateY(self.indexY)
        if item.type ~= 'Label' then
            item:getButton():updateY(self.indexY, item.id, item:getHeight(), buffer)
        end

        if item:getBottom() < topLimit and item.isVisible then
            item.isVisible = false
        elseif item:getBottom() >= topLimit and not item.isVisible then
            item.isVisible = true
        end
    end
    gWheelY = 0
end

function ShopMenu:render()
end