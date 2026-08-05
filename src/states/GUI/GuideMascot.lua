GuideMascot = class {__includes = BaseEntity}

function GuideMascot:init(params)
    BaseEntity.init(self, params)
    self.type = 'Moscot'
    self.priority = 99

    self.desired_width = self.desired_width or 64
    self.desired_height = self.desired_height or 64
    self.frame = gFrames['Guide']

    print('GuideMascot - initiated')
    
    self.destruct = function ()
        Signal:remove('destroy-GuideMascot', self.destruct)
        gStateStack:pop(self)
    end
    Signal:register('destroy-GuideMascot', self.destruct)
end

function GuideMascot:update(dt)
    
end

function GuideMascot:render()
    BaseEntity.render(self)
end