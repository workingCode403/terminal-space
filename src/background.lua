local moonshine = require("moonshine")
local player = require("player")

local background = {}

background.printList = {}
background.printText = ""
background.startTimer = 0
background.input = false
background.dieSelect = 1
background.autoStart = false

background.timer = 0
background.goalTime = 0

background.maxDT = 30
background.maxDT2 = 90
background.dieTimer = background.maxDT
background.dieTimer2 = background.maxDT2
background.d2Timer = 0
background.dead = false
background.closeTimer = -30
background.exit = false

function background.init()
    background.scanlineEffect = moonshine(moonshine.effects.scanlines)
    background.attack = require("attack")
    background.song = love.audio.newSource("placeholder.mp3", "stream")
    background.song:setLooping(true)
end

function background.addPrint(text)
    background.printList[#background.printList + 1] = text
end

function background.processCommand(text)
    if text == "start-game" then
        background.startTimer = 0
        player.visible = true
    elseif text:sub(1, 16) == "spawn-attack -t " then
        if text:sub(17) == "double" then
            background.attack.double()
        elseif text:sub(17) == "single" then
            background.attack.single()
        elseif text:sub(17) == "bounce" then
            background.attack.bounce()
        elseif text:sub(17) == "laser" then
            background.attack.laser()
        elseif text:sub(17, 24) == "mine -a " and string.len(text) > 24 then
            if tonumber(text:sub(25)) then
                for i = 1, tonumber(text:sub(25)) do
                    background.attack.mine()
                end
            end
        end
    elseif text == "terminate-player" then
        player.dead = true
    elseif text == "stop-computer" then
        love.event.quit(0)
    elseif text:sub(1, 13) == "write-output " then
        background.addPrint(text:sub(14))
    elseif text:sub(1, 10) == "get-random" then
        local min, max = 1, 2147483647

        local _, i = text:find("-min ")
        if i then
            min = (tonumber(text:sub(i + 1, (text:find(" ", i + 1) or 0) - 1)) or 1)
        end

        local _, j = text:find("-max ")
        if j then
            max = (tonumber(text:sub(j + 1, (text:find(" ", j + 1) or 0) - 1)) or 1)
        end

        background.addPrint(tostring(math.random(min, max - 1)))
    elseif text == "get-help" then
        background.addPrint("You can find help at: https://github.com/workingCode403/terminal-space/blob/main/tutorial.md")
    elseif text == "auto-start" then
        background.autoStart = true
        background.startTimer = 0
        player.visible = true
    elseif text:sub(1, 9) == "set-time " then
        if text == "set-time infinite" then
            background.goalTime = 0
        else
            background.goalTime = (tonumber(text:sub(10)) or 0)
        end
    end
end

function background.update()
    if not background.input and not background.autoStart then
        if background.startTimer == 5 then
            background.addPrint("Terminal Space v0.2 by workingCode403")
        elseif background.startTimer == 35 then
            background.addPrint("      Font Used: Courier Prime")
        elseif background.startTimer == 65 then
            background.addPrint(" Song Used: WaxTerK - Space Telecom")
        elseif background.startTimer == 155 then
            background.addPrint(" Enter command 'start-game' to start")
            background.addPrint("-------------------------------------")
            background.input = true
        end
    else
        if background.autoStart and #background.printList < 2 then
            if background.startTimer == 0 then
                player.visible = true
                background.addPrint("Restarting")
            elseif background.startTimer == 30 then
                background.printList[1] = "Restarting."
            elseif background.startTimer == 60 then
                background.printList[1] = "Restarting.."
            elseif background.startTimer == 90 then
                background.printList[1] = "Restarting..."
            elseif background.startTimer == 120 then
                player.mode = 1
                background.song:play()
            end
        elseif background.startTimer == 30 then
            player.mode = 1
            background.song:play()
        end
    end

    background.startTimer = background.startTimer + 1
end

function background.draw()
    local font = love.graphics.newFont("CourierPrime.ttf")
    local scale = 1.5
    love.graphics.setColor(0.012, 0.882, 0.271, 0.6)

    love.graphics.print("> " .. background.printText, font, 5, love.graphics.getHeight() - font:getHeight() * scale - 5, 0, scale, scale)
    for i = 1, #background.printList do
        if background.printList[i] then
            love.graphics.print(
                    background.printList[i],
                    font, 5,
                    love.graphics.getHeight() - font:getHeight() * scale * (#background.printList - i + 2) - font:getHeight() - 5,
                    0, scale, scale
            )
        end
    end

    local hour = math.floor(background.timer / 3600)
    local minute = tostring(math.floor((background.timer - hour * 3600) / 60))
    local second = tostring(math.floor(background.timer - tonumber(minute) * 60))

    if tonumber(minute) < 10 then
        minute = "0" .. minute
    end
    if tonumber(second) < 10 then
        second = "0" .. second
    end

    local width = font:getWidth("Uptime: " .. hour .. ":" .. minute .. ":" .. second) * scale

    if player.mode == 1 then
        love.graphics.print("Uptime: " .. hour .. ":" .. minute .. ":" .. second, font, love.graphics.getWidth() - 5 - width, 5, 0, scale, scale)
    end

    background.uptime = hour .. ":" .. minute .. ":" .. second
end

function background.die()
    love.graphics.setColor(1, 1, 1, 1 - background.dieTimer / background.maxDT)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(0.04, 0.04, 0.04)
    love.graphics.rectangle("fill",
            0, 0, love.graphics.getWidth(),
            (1 - (background.dieTimer2 - 60) / (background.maxDT2 - 60)) * love.graphics.getHeight() / 2
    )
    love.graphics.rectangle("fill", 0,
            love.graphics.getHeight()
                - (1 - (background.dieTimer2 - 60) / (background.maxDT2 - 60))
                * love.graphics.getHeight() / 2,
            love.graphics.getWidth(),
            (1 - (background.dieTimer2 - 60) / (background.maxDT2 - 60)) * love.graphics.getHeight() / 2
    )
    background.song:setVolume((background.dieTimer + background.dieTimer2 - 60) / (background.maxDT + background.maxDT2 - 60))

    if background.dieTimer == background.maxDT
    and background.printList[#background.printList] ~= "terminate-player" then
        background.addPrint("terminate-player")
    end

    if background.dieTimer > 0 then
        background.dieTimer = math.max(background.dieTimer - 1, 0)
    elseif background.dieTimer2 > 0 then
        background.dieTimer2 = math.max(background.dieTimer2 - 1, 0)
    else
        background.song:stop()
        background.dead = true
        background.die2(background.d2Timer)
    end
end

function background.die2(d2Timer)
    if d2Timer < 5
    or (d2Timer > 10 and d2Timer < 20) then
        love.graphics.setColor(0.982, 0.112, 0.371, 0.8)
        love.graphics.rectangle("line", 0, love.graphics.getHeight() / 2 - 1, love.graphics.getWidth(), 1)
    elseif d2Timer > 50 then
        love.graphics.setColor(0.982, 0.112, 0.371, 0.2)
        background.scanlineEffect(function()
            love.graphics.rectangle("fill", 0,
                    math.max(0, love.graphics.getHeight() / 2
                        - (d2Timer - 50) * 30),
                    love.graphics.getWidth(),
                    math.min(love.graphics.getHeight(),
                    (d2Timer - 50) * 60)
            )
        end)
        love.graphics.setColor(0.982, 0.112, 0.371, 0.8)
        love.graphics.rectangle("line", 0,
                math.max(0, love.graphics.getHeight() / 2
                    - (d2Timer - 50) * 30),
                love.graphics.getWidth(),
                math.min(love.graphics.getHeight(),
                (d2Timer - 50) * 60)
        )
    end

    if d2Timer > 110 then
        player.mode = 2
        local font = love.graphics.newFont("CourierPrime.ttf")
        local scale = 3
        love.graphics.print("Session Terminated", font,
                (love.graphics.getWidth() - font:getWidth("Session Terminated") * scale ) / 2,
                love.graphics.getHeight() / 2 - font:getHeight() * scale * 2,
                0, scale, scale
        )
        love.graphics.print("Uptime: " .. background.uptime, font,
                (love.graphics.getWidth() - font:getWidth("Uptime: " .. background.uptime) * scale * 0.8) / 2,
                love.graphics.getHeight() / 2 - font:getHeight() * scale * 0.8,
                0, scale * 0.8, scale * 0.8
        )

        if background.dieSelect == 1 then
            love.graphics.print("> Restart", font,
                    love.graphics.getWidth() / 2 - font:getWidth("> Restart") * scale / 3,
                    love.graphics.getHeight() / 2 + 10,
                    0, scale / 1.5, scale / 1.5)
            love.graphics.print("  Quit", font,
                    love.graphics.getWidth() / 2 - font:getWidth("> Restart") * scale / 3,
                    love.graphics.getHeight() / 2 + font:getHeight() * scale + 10,
                    0, scale / 1.5, scale / 1.5)
        else
            love.graphics.print("  Restart", font,
                    love.graphics.getWidth() / 2 - font:getWidth("> Restart") * scale / 3,
                    love.graphics.getHeight() / 2 + 10,
                    0, scale / 1.5, scale / 1.5)
            love.graphics.print("> Quit", font,
                    love.graphics.getWidth() / 2 - font:getWidth("> Restart") * scale / 3,
                    love.graphics.getHeight() / 2 + font:getHeight() * scale + 10,
                    0, scale / 1.5, scale / 1.5)
        end
    end

    background.d2Timer = background.d2Timer + 1
end

function background.close()
    if background.closeTimer * 60 <= love.graphics.getHeight()
    and background.closeTimer >= 0 then
        love.graphics.setColor(0.04, 0.04, 0.04, 1)
        love.graphics.rectangle("fill", 0,
                math.min(love.graphics.getHeight() / 2,
                    background.closeTimer * 30),
                love.graphics.getWidth(),
                math.max(0,
                    love.graphics.getHeight() - background.closeTimer * 60)
        )
        love.graphics.setColor(0.982, 0.112, 0.371, 0.2)
        background.scanlineEffect(function()
            love.graphics.rectangle("fill", 0,
                    math.min(love.graphics.getHeight() / 2,
                        background.closeTimer * 30),
                    love.graphics.getWidth(),
                    math.max(0,
                        love.graphics.getHeight() - background.closeTimer * 60)
            )
        end)
        love.graphics.setColor(0.982, 0.112, 0.371, 0.8)
        love.graphics.rectangle("line", 0,
                math.min(love.graphics.getHeight() / 2,
                    background.closeTimer * 30),
                love.graphics.getWidth(),
                math.max(0,
                    love.graphics.getHeight() - background.closeTimer * 60)
        )
    end

    if background.closeTimer < 0 then
        love.graphics.setColor(0.04, 0.04, 0.04, 1)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(0.982, 0.112, 0.371, 0.2)
        background.scanlineEffect(function()
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        end)
        love.graphics.setColor(0.982, 0.112, 0.371, 0.8)
        love.graphics.rectangle("line", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end

    background.closeTimer = background.closeTimer + 1

    if (background.closeTimer - 50) * 60 >= love.graphics.getHeight() then
        player.dead = false
        player.mode = 0
        background.closeTimer = -30
        if background.exit then
            love.event.quit(0)
        end
    end
end

function background.win(d2Timer)
    if d2Timer < 30 then
        background.song:setVolume(math.max(1 - (d2Timer / 30), 0))
    end

    love.graphics.setColor(0.04, 0.04, 0.04, 1)
    love.graphics.rectangle("fill", 0,
            math.max(0, love.graphics.getHeight() / 2
                - d2Timer * 30),
            love.graphics.getWidth(),
            math.min(love.graphics.getHeight(),
            d2Timer * 60)
    )
    love.graphics.setColor(0.371, 0.212, 0.982, 0.2)
    background.scanlineEffect(function()
        love.graphics.rectangle("fill", 0,
                math.max(0, love.graphics.getHeight() / 2
                    - d2Timer * 30),
                love.graphics.getWidth(),
                math.min(love.graphics.getHeight(),
                d2Timer * 60)
        )
    end)
    love.graphics.setColor(0.371, 0.212, 0.982, 0.8)
    love.graphics.rectangle("line", 0,
            math.max(0, love.graphics.getHeight() / 2
                - d2Timer * 30),
            love.graphics.getWidth(),
            math.min(love.graphics.getHeight(),
            d2Timer * 60)
    )

    if d2Timer > 60 then
        background.song:stop()
        background.song:setVolume(1)

        local font = love.graphics.newFont("CourierPrime.ttf")
        local scale = 3
        love.graphics.print("Program Exited", font,
                (love.graphics.getWidth() - font:getWidth("Program Exited") * scale ) / 2,
                love.graphics.getHeight() / 2 - font:getHeight() * scale * 2,
                0, scale, scale
        )
        love.graphics.print("Uptime: " .. background.uptime, font,
                (love.graphics.getWidth() - font:getWidth("Uptime: " .. background.uptime) * scale * 0.8) / 2,
                love.graphics.getHeight() / 2 - font:getHeight() * scale * 0.8,
                0, scale * 0.8, scale * 0.8
        )

        if background.dieSelect == 1 then
            love.graphics.print("> Restart", font,
                    love.graphics.getWidth() / 2 - font:getWidth("> Restart") * scale / 3,
                    love.graphics.getHeight() / 2 + 10,
                    0, scale / 1.5, scale / 1.5)
            love.graphics.print("  Quit", font,
                    love.graphics.getWidth() / 2 - font:getWidth("> Restart") * scale / 3,
                    love.graphics.getHeight() / 2 + font:getHeight() * scale + 10,
                    0, scale / 1.5, scale / 1.5)
        else
            love.graphics.print("  Restart", font,
                    love.graphics.getWidth() / 2 - font:getWidth("> Restart") * scale / 3,
                    love.graphics.getHeight() / 2 + 10,
                    0, scale / 1.5, scale / 1.5)
            love.graphics.print("> Quit", font,
                    love.graphics.getWidth() / 2 - font:getWidth("> Restart") * scale / 3,
                    love.graphics.getHeight() / 2 + font:getHeight() * scale + 10,
                    0, scale / 1.5, scale / 1.5)
        end
    end

    background.d2Timer = background.d2Timer + 1
end

function background.winClose()
    if background.closeTimer * 60 <= love.graphics.getHeight()
    and background.closeTimer >= 0 then
        love.graphics.setColor(0.04, 0.04, 0.04, 1)
        love.graphics.rectangle("fill", 0,
                math.min(love.graphics.getHeight() / 2,
                    background.closeTimer * 30),
                love.graphics.getWidth(),
                math.max(0,
                    love.graphics.getHeight() - background.closeTimer * 60)
        )
        love.graphics.setColor(0.371, 0.212, 0.982, 0.2)
        background.scanlineEffect(function()
            love.graphics.rectangle("fill", 0,
                    math.min(love.graphics.getHeight() / 2,
                        background.closeTimer * 30),
                    love.graphics.getWidth(),
                    math.max(0,
                        love.graphics.getHeight() - background.closeTimer * 60)
            )
        end)
        love.graphics.setColor(0.371, 0.212, 0.982, 0.8)
        love.graphics.rectangle("line", 0,
                math.min(love.graphics.getHeight() / 2,
                    background.closeTimer * 30),
                love.graphics.getWidth(),
                math.max(0,
                    love.graphics.getHeight() - background.closeTimer * 60)
        )
    end

    if background.closeTimer < 0 then
        love.graphics.setColor(0.04, 0.04, 0.04, 1)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(0.371, 0.212, 0.982, 0.2)
        background.scanlineEffect(function()
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        end)
        love.graphics.setColor(0.371, 0.212, 0.982, 0.8)
        love.graphics.rectangle("line", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end

    background.closeTimer = background.closeTimer + 1

    if (background.closeTimer - 50) * 60 >= love.graphics.getHeight() then
        player.dead = false
        player.mode = 0
        background.closeTimer = -30
        if background.exit then
            love.event.quit(0)
        end
    end
end

return background