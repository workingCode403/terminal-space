local obstacle = require("obstacle")
local background = require("background")
local attack = require("attack")
local player = require("player")

function love.load()
    math.randomseed(os.time())
    love.window.setMode(0, 0, {resizable = true})
    love.window.maximize()
    love.window.setTitle("Terminal Space")
    love.keyboard.setKeyRepeat(true)

    background.init()
    player.load()
end

function love.update(dt)
    if not player.dead then
        player.move(dt)
    end

    if player.mode == 0 then
        background.update()
    elseif player.mode == 1 then
        attack.update(dt)
    end

    obstacle.calcPlayer(dt)
end

function love.mousepressed(x, y, button)
    if button ~= 1 then
        return
    end

    if (player.mode == 2 or player.mode == 4) and not background.restart then
        local font = love.graphics.newFont("CourierPrime.ttf")

        if x > (love.graphics.getWidth() - font:getWidth("> Restart") * 2) / 2
        and x < (love.graphics.getWidth() + font:getWidth("> Restart") * 2) / 2
        and y > love.graphics.getHeight() / 2 + 10
        and y < love.graphics.getHeight() / 2 + 10 + font:getHeight() * 2 then
            Reset()
        elseif x > (love.graphics.getWidth() - font:getWidth("> Restart") * 2) / 2
        and x < (love.graphics.getWidth() + font:getWidth("> Quit") * 2) / 2
        and y > love.graphics.getHeight() / 2 + 10 + font:getHeight() * 3
        and y < love.graphics.getHeight() / 2 + 10 + font:getHeight() * 5 then
            Reset()
            background.exit = true
        end
    elseif player.mode == 0 then
        local font = love.graphics.newFont("CourierPrime.ttf")
        local collide = false

        for i, v in ipairs(background.printList) do
            local j = v:find("https://")

            if j then
                if x > 5 + font:getWidth(v:sub(1, j - 1)) * 1.5
                and x < 5 + font:getWidth(v) * 1.5
                and y > love.graphics.getHeight()
                    - font:getHeight() * 1.5 * (#background.printList - i + 2)
                    - font:getHeight() - 5
                and y < love.graphics.getHeight()
                    - font:getHeight() * 1.5 * (#background.printList - i + 2)
                    + font:getHeight() / 2 - 5 then
                    collide = true
                end
            end
        end

        if collide then
            love.system.openURL("https://github.com/workingCode403/terminal-space/blob/main/tutorial.md")
        end
    end
end

function love.mousemoved(x, y)
    if player.mode == 2 or player.mode == 4 then
        local font = love.graphics.newFont("CourierPrime.ttf")

        if x > (love.graphics.getWidth() - font:getWidth("> Restart") * 2) / 2
        and x < (love.graphics.getWidth() + font:getWidth("> Restart") * 2) / 2
        and y > love.graphics.getHeight() / 2 + 10
        and y < love.graphics.getHeight() / 2 + 10 + font:getHeight() * 2 then
            background.dieSelect = 1
            if love.mouse.isCursorSupported() then
                love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
            end
        elseif x > (love.graphics.getWidth() - font:getWidth("> Restart") * 2) / 2
        and x < (love.graphics.getWidth() + font:getWidth("> Quit") * 2) / 2
        and y > love.graphics.getHeight() / 2 + 10 + font:getHeight() * 3
        and y < love.graphics.getHeight() / 2 + 10 + font:getHeight() * 5 then
            background.dieSelect = -1
            if love.mouse.isCursorSupported() then
                love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
            end
        else
            if love.mouse.isCursorSupported() then
                love.mouse.setCursor()
            end
        end
    elseif player.mode == 0 then
        local font = love.graphics.newFont("CourierPrime.ttf")
        local collide = false

        for i, v in ipairs(background.printList) do
            local j = v:find("https://")

            if j then
                if x > 5 + font:getWidth(v:sub(1, j - 1)) * 1.5
                and x < 5 + font:getWidth(v) * 1.5
                and y > love.graphics.getHeight()
                    - font:getHeight() * 1.5 * (#background.printList - i + 2)
                    - font:getHeight() - 5
                and y < love.graphics.getHeight()
                    - font:getHeight() * 1.5 * (#background.printList - i + 2)
                    + font:getHeight() / 2 - 5 then
                    collide = true
                end
            end
        end

        if collide then
            if love.mouse.isCursorSupported() then
                love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
            end
        else
            if love.mouse.isCursorSupported() then
                love.mouse.setCursor()
            end
        end
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit(0)
    elseif key == "space" and background.autoStart and player.mode == 0 then
            background.autoStart = false
            background.startTimer = 156
            background.addPrint("Reboot aborted!")
            background.addPrint("---------------")
            player.visible = false
            background.input = true
    elseif key == "backspace" and player.mode == 0 and background.input then
        background.printText = background.printText:sub(1,
                #background.printText - 1
        )
        background.cmdCurrent = background.printText
        background.cmdQueueNum = 0
    elseif key == "return" and player.mode == 0 and background.input then
        background.addPrint(background.printText)
        background.processCommand(background.printText)
        background.printText = ""
        background.cmdCurrent = ""
        background.cmdQueueNum = 0
    elseif (key == "up" or key == "down") and (player.mode == 2 or player.mode == 4) then
        if key == "up" then
            background.dieSelect = 1
        else
            background.dieSelect = -1
        end
    elseif key == "return" and (player.mode == 2 or player.mode == 4) and not background.restart then
        if background.dieSelect == -1 then
            Reset()
            background.exit = true
        else
            Reset()
        end
    elseif key == "v" and love.keyboard.isDown("lctrl", "rctrl") then
        background.printText = background.printText .. love.system.getClipboardText()
    elseif key == "c" and love.keyboard.isDown("lctrl", "rctrl") then
        love.system.setClipboardText(background.printText)
    elseif (key == "up" or key == "down") and player.mode == 0 and background.input then
        if key == "up" then
            if background.cmdQueueNum < #background.cmdQueue then
                background.cmdQueueNum = background.cmdQueueNum + 1
            end
        else
            background.cmdQueueNum = background.cmdQueueNum - 1
        end

        if background.cmdQueueNum <= 0 then
            background.cmdQueueNum = 0
            background.printText = background.cmdCurrent
        else
            background.printText = background.cmdQueue[#background.cmdQueue + 1 - background.cmdQueueNum]
        end
    end
end

function Reset()
    if background.dead then
        player.mode = 3
    else
        player.mode = 5
    end

    background.printList = {}
    background.input = false
    background.startTimer = 0
    background.dieTimer = background.maxDT
    background.dieTimer2 = background.maxDT2
    background.d2Timer = 0
    background.dead = false
    background.printText = ""
    background.timer = 0
    background.cmdQueueNum = 0

    player.visible = false
    player.x, player.y = 500, 500
    player.vertMod = 1
    player.horDir = 0

    obstacle.obstacles = {}
    attack.timer = 2
end

function love.textinput(text)
    if player.mode == 0 and background.input then
        background.printText = background.printText .. text
        background.cmdCurrent = background.printText
        background.cmdQueueNum = 0
    end
end

function love.draw()
    love.graphics.setColor(0.04, 0.04, 0.04, 1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setBackgroundColor(0,0,0,0)

    if player.mode == 0 then
        local font = love.graphics.newFont("CourierPrime.ttf")
        love.graphics.setColor(0.012, 0.882, 0.271, 0.6)
        love.graphics.print("Enable fullscreen", font, 5, 5, 0, 1.2, 1.2)
    end

    background.draw()
    obstacle.draw()
    player.draw()
    if player.mode == 3 then
        background.close()
    elseif player.mode == 4 then
        background.win(background.d2Timer)
    elseif player.mode == 5 then
        background.winClose()
    elseif player.dead then
        background.die()
    end
end