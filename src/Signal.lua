local Signal = {
    listeners = {}
}
setmetatable(Signal, Signal)

function Signal:register(eventName, callback)
    self.listeners[eventName] = self.listeners[eventName] or {}
    table.insert(self.listeners[eventName], callback)
end

function Signal:emit(eventName, ...)
    if self.listeners[eventName] then
        for _, callback in ipairs(self.listeners[eventName]) do
            callback(...)
        end
    end
end

function Signal:request(eventName, ...)
    if self.listeners[eventName] then
        for _, callback in ipairs(self.listeners[eventName]) do
            local result = callback(...)
            if result ~= nil then
                return result
            end
        end
    end
    return nil
end

function Signal:remove(eventName, callback)
    if self.listeners[eventName] then
        for i, cb in ipairs(self.listeners[eventName]) do
            if cb == callback then
                table.remove(self.listeners[eventName], i)
                break
            end
        end
    end
end

return Signal