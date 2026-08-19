love.graphics.setDefaultFilter('nearest', 'nearest')

require('src.Dependencies')

function love.load()
    profiler.start()
    math.randomseed(os.time())
    love.window.setTitle('Pixel Cafe')
    --love.window.setIcon(gLogo)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true,
        filter = 'nearest',
    })

    gStateStack = StateStack()
    gStateStack:push(StartMenu())

    --gStateStack = StateStack()
    --gStateStack:push(PlayState())
    love.keyboard.keysPressed = {}
    love.mouse.keysPressed = {}
    love.mouse.keysReleased = {}
end

function love.update(dt)
    local mx, my = push:toGame(love.mouse.getX(), love.mouse.getY())
    _G.mouseX = mx or -1000
    _G.mouseY = my or -1000

    suit.updateMouse(mouseX, mouseY, love.mouse.isDown(1))

    if love.keyboard.wasPressed('k') and not gStateStack.isPopup then
        gStateStack:popupCreate()
        gStateStack:push(PopupWindow('Dev'))
    end
    if love.keyboard.wasPressed('f11') then
        local fullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not fullscreen)
    end

    timer.update(dt)
    gStateStack:update(dt)
    love.keyboard.keysPressed = {}
    love.mouse.keysPressed = {}
    love.mouse.keysReleased = {}
end

function love.draw()
    push:start()
    gStateStack:render()
    love.graphics.setColor(gColors['curtain2'])
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    love.graphics.setColor(gColors['white'])
    push:finish()
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true

    if key:match("^f%d+$") or key == "lalt" or key == "ralt" then
        return
    end

    if key == 'k' and not gStateStack.isPopup then
        InputBox.ignoreNextK = true
    end
    InputBox.keypressed(key)
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.textedited(text, start, length)
    InputBox.textedited(text, start, length)
end

function love.mousepressed(x, y, button)
    love.mouse.keysPressed[button] = true
end

function love.mousereleased(x, y, button)
    love.mouse.keysReleased[button] = true
end

function love.mouse.wasPressed(button)
    return love.mouse.keysPressed[button]
end

function love.mouse.wasReleased(button)
    return love.mouse.keysReleased[button]
end

function love.textinput(t) 
    if InputBox.ignoreNextK and t == 'k' then
        InputBox.ignoreNextK = false
        return
    end
    InputBox.textinput(t) 
end

function love.wheelmoved(x, y)
    gWheelY = y
end