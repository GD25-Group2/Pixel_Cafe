Challenge = class {__includes = BaseState}

function Challenge:init()
    self.priority = 0
    self.type = 'Challenge'

    self.startShiftButton = Button(BUTTON_PARAMS['StartShift'])
end

function Challenge:update()
    self:mouseResponse()
end