astroAPI.graphics = {}

--% depends sprite and text
local fontText = require 'src.core.components.Text'
local spr = require 'src.core.components.Sprite'
local rectangle = require 'src.core.components.Rectangle'

function astroAPI.graphics.setBackgroundColor(colorID)
    if colorID < 1 then
        colorID = 1
    end
    if colorID > 39 then
        colorID = 39
    end
    render.bgColor = colorID
end

function astroAPI.graphics.newSprite(index, x, y)
    spr.newSprite(index, x, y)
end

function astroAPI.graphics.newText(text, x, y, color, bgcolor)
    if type(color) == "number" then
        if color < 1 then
            color = 1
        elseif color > 39 then
            color = 39
        end
    end
    if type(bgcolor) == "number" then
        if bgcolor < 1 then
            bgcolor = 1
        elseif bgcolor > 39 then
            bgcolor = 39
        end
    end
    fontText.newText(text, x, y, color, bgcolor)
end

function astroAPI.graphics.getTextSize(text)
    assert(type(text) == "string", "[ERROR] :: Invalid type, expected 'string' got " .. type(text))
    return #text * 6
end

function astroAPI.graphics.newRectangle(color, x, y, w, h)
    if color < 1 then
        color = 1
    elseif color > 39 then
        color = 39
    end
    if w > 0 and h > 0 then
        rectangle.newRectangle(color, x, y, w, h)
    end
end

function astroAPI.graphics.loadSpriteBank(name)
    vram.buffer.bank = json.decode(love.data.decompress("string", "zlib", love.filesystem.read("baserom/" .. name .. ".spr")))
    --local file = love.filesystem.newFile("output.bin", "w")
end

function astroAPI.graphics.loadSpriteBankFromPath(name)
    vram.buffer.bank = json.decode(love.data.decompress("string", "zlib", love.filesystem.read(name .. ".spr")))
    --local file = love.filesystem.newFile("output.bin", "w")
end

function astroAPI.graphics.loadFontBank(name)
    vram.buffer.font = json.decode(love.data.decompress("string", "zlib", love.filesystem.read("baserom/" .. name .. ".chr")))
end

function astroAPI.graphics.loadFontBankFromPath(name)
    vram.buffer.font = json.decode(love.data.decompress("string", "zlib", love.filesystem.read(name .. ".chr")))
end

function astroAPI.graphics.getScreenDimentions()
    return render.resX, render.resY
end

return astroAPI.graphics