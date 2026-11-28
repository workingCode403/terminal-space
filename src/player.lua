local player = {}

player.mode = 0 -- gameplay mode
-- 0 = start
-- 1 = main
-- 2 = die
-- 3 = resetDie

player.visible = false
player.width = 80
player.height = 80
player.x = 500
player.y = 500
player.speed = 600
player.vertMod = 1
player.horDir = 0
player.dead = false

function player.load()
    player.attack = require("attack")
    player.background = require("background")
end

function player.move(dt)
    if player.mode == 1 then
        player.collide = false
        player.horDir = 0

        if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
            player.x = player.x + player.speed * dt
            player.horDir = player.horDir + 1
        end
        if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
            player.x = player.x - player.speed * dt
            player.horDir = player.horDir - 1
        end

        if love.graphics.getWidth() then
            if player.x > love.graphics.getWidth() - player.width / 2 then
                player.x = love.graphics.getWidth() - player.width / 2
            elseif player.x < 0 + player.width / 2 then
                player.x = player.width / 2
            end
        end

        player.y = player.y + player.speed / 2 * dt * player.vertMod

        if love.graphics.getHeight() then
            if player.y >= love.graphics.getHeight() - player.height / 2 then
                player.y = love.graphics.getHeight() - player.height / 2
                player.vertMod = player.vertMod * -1

                if player.attack.laserAwait then
                    player.attack.laserActivate()
                elseif type(player.attack.laserAwait) == "boolean" then
                    player.attack.laserDeactivate()
                elseif math.random(5) == 1 then
                    player.attack.laser()
                end
            elseif player.y <= 0 + player.height / 2 then
                player.y = 0 + player.height / 2
                player.vertMod = player.vertMod * -1

                if player.attack.laserAwait then
                    player.attack.laserActivate()
                elseif type(player.attack.laserAwait) == "boolean" then
                    player.attack.laserDeactivate()
                elseif math.random(5) == 1 then
                    player.attack.laser()
                end
            end
        end
    end
end

function player.draw()
    if player.visible then
        if player.dead then
            player.horDir = 0
        end

        -- draw bg
        love.graphics.setColor(0.012, 0.882, 0.271, 0.2)
        player.background.scanlineEffect(function()
            love.graphics.rectangle("fill",
                    player.x - player.width / 2,
                    player.y - player.height / 2,
                    player.width,
                    player.height
            )
        end)

        -- draw eyes
        love.graphics.setColor(0.7, 0.7, 0.7, 0.9)
        love.graphics.rectangle("fill",
                player.x - player.width * 3 / 10 + player.width / 10 * player.horDir,
                player.y - player.height * 1.5 / 8 + player.height / 8 * player.vertMod,
                player.width / 10,
                player.height * 3 / 8
        )
        love.graphics.rectangle("fill",
                player.x + player.width * 2 / 10 + player.width / 10 * player.horDir,
                player.y - player.height * 1.5 / 8 + player.height / 8 * player.vertMod,
                player.width / 10,
                player.height * 3 / 8
        )

        -- draw outline
        love.graphics.setColor(0.012, 0.882, 0.271, 0.8)
        love.graphics.rectangle("line",
                player.x - player.width / 2,
                player.y - player.height / 2,
                player.width,
                player.height
        )
    end
end

return player