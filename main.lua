vram = require 'src.core.virtualization.VRAM'
_version = love.filesystem.read(".version")
function love.load()
    --% third party libs --
    Version = require 'libraries.version'
    hex = require 'src.core.components.Hex'
    json = require 'libraries.json'
    lue = require 'libraries.lue'
    render = require 'src.core.Render'
    memory = require 'src.core.components.Memory'
    keyboard = require 'src.core.virtualization.Keyboard'
    storagedvr = require 'src.core.virtualization.Storage'
    moonshine = require 'libraries.moonshine'
    gamestate = require 'libraries.gamestate'
    touchpad = require 'src.core.virtualization.Touchpad'

    love.graphics.setDefaultFilter("nearest", "nearest")

    effect = moonshine(moonshine.effects.crt)
    .chain(moonshine.effects.glow)
    .chain(moonshine.effects.scanlines)

    effect.glow.strength = 5
    effect.glow.min_luma = 0.7
    effect.scanlines.width = 1
    effect.scanlines.opacity = 0.5

    storagedvr.init()

    --% addons loader --
    Addons = love.filesystem.getDirectoryItems("libraries/addons")
    for addon = 1, #Addons, 1 do
        require("libraries.addons." .. string.gsub(Addons[addon], ".lua", ""))
    end

    --% api --
    stellarAPI = require 'src.modules.Stellar'

    __updateShaders__()

    --% gamepad system --
    _gamepads = love.joystick.getJoysticks()

    --% cool vars --
    hasPackage = true
    errorCodes = {
        "0x001",
        "0x002",
    }

    DEVMODE = {
        screenBounds = false,
        mobileTouchPad = false,
        showTouchpadButtons = false,
        listObjects = false,
        showMemory = true,
        showFPS = true,
    }

    --% initialization folders --
    love.filesystem.createDirectory("bin")

    --% initialization stuff to the package --

    if love.filesystem.isFused() then
        dataFile = love.filesystem.getInfo(love.filesystem.getSourceBaseDirectory() .. "/data.pkg")
    else
        dataFile = love.filesystem.getInfo("Build/instance/data.pkg")
    end
    
    if dataFile == nil then
        hasPackage = false
    end

    if hasPackage then
        if love.filesystem.isFused() then
            sucess = love.filesystem.mount(love.filesystem.getSourceBaseDirectory() .. "/data.pkg", "baserom")
            print(love.filesystem.getSourceBaseDirectory())
            print(sucess)
        else
            sucess = love.filesystem.mount("Build/instance/data.pkg", "baserom")
            print(sucess)
        end
    else
        if love.filesystem.isFused() then
            sucess = love.filesystem.mount(love.filesystem.getSourceBaseDirectory() .. "/lumina.fmw", "baserom")
            print(love.filesystem.getSourceBaseDirectory())
            --print(sucess)
        else
            sucess = love.filesystem.mount("Build/instance/", "baserom")
            --print(sucess)
        end
    end
    
    --% load the default fontchr file --
    vram.buffer.font = json.decode(love.data.decompress("string", "zlib", love.filesystem.read("baserom/FONTCHR.chr")))

    --% load the rom logic --
    data = love.filesystem.load("baserom/boot.lua")

    --% initialize render stuff (create the first frame)
    render.init()
    touchpad.init()
    pcall(data(), _init())
end

function love.draw()
    render.drawCall()
    pcall(data(), _render())
    touchpad.render()
    if DEVMODE.listObjects then
        local y = 15
        love.graphics.print(love.timer.getFPS())
        for _, spr in ipairs(vram.buffer.bank) do
            love.graphics.print("$" .. spr.name, 3, y)
            y = y + 15
        end
    end
    if DEVMODE.showMemory then
        memory.render()
    end
    if DEVMODE.showFPS then
        love.graphics.print(love.timer.getFPS())
    end
end

function love.update(elapsed)
    __updateShaders__()
    touchpad.update(elapsed)
    memory.update()
    pcall(data(), _update(elapsed))
end

function love.keypressed(k)
    for _, value in pairs(keyboard.keys) do
        if value == k then
            pcall(data(), _keydown(k))
        end
    end
end

function love.gamepadpressed(joystick, button)
    pcall(data(), _gamepadpressed(button))
end

---------------------------------------------

function __updateShaders__()
    if stellarAPI.storage.isSaveExist("__system__") then
        local systemData = stellarAPI.storage.getSaveData("__system__")
        if not systemData[1][1].value then
            effect.disable("crt")
        else
            effect.enable("crt")
        end
        if not systemData[1][2].value then
            effect.disable("glow")
        else
            effect.enable("glow")
        end
        if not systemData[1][3].value then
            effect.disable("scanlines")
        else
            effect.enable("scanlines")
        end
    end
end