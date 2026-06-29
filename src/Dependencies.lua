_G.love = require('love')

_G.class = require('src.libs.class')
_G.push  = require('src.libs.push')
require('src.libs.StateMachine')
require('src.libs.StateStack')
_G.suit  = require('src.libs.SUIT')
_G.json = require('src.libs.dkjson')
require('src.libs.Util')
require('src.libs.Animation')

gFonts = {
    ['large']  = love.graphics.newFont('assets/font.ttf', 32),
    ['medium'] = love.graphics.newFont('assets/font.ttf', 16),
    ['small']  = love.graphics.newFont('assets/font.ttf', 8),
}

gFrames = {
    ['StartMenuBackground'] = love.graphics.newImage('assets/pixelCafeCityBackground.png'),
    ['CoffeeMachine'] = love.graphics.newImage('assets/coffeeMachine.png'),
    customers = {
        ['Headless'] = {
            ['walk'] = {love.graphics.newImage('assets/CustomerHeadless/customerHeadless1.png'),
            love.graphics.newImage('assets/CustomerHeadless/customerHeadless2.png'),},
            ['idle'] = {love.graphics.newImage('assets/CustomerHeadless/customerHeadless3.png'),
            love.graphics.newImage('assets/CustomerHeadless/customerHeadless4.png'),},
        },
        ['LegLady'] = {
            ['walk'] = {love.graphics.newImage('assets/CustomerLegLady/LegLady1.png'), -- Leg Lady
            love.graphics.newImage('assets/CustomerLegLady/LegLady2.png'),},
            ['idle'] = {love.graphics.newImage('assets/CustomerLegLady/LegLady3.png'),
            love.graphics.newImage('assets/CustomerLegLady/LegLady4.png'),},
        },
        ['ArmEater'] = {
            ['walk'] = {love.graphics.newImage('assets/CustomerArmEater/customerArmEater1.png'), -- Arm Eater
            love.graphics.newImage('assets/CustomerArmEater/customerArmEater2.png'),},
            ['idle'] = {love.graphics.newImage('assets/CustomerArmEater/customerArmEater3.png'),
            love.graphics.newImage('assets/CustomerArmEater/customerArmEater4.png'),},
        },
    },
    ['Coffee'] = love.graphics.newImage('assets/JarVolumeStages/CoffeeJarVolume4by4.png'),
    ['EmptyTray'] = love.graphics.newImage('assets/Cups and stack/EmptyTray.png'),
    ['CoffeeCupStack'] = love.graphics.newImage('assets/Cups and stack/coffeecupstack.png'),
    ['DisposableCoffeeCup'] = love.graphics.newImage('assets/Cups and stack/DisposableCoffeeCup.png'),
    ['DisposableCoffeeCupFilled'] = love.graphics.newImage('assets/Cups and stack/DisposableCoffeeCupFilled.png'),
    ['TrayWithEmptyCups1'] = love.graphics.newImage('assets/Cups and stack/TrayWithEmptyCups1.png'),
    ['TrayWithEmptyCups2'] = love.graphics.newImage('assets/Cups and stack/TrayWithEmptyCups2.png'),
    ['TrayWithEmptyCups3'] = love.graphics.newImage('assets/Cups and stack/TrayWithEmptyCups3.png'),
    ['TrayWithEmptyCups4'] = love.graphics.newImage('assets/Cups and stack/TrayWithEmptyCups4.png'),
    ['TrayWithCupsFilled1'] = love.graphics.newImage('assets/Cups and stack/TrayWithCupsFilled1.png'),
    ['TrayWithCupsFilled2'] = love.graphics.newImage('assets/Cups and stack/TrayWithCupsFilled2.png'),
    ['TrayWithCupsFilled3'] = love.graphics.newImage('assets/Cups and stack/TrayWithCupsFilled3.png'),
    ['TrayWithCupsFilled4'] = love.graphics.newImage('assets/Cups and stack/TrayWithCupsFilled4.png'),
    -- Mixed fill stages: [N]CupsFillStage[filled]by[total]
    ['FourCupFillStage1by4'] = love.graphics.newImage('assets/Cups and stack/CupFillStage4/FourCupFillStage1by4.png'),
    ['FourCupFillStage2by4'] = love.graphics.newImage('assets/Cups and stack/CupFillStage4/FourCupFillStage2by4.png'),
    ['FourCupFillStage3by4'] = love.graphics.newImage('assets/Cups and stack/CupFillStage4/FourCupFillStage3by4.png'),
    ['ThreeCupsFillStage1by3'] = love.graphics.newImage('assets/Cups and stack/CupFillStage3/ThreeCupsFillStage1by3.png'),
    ['ThreeCupsFillStage2by3'] = love.graphics.newImage('assets/Cups and stack/CupFillStage3/ThreeCupsFillStage2by3.png'),
    ['TwoCupsFillStage1by2'] = love.graphics.newImage('assets/Cups and stack/CupFillStage2/2CupsFillStage1by2.png'),
    ['CounterBackground'] = love.graphics.newImage('assets/pixelCafeCounterBackground3.png'),
    ['CityBackground'] = love.graphics.newImage('assets/pixelCafeCityBackgroundLowerPerspective.png'),
    ['ShopIcon'] = love.graphics.newImage('assets/ShopIcon.png'),
    ['QueueExpandIcon'] = love.graphics.newImage('assets/expandToLeft.png'),
    ['QueueContractIcon'] = love.graphics.newImage('assets/expandToRight.png'),
    ['choppedPlatet'] = love.graphics.newImage('assets/choppedPlatet.png'),
    ['ChoppingBoard'] = love.graphics.newImage('assets/choppingBoard&Knife.png'),
    ['Stove'] = love.graphics.newImage('assets/stove.png'),
    ['ChoppedMeat'] = love.graphics.newImage('assets/choppedMeatFromBoard.png'),
    ['ChoppedLettuce'] = love.graphics.newImage('assets/choppedLettuceFromBoard.png'),
    ['ChoppedBread'] = love.graphics.newImage('assets/choppedBreadFromBoard.png'),
    ['Meat'] = love.graphics.newImage('assets/meatCarry.png'),
    ['Lettuce'] = love.graphics.newImage('assets/lettuceCarry.png'),
    ['FreeSandwich'] = love.graphics.newImage('assets/breadCarry.png'),
    ['MeatSandwich'] = love.graphics.newImage('assets/meatSandwich.png'),
    ['VegeSandwich'] = love.graphics.newImage('assets/vegeSandwich.png'),
    ['DeluxeSandwich'] = love.graphics.newImage('assets/deluxeSandwich.png'),
    ['LettuceBig'] = love.graphics.newImage('assets/lettuce.png'),
    ['LoafOfBread'] = love.graphics.newImage('assets/breadLoaf.png'),
    ['CoffeeCup'] = love.graphics.newImage('assets/Cups and stack/DisposableCoffeeCupFilled11.png'),
    ['DayEndBackground'] = love.graphics.newImage('assets/pixelCafeCityBackgroundShopFocus.png'),
    ['SaveSlotBackground'] = love.graphics.newImage('assets/pixelCafeCityBackgroundSkyFocus.png'),
}

