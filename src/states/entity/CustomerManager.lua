-- CustomerManager.lua
-- Handles customer spawning (with timer), slot assignment, and cleanup.
-- Lives inside PlayState; update() is called each frame by PlayState:update().

CustomerManager = class{__includes = BaseState}

function CustomerManager:init()
    self.customers     = {}   -- list of active CustomerState objects
    self.queue = {}
    self.occupiedSlots = {}   -- [slotIndex] = true/false

    self.spawnTimer    = 0
    self.nextSpawnTime = 1--CUSTOMER_CONFIG.spawnInterval

    -- Mark all slots free
    for i = 1, #WAITING_SLOTS do
        self.occupiedSlots[i] = false
    end

    self.spawningEnabled = true
    self.walkSongIndex = 1
end

function CustomerManager:update(dt)
    if self.spawningEnabled then
        self.spawnTimer = self.spawnTimer + dt
        if self.spawnTimer >= self.nextSpawnTime then
            self:spawnCustomer()
            self.spawnTimer    = 0
            -- Add ±0.5 s of jitter so arrivals feel natural
            self.nextSpawnTime = self:calculateNextSpawnTime()
        end
    end

    local slot = self:getAvailableSlot()
    if slot and #self.queue > 0 then
        local customer = table.remove(self.queue, 1)
        customer:setSlot(slot)
        self.occupiedSlots[slot.index] = true
        table.insert(self.customers, customer)
        customer:setState('moving_in')
    end

    -- Remove customers that have fully exited (state == 'done')
    for i = #self.customers, 1, -1 do
        local c = self.customers[i]
        c:update(dt)
        if c.state == 'done' then
            if c.slotIndex then
                self.occupiedSlots[c.slotIndex] = false
            end
            table.remove(self.customers, i)
        end
    end

    for _, c in ipairs(self.customers) do
        c:update(dt)
    end

    -- Play walking song while any customer is walking in or out
    local isAnyoneWalking = false
    for _, c in ipairs(self.customers) do
        if c.state == 'moving_in' or c.state == 'leaving' then
            isAnyoneWalking = true
            break
        end
    end

    if isAnyoneWalking then
        if gSounds then
            local currentSound = self.currentWalkSong and gSounds[self.currentWalkSong]
            if currentSound and currentSound:isPlaying() then
                -- Already playing/resuming the current walking song
            else
                -- Choose next song alternately if none is tracked
                if not currentSound then
                    self.walkSongIndex = self.walkSongIndex == 1 and 2 or 1
                    self.currentWalkSong = 'walking-song' .. self.walkSongIndex
                    currentSound = gSounds[self.currentWalkSong]
                end

                if currentSound then
                    currentSound:setVolume(gSettings.sfxVolume)
                    currentSound:setLooping(true)
                    currentSound:play()
                end
            end
        end
    else
        -- Stop all walking songs if no one is walking
        if gSounds then
            if gSounds['walking-song1']:isPlaying() then
                gSounds['walking-song1']:stop()
            end
            if gSounds['walking-song2']:isPlaying() then
                gSounds['walking-song2']:stop()
            end
        end
        self.currentWalkSong = nil
    end
end

function CustomerManager:spawnCustomer()
    --[[local slot = self:getAvailableSlot()
    if not slot then return end   -- all slots full]]

    local customer = CustomerState({
        --slotIndex = slot.index,
        --slot      = slot,
        --orderType = 'Coffee',
    })

    --self.occupiedSlots[slot.index] = true
    table.insert(self.queue, customer)
    Signal:emit('queue-count', self:getQueueCount())
    Signal:emit('queue-customers', self.queue)
    --return customer
end

function CustomerManager:calculateNextSpawnTime()
    local reputation = DataManager:getData('reputation') or 50
    local repPercent = reputation / 100

    local slowestSpawn = 8.0
    local fastestSpawn = 2.0

    local baseSpawnInterval = slowestSpawn - (slowestSpawn - fastestSpawn) * repPercent

    local jitter = (math.random() - 0.5)

    return math.max(0.75, baseSpawnInterval + jitter)
end

function CustomerManager:getAvailableSlot()
    for i, s in ipairs(WAITING_SLOTS) do
        if not self.occupiedSlots[i] then
            return {index = i, x = s.x, y = s.y, id = s.id}
        end
    end
    return false
end

function CustomerManager:getAllCustomers() return self.customers end

function CustomerManager:getCustomerCount() return #self.customers end

function CustomerManager:getQueueCount() return #self.queue end

function CustomerManager:getOccupiedSlotCount()
    local n = 0
    for i = 1, #WAITING_SLOTS do
        if self.occupiedSlots[i] then n = n + 1 end
    end
    return n
end

function CustomerManager:forceExitAll()
    self.queue = {}
    for _, c in ipairs(self.customers) do
        c:leave()
    end
end

function CustomerManager:isEmpty() return #self.customers == 0 end

function CustomerManager:stopSpawning() self.spawningEnabled = false end

function CustomerManager:render()
    for _, c in ipairs(self.customers) do
        c:render()
    end
end
