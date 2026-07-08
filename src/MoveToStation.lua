local MoveToStation = {}

function MoveToStation.init(source, target, process)
    local src = source
    local tgt = target
    local proc = process

    local scatter_x = src.x + math.random(-30, 30)
    local scatter_y = src.y + math.random(-20, 20)

    local finalRestProcess = function()
        print('MoveToStation-resting still at target plate')
        timer.after(proc.final_delay, function()
            if src.type == 'Coin' then
                print('MoveToStation-signal coin remove')
                Signal:emit('coin-remove-' .. tostring(src.id))
            elseif src.type == 'DropItem' then
                print('MoveToStation-signal drop item remove: ' .. tostring(src.order))
                Signal:emit('DropItem-remove-' .. tostring(src.order))
            end
        end)
    end

    local realProcess = function ()
        print('MoveToStation-flying and shrinking to target')
        
        local small_w = math.floor(src.desired_width * 0.5)
        local small_h = math.floor(src.desired_height * 0.5)

        timer.tween(proc.duration, src, { 
            x = tgt.x, 
            y = tgt.y,
            desired_width = small_w,
            desired_height = small_h
        }, proc.mode, finalRestProcess)
    end

    local float_cycles = 0
    local max_float_cycles = 2
    local bobUp, bobDown

    bobUp = function()
        if float_cycles >= max_float_cycles then
            realProcess()
            return
        end
        timer.tween(proc.bob_duration, src, { y = scatter_y - 5 }, 'in-out-sine', bobDown)
    end

    bobDown = function()
        timer.tween(proc.bob_duration, src, { y = scatter_y + 5 }, 'in-out-sine', function()
            float_cycles = float_cycles + 1
            bobUp()
        end)
    end

    print('MoveToStation-burst scatter near spawn')
    timer.tween(proc.birth_duration, src, { x = scatter_x, y = scatter_y }, 'out-cubic', function()
        print('MoveToStation-starting sine wave float')
        bobUp()
    end)
end

return MoveToStation