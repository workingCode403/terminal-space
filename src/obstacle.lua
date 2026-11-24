local background = require("background")
local player = require("player")

local obstacle = {}

obstacle.obstacles = {}

function obstacle.create(x, y, width, height, dx, dy, disabled)
    table.insert(obstacle.obstacles, {
        x = x,
        y = y,
        width = width,
        height = height,
        isCircle = false,
        dx = dx or 0,
        dy = dy or 0,
        destroy = false,
        disabled = disabled or false,
        index = #obstacle.obstacles + 1
    })
end

function obstacle.createF(x, y, width, height, callable, disabled)
    table.insert(obstacle.obstacles, {
        x = x,
        y = y,
        width = width,
        height = height,
        isCircle = false,
        callable = callable,
        time = 0,
        destroy = false,
        disabled = disabled or false,
        index = #obstacle.obstacles + 1
    })
end

function obstacle.createCircle(x, y, radius, dx, dy, disabled)
    table.insert(obstacle.obstacles, {
        x = x,
        y = y,
        radius = radius,
        isCircle = true,
        dx = dx or 0,
        dy = dy or 0,
        destroy = false,
        disabled = disabled or false,
        index = #obstacle.obstacles + 1
    })
end

function obstacle.createCircleF(x, y, radius, callable, disabled)
    table.insert(obstacle.obstacles, {
        x = x,
        y = y,
        radius = radius,
        isCircle = true,
        callable = callable,
        time = 0,
        destroy = false,
        disabled = disabled or false,
        index = #obstacle.obstacles + 1
    })
end

function obstacle.getObsAt(x, y)
    for i, obs in ipairs(obstacle.obstacles) do
        if obs.x == x and obs.y == y then
            return obs
        end
    end

    return nil
end

function obstacle.calcPlayer(dt)
    for i, obs in ipairs(obstacle.obstacles) do
        -- remove

        if obs.destroy then
            table.remove(obstacle.obstacles, i)
        end
        -- move & destroy

        if obs.dx and not player.dead then
            obs.x = obs.x + obs.dx * dt
            obs.y = obs.y + obs.dy * dt

            if (obs.x < 0 - obs.width / 2 and obs.dx < 0)
            or (obs.x > love.graphics.getWidth() + obs.width / 2 and obs.dx > 0)
            or (obs.y < 0 - obs.height / 2 and obs.dy < 0)
            or (obs.y > love.graphics.getHeight() + obs.height / 2 and obs.dy > 0) then
                obs.destroy = true
            end
        elseif not player.dead then
            obs.callable(obs)
            obs.time = obs.time + 1
        end
        -- calculate collisions with player

        if obs.isCircle and not obs.disabled and player.mode == 1 then
            local difX, difY

            for j = 0, player.height do
                difX = player.x - player.width / 2 - obs.x
                difY = player.y + j - player.height / 2 - obs.y

                if math.sqrt(math.pow(difX, 2) + math.pow(difY, 2)) < obs.radius then
                    player.dead = true
                end
            end
            for j = 0, player.height do
                difX = player.x + player.width / 2 - obs.x
                difY = player.y + j - player.height / 2 - obs.y

                if math.sqrt(math.pow(difX, 2) + math.pow(difY, 2)) < obs.radius then
                    player.dead = true
                end
            end
            for j = 0, player.width do
                difX = player.x + j - player.width / 2 - obs.x
                difY = player.y - player.height / 2 - obs.y

                if math.sqrt(math.pow(difX, 2) + math.pow(difY, 2)) < obs.radius then
                    player.dead = true
                end
            end
            for j = 0, player.width do
                difX = player.x + j - player.width / 2 - obs.x
                difY = player.y + player.height / 2 - obs.y

                if math.sqrt(math.pow(difX, 2) + math.pow(difY, 2)) < obs.radius then
                    player.dead = true
                end
            end
        elseif not obs.disabled and player.mode == 1 then
            if player.x + player.width / 2 >= obs.x - obs.width / 2
            and player.y + player.height / 2 >= obs.y - obs.height / 2
            and player.x - player.width / 2 <= obs.x + obs.width / 2
            and player.y - player.height / 2 <= obs.y + obs.height / 2 then
                player.dead = true
            end
        end
    end
end

function obstacle.draw()
    for i, obs in ipairs(obstacle.obstacles) do
        if obs.isCircle and not background.dead then
            obstacle.drawCircle(obs.x, obs.y, obs.radius, obs.disabled, obs)
        elseif not background.dead then
            obstacle.drawEach(
                    obs.x - obs.width / 2,
                    obs.y - obs.height / 2,
                    obs.width,
                    obs.height,
                    obs.disabled
            )
        end
    end
end

function obstacle.drawEach(x, y, width, height, disabled)
    -- draw bg
    if not disabled then
        if player.vertMod == 1 then
            love.graphics.setColor(0.982, 0.112, 0.371, 0.2)
        else
            love.graphics.setColor(0.371, 0.212, 0.982, 0.2)
        end

        background.scanlineEffect(function()
            love.graphics.rectangle("fill", x, y, width, height)
        end)
    end

    -- draw outline
    if player.vertMod == 1 then
        love.graphics.setColor(0.982, 0.112, 0.371, 0.8)
    else
        love.graphics.setColor(0.371, 0.212, 0.982, 0.8)
    end
    love.graphics.rectangle("line", x, y, width, height)
end

function obstacle.drawCircle(x, y, radius, disabled, obs)
    -- draw bg
    if not disabled then
        if player.vertMod == 1 then
            love.graphics.setColor(0.982, 0.112, 0.371, 0.2)
        else
            love.graphics.setColor(0.371, 0.212, 0.982, 0.2)
        end

        background.scanlineEffect(function()
            love.graphics.circle("fill", x, y, radius)
        end)
    end

    -- draw outline
    if player.vertMod == 1 then
        love.graphics.setColor(0.982, 0.112, 0.371, 0.8)
    else
        love.graphics.setColor(0.371, 0.212, 0.982, 0.8)
    end
    love.graphics.circle("line", x, y, radius)

    -- draw indicator (for bounce)
    if obs.dir then
        if obs.time < 80 then
            love.graphics.line(
                    love.graphics.getWidth() / 2 + math.cos(math.rad(obs.dir)) * 60,
                    love.graphics.getHeight() / 2 + math.sin(math.rad(obs.dir)) * 60,
                    love.graphics.getWidth() / 2 + math.cos(math.rad(obs.dir)) * 80,
                    love.graphics.getHeight() / 2 + math.sin(math.rad(obs.dir)) * 80
            )
            love.graphics.line(
                    love.graphics.getWidth() / 2 + math.cos(math.rad(obs.dir)) * 80,
                    love.graphics.getHeight() / 2 + math.sin(math.rad(obs.dir)) * 80,
                    love.graphics.getWidth() / 2 + math.cos(math.rad(obs.dir + 4)) * 75,
                    love.graphics.getHeight() / 2 + math.sin(math.rad(obs.dir + 4)) * 75
            )
            love.graphics.line(
                    love.graphics.getWidth() / 2 + math.cos(math.rad(obs.dir)) * 80,
                    love.graphics.getHeight() / 2 + math.sin(math.rad(obs.dir)) * 80,
                    love.graphics.getWidth() / 2 + math.cos(math.rad(obs.dir - 4)) * 75,
                    love.graphics.getHeight() / 2 + math.sin(math.rad(obs.dir - 4)) * 75
            )
        end
    end
end

return obstacle