-- Coffee Machine Animation Frames
gFrames['CoffeeMachineAnimation'] = {}
for i = 1, 11 do
    gFrames['CoffeeMachineAnimation'][i] = love.graphics.newImage('assets/CoffeeMachineAnimation/CoffeeMachine' .. i .. '.png')
end
gFrames['CoffeeMachineHold'] = love.graphics.newImage('assets/CoffeeMachineAnimation/CoffeeMachineHold.png')

--[[ Example layout for a horizontal strip sheet asset
local scavengerAtlas = love.graphics.newImage('assets/CustomerScavenger/scavenger_strip.png')
local scavengerQuads = GenerateQuads(scavengerAtlas, 64, 64) -- Width/Height per frame

gFrames.customers['Scavenger'] = {
    texture = scavengerAtlas, -- Saved for the BaseEntity render lookup
    ['walk'] = { scavengerQuads[1], scavengerQuads[2] },
    ['idle'] = { scavengerQuads[3], scavengerQuads[4] }
}]]

-- CoffeeMachine fill stage frames: 4=full jar (4/4), 1=almost empty (1/4)
gFrames['CoffeeMachinesFillStages4'] = love.graphics.newImage('assets/Fill stages/CoffeeMachinesFillStages4.png')
gFrames['CoffeeMachinesFillStages3'] = love.graphics.newImage('assets/Fill stages/CoffeeMachinesFillStages3.png')
gFrames['CoffeeMachinesFillStages2'] = love.graphics.newImage('assets/Fill stages/CoffeeMachinesFillStages2.png')
gFrames['CoffeeMachinesFillStages1'] = love.graphics.newImage('assets/Fill stages/CoffeeMachinesFillStages1.png')

