function love.conf(t)
    -- Identity & Title
    t.identity = "pixel_cafe"               -- Save directory name (%appdata%/LOVE/pixel_cafe)
    t.title = "Pixel Cafe"                  -- The window title
    t.author = "GD25-Group2"                -- Developer / Author
    t.version = "11.5"                      -- The LÖVE version this game was created for

    -- Window / Display Settings
    t.window.title = "Pixel Cafe"           -- Title of the window
    t.window.icon = 'assets/mascot.ico'      -- Filepath to an image to use as the window icon (e.g. "assets/icon.png")
    t.window.width = 1280                   -- Window width in pixels
    t.window.height = 720                   -- Window height in pixels
    t.window.borderless = false             -- Remove window border and title bar
    t.window.resizable = false              -- Allow the user to resize the window
    t.window.minwidth = 320                 -- Minimum window width if resizable
    t.window.minheight = 180                -- Minimum window height if resizable
    t.window.fullscreen = true              -- Enable fullscreen mode
    t.window.fullscreentype = "desktop"     -- Fullscreen type ("desktop" or "exclusive")
    t.window.vsync = 1                      -- Vertical sync (1 to enable, 0 to disable)
    t.window.msaa = 0                       -- Multi-sample antialiasing (keep 0 for pixel art)
    t.window.highdpi = false                -- Enable high-DPI mode on Retina displays
    t.window.x = nil                        -- Initial X position on screen (nil = centered)
    t.window.y = nil                        -- Initial Y position on screen (nil = centered)

    -- Modules (Disable unused modules to improve performance/load times)
    t.modules.audio = true                  -- Enable audio module
    t.modules.data = true                   -- Enable data module (hashing/compressing)
    t.modules.event = true                  -- Enable event system
    t.modules.font = true                   -- Enable font module
    t.modules.graphics = true               -- Enable graphics module
    t.modules.image = true                  -- Enable image loader
    t.modules.joystick = false              -- Disable if you aren't using gamepads
    t.modules.keyboard = true               -- Enable keyboard input
    t.modules.math = true                   -- Enable math module (randomness/noise)
    t.modules.mouse = true                  -- Enable mouse input
    t.modules.physics = false               -- Disable Box2D physics if you use custom collision
    t.modules.sound = true                  -- Enable sound decoder
    t.modules.system = true                 -- Enable system info (OS, clipboard, etc.)
    t.modules.thread = true                 -- Enable threading
    t.modules.timer = true                  -- Enable delta time / frame timing
    t.modules.touch = false                 -- Disable touch input unless targeting mobile
    t.modules.video = false                 -- Disable video playback module
    t.modules.window = true                 -- Enable window management
end