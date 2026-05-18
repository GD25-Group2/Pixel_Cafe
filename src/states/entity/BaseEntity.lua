BaseEntity = class {__includes = BaseState}

function BaseEntity:init(params)
    for k, v in pairs(params) do
        self[k] = v
    end
end

function BaseEntity:isMouseOver()
    return mouseX > self.x and mouseX < self.x + self.desired_width and
           mouseY > self.y and mouseY < self.y + self.desired_height
end

function BaseEntity:update(dt)
    if self.animation then
        self.animation:update(dt)
        local frame = self.animation:getCurrentFrame()
        if frame then
            self.frame = frame
        end
    end
end

function BaseEntity:render()
    if self.type == 'Cursor' then
        self.x = mouseX
        self.y = mouseY
    end

    if not self.frame then return end

    -- Using :typeOf() is completely bulletproof across all LÖVE versions
    if type(self.frame) == "userdata" and self.frame:typeOf("Quad") then
        local _, _, qw, qh = self.frame:getViewport()
        local texture = self.texture or (self.animation and self.animation.texture)
        
        if texture then
            love.graphics.draw(texture, self.frame, self.x, self.y, 0, 
                self.desired_width / qw, self.desired_height / qh)
        end
    elseif type(self.frame) == "userdata" and (self.frame:typeOf("Image") or self.frame:typeOf("Texture")) then
        -- FIXED: Standalone full images (like GrumpyOldMan) fall into this crisp scaler block
        love.graphics.draw(self.frame, self.x, self.y, 0, 
            self.desired_width / self.frame:getWidth(), self.desired_height / self.frame:getHeight())
    end
end