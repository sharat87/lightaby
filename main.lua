function love.load()

    -- Requires and initializations --------------------------------------------
    require 'math'
    conf = require 'conf'
    goo = require 'goo/goo'
    goo:load()

    local levelMaker = require 'level-maker'

    -- Images, colors and fonts ------------------------------------------------
    bgImage = love.graphics.newImage('images/bg.png')
    bgImage:setWrap('repeat', 'repeat')
    bgQuad = love.graphics.newQuad(0, 0, conf.screenWidth, conf.screenHeight, 360, 360)

    images = {
        lightOn = love.graphics.newImage('images/light-on.png'),
        lightOff = love.graphics.newImage('images/light-off.png'),
        buttonInactive = love.graphics.newImage('images/button-inactive.png'),
        buttonActive = love.graphics.newImage('images/button-active.png')
    }

    appFont = love.graphics.newFont('fonts/LSANS.TTF', 26)
    buttonFont = love.graphics.newFont('fonts/LSANS.TTF', 18)

    love.graphics.setBackgroundColor(255, 255, 255)

    -- Initial game measurements -----------------------------------------------
    padding = 3
    cellWidth = images.lightOn:getWidth()
    cellHeight = images.lightOn:getHeight()

    boardRows = 5
    boardCols = 5

    boardWidth = boardCols * (cellWidth + 2 * padding)
    boardHeight = boardRows * (cellHeight + 2 * padding)

    boardX = (conf.screenWidth - boardWidth) / 2
    boardY = 60

    levelMatrix = {}

    for row = 0, (boardRows - 1) do
        -- The table is full of `nils` which are false,
        -- so we don't have to initialize each cell
        levelMatrix[row] = {}
    end

    initialLevelMatrix, solution = levelMaker.newLevel(boardRows, boardCols)

    levelMatrix = {}
    for k, v in pairs(initialLevelMatrix) do
        levelMatrix[k] = {}
        for k2, v2 in pairs(v) do
            levelMatrix[k][k2] = v2
        end
    end

    -- Game states -------------------------------------------------------------
    local MenuBtn = require 'menu-btn'
    MenuBtn.commonOpts = {
        centerHorizontallyWithin = conf.screenWidth,
        style = {
            activeImage = images.buttonActive,
            inactiveImage = images.buttonInactive,
            textColor = {255, 255, 255},
        },
    }

    lastState = nil
    currentState = 'game'

    gameStates = {}

    gameStates.game = {

        load = function (self)
            self.pauseBtn = MenuBtn:new {
                y = boardY + boardHeight + 30,
                text = 'Pause/Menu',
                onLeftClick = function (self, button)
                    currentState = 'menu'
                end,
            }
        end,

        draw = function (self)
            local mouseX, mouseY = love.mouse.getPosition()

            local row, col
            for row = 0, (boardRows - 1) do
                for col = 0, (boardCols - 1) do

                    local cellX = boardX + col * (cellWidth  + 2 * padding) + padding
                    local cellY = boardY + row * (cellHeight + 2 * padding) + padding

                    -- If this cell is lit, color it special
                    love.graphics.setColor(255, 255, 255)
                    if levelMatrix[row][col] then
                        love.graphics.draw(images.lightOn, cellX, cellY)
                    else
                        love.graphics.draw(images.lightOff, cellX, cellY)
                    end

                end
            end

        end,

        unload = function (self)
            self.pauseBtn:destroy()
        end,

        mousereleased = function (x, y, button)
            if button == 'l' then

                local row = math.floor((y - boardY) / (cellHeight + 2 * padding))
                local col = math.floor((x - boardX) / (cellWidth  + 2 * padding))

                -- Clicked outside of the board's bounds?
                if row < 0 or row >= boardRows or col < 0 or col >= boardCols then
                    return
                end

                -- Clicked in x-padding?
                local relativeX = (x - boardX) % (cellWidth + 2 * padding)
                if relativeX < padding or relativeX > cellWidth + padding then
                    return
                end

                -- Clicked in y-padding?
                local relativeY = (y - boardY) % (cellHeight + 2 * padding)
                if relativeY < padding or relativeY > cellHeight + padding then
                    return
                end

                -- If through to here, we have a valid cell clicked!
                levelMatrix[row][col] = not levelMatrix[row][col]

                -- Toggle upper cell, if clicked cell is not in the top row
                if row > 0 and row < boardRows then
                    levelMatrix[row - 1][col] = not levelMatrix[row - 1][col]
                end

                -- Toggle lower cell, if clicked cell is not in the bottom row
                if row >= 0 and row < boardRows - 1 then
                    levelMatrix[row + 1][col] = not levelMatrix[row + 1][col]
                end

                -- Toggle left cell, if clicked cell is not in the left most col
                if col > 0 and col < boardCols then
                    levelMatrix[row][col - 1] = not levelMatrix[row][col - 1]
                end

                -- Toggle right cell, if clicked cell is not in the right most col
                if col >= 0 and col < boardCols - 1 then
                    levelMatrix[row][col + 1] = not levelMatrix[row][col + 1]
                end

                -- Check if game over!
                local finished = true
                for r = 0, (boardRows - 1) do
                    for c = 0, (boardCols - 1) do
                        if levelMatrix[r][c] then
                            finished = false
                            break
                        end
                    end
                    if not finished then break end
                end
                if finished then
                    currentState = 'menu'
                end

            end
        end,

    }

    gameStates.menu = {

        load = function (self)

            btnY = 100
            incY = MenuBtn.commonOpts.style.activeImage:getHeight() + 20

            self.resumeBtn = MenuBtn:new {
                y = btnY,
                text = 'Resume',
                onLeftClick = function (self, button)
                    currentState = 'game'
                end,
            }

            btnY = btnY + incY
            self.restartBtn = MenuBtn:new {
                y = btnY,
                text = 'Restart level',
                onLeftClick = function (self, button)
                    -- FIXME: Have to make a copy here too, else subsequent restarts don't work
                    levelMatrix = initialLevelMatrix
                    currentState = 'game'
                end,
            }

            btnY = btnY + incY
            self.newGameBtn = MenuBtn:new {
                y = btnY,
                text = 'New game',
                onLeftClick = function (self, button)
                    levelMatrix, solution = levelMaker.newLevel(boardRows, boardCols)
                    currentState = 'game'
                end,
            }

            btnY = btnY + incY
            self.exitBtn = MenuBtn:new {
                y = btnY,
                text = 'Exit',
                onLeftClick = function (self, button)
                    love.event.push('q')
                end,
            }

        end,

        unload = function (self)
            self.resumeBtn:destroy()
            self.restartBtn:destroy()
            self.newGameBtn:destroy()
            self.exitBtn:destroy()
        end,

    }

end

function love.update(dt)
    goo:update(dt)
end

function love.draw()

    love.graphics.setColor(255, 255, 255)
    love.graphics.drawq(bgImage, bgQuad, 0, 0)

    love.graphics.setFont(appFont)
    love.graphics.printf('Lightaby', 0, 10, conf.screenWidth, 'center')

    local state = gameStates[currentState]

    if currentState ~= lastState then
        if lastState and gameStates[lastState].unload then
            gameStates[lastState]:unload()
        end
        if state.load then state:load() end
        lastState = currentState
    end

    if state.draw then state:draw() end
    goo:draw()

end

function love.mousepressed(x, y, button)
    goo:mousepressed(x,y,button)
end

function love.mousereleased(x, y, button)
    if gameStates[currentState].mousereleased then
        gameStates[currentState].mousereleased(x, y, button)
    end
    goo:mousereleased(x, y, button)
end

function love.keypressed(key, unicode)
    goo:keypressed(key,unicode)
    if key == 'escape' then
        love.event.push('q')
    end
end

function love.keyreleased(key, unicode)
    goo:keyreleased(key,unicode)
end
