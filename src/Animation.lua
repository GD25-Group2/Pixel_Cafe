Animation = class{}

function Animation:init(def)
    self.def = def or {}
    self.frames = self.def.frames or {}
    self.speed = self.def.speed or 0.1
    self.loop = self.def.loop ~= false
    self.activate = self.def.activate
    self.defaultFrame = self.def.defaultFrame or self.frames[1]
    self.holdFrameWhenInactive = self.def.holdFrameWhenInactive or false
    self.active = false
    self.finished = false
    self.timer = 0
    self.frameIndex = 1
    self.frame = self.defaultFrame
end

function Animation:update(dt, owner)
    if self.activate then
        local shouldBeActive = self.activate(owner)
        if shouldBeActive and not self.active then
            self.active = true
            self.finished = false
            self.frameIndex = 1
            self.timer = 0
        elseif not shouldBeActive and self.active then
            self.active = false
            self.frameIndex = 1
            self.timer = 0
        end
    end

    if not self.active then
        if not self.holdFrameWhenInactive then
            self.frame = self.defaultFrame
        end
        return
    end

    if self.speed <= 0 or #self.frames == 0 then
        self.frame = self.frames[self.frameIndex] or self.defaultFrame
        return
    end

    self.timer = self.timer + dt
    while self.timer >= self.speed do
        self.timer = self.timer - self.speed
        self.frameIndex = self.frameIndex + 1

        if self.frameIndex > #self.frames then
            if self.loop then
                self.frameIndex = 1
            else
                self.frameIndex = #self.frames
                self.active = false
                self.finished = true
                break
            end
        end
    end

    self.frame = self.frames[self.frameIndex] or self.defaultFrame
end

function Animation:getFrame()
    return self.frame
end

function Animation:play()
    self.active = true
    self.finished = false
    self.frameIndex = 1
    self.timer = 0
    self.frame = self.frames[self.frameIndex] or self.defaultFrame
end

function Animation:stop()
    self.active = false
    self.frameIndex = 1
    self.timer = 0
    self.frame = self.defaultFrame
end
