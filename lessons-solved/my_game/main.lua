-- Pong Game in Lua using LÖVE 2D framework

function love.load()
    -- Window setup
    love.window.setMode(800, 600)
    love.window.setTitle("Pong")
    
    -- Game state
    gameWidth = 800
    gameHeight = 600
    
    -- Paddle properties
    paddleWidth = 10
    paddleHeight = 80
    paddleSpeed = 400
    
    -- Left paddle (Player 1)
    player1 = {
        x = 20,
        y = gameHeight / 2 - paddleHeight / 2,
        width = paddleWidth,
        height = paddleHeight,
        dy = 0,
        score = 0
    }
    
    -- Right paddle (Player 2 - AI)
    player2 = {
        x = gameWidth - 20 - paddleWidth,
        y = gameHeight / 2 - paddleHeight / 2,
        width = paddleWidth,
        height = paddleHeight,
        dy = 0,
        score = 0
    }
    
    -- Ball properties
    ball = {
        x = gameWidth / 2,
        y = gameHeight / 2,
        radius = 5,
        dx = -400,
        dy = -400,
        speed = 400
    }
    
    -- AI difficulty (0 to 1, higher = harder)
    aiDifficulty = 0.8
end

function love.update(dt)
    -- Player 1 controls (W/S keys)
    if love.keyboard.isDown("w") then
        player1.dy = -paddleSpeed
    elseif love.keyboard.isDown("s") then
        player1.dy = paddleSpeed
    else
        player1.dy = 0
    end
    
    -- Update player 1 position
    player1.y = player1.y + player1.dy * dt
    
    -- Keep player 1 in bounds
    if player1.y < 0 then
        player1.y = 0
    elseif player1.y + player1.height > gameHeight then
        player1.y = gameHeight - player1.height
    end
    
    -- AI for player 2
    local ballCenter = ball.y
    local paddleCenter = player2.y + player2.height / 2
    local aiResponse = paddleSpeed * aiDifficulty
    
    if ballCenter < paddleCenter - 10 then
        player2.y = player2.y - aiResponse * dt
    elseif ballCenter > paddleCenter + 10 then
        player2.y = player2.y + aiResponse * dt
    end
    
    -- Keep player 2 in bounds
    if player2.y < 0 then
        player2.y = 0
    elseif player2.y + player2.height > gameHeight then
        player2.y = gameHeight - player2.height
    end
    
    -- Update ball position
    ball.x = ball.x + ball.dx * dt
    ball.y = ball.y + ball.dy * dt
    
    -- Ball collision with top and bottom
    if ball.y - ball.radius < 0 then
        ball.y = ball.radius
        ball.dy = -ball.dy
    elseif ball.y + ball.radius > gameHeight then
        ball.y = gameHeight - ball.radius
        ball.dy = -ball.dy
    end
    
    -- Ball collision with left paddle
    if ball.x - ball.radius < player1.x + player1.width and
       ball.y > player1.y and
       ball.y < player1.y + player1.height then
        ball.x = player1.x + player1.width + ball.radius
        ball.dx = -ball.dx
        
        -- Add spin based on where it hits the paddle
        local hitPos = (ball.y - player1.y) / player1.height
        ball.dy = (hitPos - 0.5) * 600
    end
    
    -- Ball collision with right paddle
    if ball.x + ball.radius > player2.x and
       ball.y > player2.y and
       ball.y < player2.y + player2.height then
        ball.x = player2.x - ball.radius
        ball.dx = -ball.dx
        
        -- Add spin based on where it hits the paddle
        local hitPos = (ball.y - player2.y) / player2.height
        ball.dy = (hitPos - 0.5) * 600
    end
    
    -- Ball out of bounds - left side (player 2 scores)
    if ball.x < 0 then
        player2.score = player2.score + 1
        resetBall()
    end
    
    -- Ball out of bounds - right side (player 1 scores)
    if ball.x > gameWidth then
        player1.score = player1.score + 1
        resetBall()
    end
end

function resetBall()
    ball.x = gameWidth / 2
    ball.y = gameHeight / 2
    ball.dx = -400 * (math.random() > 0.5 and 1 or -1)
    ball.dy = (math.random() - 0.5) * 400
end

function love.draw()
    -- Set background color
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)
    
    -- Draw center line
    love.graphics.setColor(1, 1, 1)
    for y = 0, gameHeight, 20 do
        love.graphics.rectangle("fill", gameWidth / 2 - 2, y, 4, 10)
    end
    
    -- Draw paddles
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", player1.x, player1.y, player1.width, player1.height)
    love.graphics.rectangle("fill", player2.x, player2.y, player2.width, player2.height)
    
    -- Draw ball
    love.graphics.circle("fill", ball.x, ball.y, ball.radius)
    
    -- Draw scores
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(40))
    love.graphics.print(player1.score, gameWidth / 4, 50)
    love.graphics.print(player2.score, 3 * gameWidth / 4, 50)
    
    -- Draw instructions
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("W/S to move | ESC to quit", 10, gameHeight - 30)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end