-- Jar volume stages for dragging
gFrames['CoffeeJarVolume0by4'] = love.graphics.newImage('assets/JarVolumeStages/CoffeeJarVolume0by4.png')
gFrames['CoffeeJarVolume1by4'] = love.graphics.newImage('assets/JarVolumeStages/CoffeeJarVolume1by4.png')
gFrames['CoffeeJarVolume2by4'] = love.graphics.newImage('assets/JarVolumeStages/CoffeeJarVolume2by4.png')
gFrames['CoffeeJarVolume3by4'] = love.graphics.newImage('assets/JarVolumeStages/CoffeeJarVolume3y4.png')
gFrames['CoffeeJarVolume4by4'] = love.graphics.newImage('assets/JarVolumeStages/CoffeeJarVolume4by4.png')

gFrames['choppedPlatetQuads'] = GenerateQuads(gFrames['choppedPlatet'], 32, 32)
gFrames['ChoppingBoardQuads'] = GenerateQuads(gFrames['ChoppingBoard'], 32, 32)
gFrames['StoveQuads'] = GenerateQuads(gFrames['Stove'], 64, 64)

--require('src.Animation')
DataManager = require('src.DataManager')
StockManager = require('src.StockManager')
Signal = require('src.Signal')
require('src.constants')
InputBox = require('src.InputBox')

-- Audio loading
gMusic = love.audio.newSource('assets/music&SFX/Cafe Love - WOW Sound  The Boba Teashop Main Theme.mp3', 'stream')
gMusic:setLooping(true)
-- SFX 
gSounds = {
    ['click'] = love.audio.newSource('assets/music&SFX/bottom sfx.mp3', 'static'),
    ['cup-drag'] = love.audio.newSource('assets/music&SFX/cup-drag-2.mp3', 'static'),
    ['cup-fill'] = love.audio.newSource('assets/music&SFX/coffee-fill.mp3', 'static'),
    ['coffee-machine'] = love.audio.newSource('assets/music&SFX/coffee-machine.mp3', 'static'),
    ['coin-receive'] = love.audio.newSource('assets/music&SFX/coin-receive.mp3', 'static'),
    ['time-ticking'] = love.audio.newSource('assets/music&SFX/time-ticking.mp3', 'static'),
    ['walking-song1'] = love.audio.newSource('assets/music&SFX/walking-song1.mp3', 'static'),
    ['walking-song2'] = love.audio.newSource('assets/music&SFX/walking-song2.mp3', 'static'),
}

require('src.states.BaseState')
require('src.states.game.PlayState')
require('src.states.game.StartMenu')
require('src.states.game.DayEndState')
require('src.states.game.PauseMenu')
require('src.states.game.PopupWindow')
require('src.states.game.SettingsState')
--require('src.states.game.ShopMenu')
require('src.states.game.GameStartShopState')
require('src.states.game.ClosingState')
require('src.states.game.GameOver')
require('src.states.game.SaveSlotState')

require('src.states.entity.BaseEntity')
require('src.states.entity.CoffeeMachine')
require('src.states.entity.CustomerState')
require('src.states.entity.CustomerManager')
require('src.states.entity.OrderBox')
require('src.states.entity.FloatingMoney')
require('src.states.entity.MoneyManager')
require('src.states.entity.Cursor')
require('src.states.entity.TimeManager')
require('src.states.entity.Button')
require('src.states.entity.BreadBasket')
require('src.states.entity.BreadPlate')
require('src.states.entity.SandwichPlate')
require('src.states.entity.CoffeeCupStack')
require('src.states.entity.CoffeeTray')
require('src.states.entity.ScrollBar')
require('src.states.entity.ShopItem')
require('src.states.entity.ReputationBar')
--require('src.states.entity.QueueShowcase')
require('src.states.entity.Stove')
require('src.states.entity.ChoppingBoard')
require('src.states.entity.Lettuce')
require('src.states.entity.Plate')
require('src.states.entity.PlateManager')

require('src.states.GUI.DayEndStateCard')
require('src.states.GUI.PauseMenuCard')
require('src.states.GUI.StartMenuBackground')
require('src.states.GUI.PopupWindowCard')
require('src.states.GUI.CounterBackground')
require('src.states.GUI.CityBackground')
--require('src.states.GUI.ShopBackground')
--require('src.states.GUI.ShopTopBox')
require('src.states.GUI.GameStartShopStateCard')
require('src.states.GUI.Bubble')
require('src.states.GUI.SaveSlotBackground')