local obstacle = require("obstacle")
local background = require("background")
local attack = require("attack")
local player = require("player")

function love.load()
    math.randomseed(os.time())
    love.window.setMode(0, 0, {resizable = true})
    love.window.maximize()
    love.window.setTitle("Terminal Space")

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
    elseif key == "return" and player.mode == 0 and background.input then
        background.addPrint(background.printText)
        background.processCommand(background.printText)
        background.printText = ""
    elseif (key == "up" or key == "down") and (player.mode == 2 or player.mode == 4) then
        background.dieSelect = background.dieSelect * -1
    elseif key == "return" and (player.mode == 2 or player.mode == 4) and not background.restart then
        if background.dieSelect == -1 then
            Reset()
            background.exit = true
        else
            Reset()
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
    end
end

function love.draw()
    love.graphics.setColor(0.04, 0.04, 0.04, 1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setBackgroundColor(0,0,0,0)

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