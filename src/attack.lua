local obstacle = require("obstacle")
local background = require("background")
local player = require("player")

local attack = {}

attack.timer = 2
attack.laserPos = {}
attack.laserAwait = nil

function attack.update(dt)
    if not player.dead then
        background.timer = background.timer + dt
    end
    attack.timer = attack.timer - dt

    if background.goalTime > 0 and background.timer >= background.goalTime then
        player.mode = 4
    end

    if attack.timer <= 0 then
        local chance = math.random(5)
        if chance > 3 then
            attack.double()
            background.addPrint("spawn-attack -t double")
            attack.timer = 12
        elseif chance < 3 then
            attack.single()
            background.addPrint("spawn-attack -t single")
            attack.timer = 12
        else
            attack.timer = 4
        end
    end

    if math.random(400) == 1 then
        local amount = math.random(10)
        for i = 1, amount do
            attack.mine()
        end

        background.addPrint("spawn-attack -t mine -a " .. amount)
    end

    if math.random(1800) == 1 then
        attack.bounce()
        background.addPrint("spawn-attack -t bounce")
    end
end

function attack.double()
    local width = 300
    local height = 150

    if math.random(2) == 1 then
        obstacle.create(0 - width / 2, (love.graphics.getHeight() - height) / 2 - 150, width, height, 160, 0)
        obstacle.create(love.graphics.getWidth() + width / 2, (love.graphics.getHeight() + height) / 2 + 150, width, height, -160, 0)
    else
        obstacle.create(0 - width / 2, (love.graphics.getHeight() + height) / 2 + 150, width, height, 160, 0)
        obstacle.create(love.graphics.getWidth() + width / 2, (love.graphics.getHeight() - height) / 2 - 150, width, height, -160, 0)
    end
end

function attack.single()
    local width = 300
    local height = 150

    if math.random(2) == 1 then
        obstacle.create(0 - width / 2, love.graphics.getHeight() / 2 + math.random(-225, 225), width, height, 160, 0)
    else
        obstacle.create(love.graphics.getWidth() + width / 2, love.graphics.getHeight() / 2 + math.random(-225, 225), width, height, -160, 0)
    end
end

function attack.mine()
    obstacle.createCircleF(
            math.random(30, love.graphics.getWidth() - 30),
            math.random(30, love.graphics.getHeight() - 30),
            30,
            function(obs)
                if obs.time == 40 then
                    obs.disabled = false
                elseif obs.time == 80 then
                    obs.destroy = true
                end
            end,
            true
    )
end

function attack.bounce()
    obstacle.createCircleF(
            love.graphics.getWidth() / 2,
            love.graphics.getHeight() / 2,
            40,
            function(obs)
                if obs.time >= 1800 then
                    obs.destroy = true
                end

                if obs.time == 0 then
                    obs.dir = math.random(360)
                end

                if obs.time == 80 then
                    obs.disabled = false

                    obs.dx0 = math.cos(math.rad(obs.dir))
                    obs.dy0 = math.sin(math.rad(obs.dir))
                elseif obs.time > 80 then
                    obs.x = obs.x + obs.dx0 * 8
                    obs.y = obs.y + obs.dy0 * 8

                    if love.graphics.getWidth() then
                        if obs.x > love.graphics.getWidth() - obs.radius then
                            obs.x = love.graphics.getWidth() - obs.radius
                            obs.dx0 = obs.dx0 * -1
                        elseif obs.x < obs.radius then
                            obs.x = obs.radius
                            obs.dx0 = obs.dx0 * -1
                        end
                    end

                    if love.graphics.getHeight() then
                        if obs.y > love.graphics.getHeight() - obs.radius then
                            obs.y = love.graphics.getHeight() - obs.radius
                            obs.dy0 = obs.dy0 * -1
                        elseif obs.y < obs.radius then
                            obs.y = obs.radius
                            obs.dy0 = obs.dy0 * -1
                        end
                    end
                end
            end,
            true
    )
end

function attack.laser()
    local count = math.random(3)
    local a, b = 0, 0

    background.addPrint("spawn-attack -t laser")

    for i = 1, count do
        local position = math.random(10)

        while position == a or position == b do
            position = math.random(10)
        end

        obstacle.create(
                love.graphics.getWidth() * ((position - 1) / 10)
                    + love.graphics.getWidth() / 20,
                love.graphics.getHeight() / 2,
                love.graphics.getWidth() / 10,
                love.graphics.getHeight(),
                0,
                0,
                true
        )

        table.insert(attack.laserPos, i,
                love.graphics.getWidth() * ((position - 1) / 10)
                    + love.graphics.getWidth() / 20
        )

        if a == 0 then
            a = position
        else
            b = position
        end
    end

    attack.laserAwait = true
end

function attack.laserActivate()
    for i = 1, 3 do
        if attack.laserPos[i] then
            local obs = obstacle.getObsAt(attack.laserPos[i], love.graphics.getHeight() / 2)

            if obs then
                obs.disabled = false
            end
        end
    end

    attack.laserAwait = false
end

function attack.laserDeactivate()
    for i = 1, 3 do
        if attack.laserPos[i] then
            local obs = obstacle.getObsAt(attack.laserPos[i], love.graphics.getHeight() / 2)

            if obs then
                obs.destroy = true
            end
        end
    end

    attack.laserAwait = nil
end

return attack