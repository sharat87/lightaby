require 'math'
require 'os'
require 'io'

-- Read http://mathworld.wolfram.com/LightsOutPuzzle.html for the mathematics
-- involved in making lightbox levels

local levelMaker = {}

function levelMaker.newLevel(rows, cols)

    math.randomseed(os.time())

    -- Initialize the all-unlit board matrix.
    boardMatrix = {}

    -- These lights are hit to create the level. This is also, the *solution* :)
    states = {}
    solution = states

    for r = 0, (rows - 1) do

        boardMatrix[r] = {}
        states[r] = {}

        for c = 0, (cols - 1) do
            boardMatrix[r][c] = 0
            states[r][c] = math.random(0, 1)
            io.write(states[r][c] .. ' ')
        end

        print('')

    end

    for r = 0, (rows - 1) do
        for c = 0, (cols - 1) do

            if states[r][c] == 1 then

                boardMatrix[r][c] = boardMatrix[r][c] + 1

                if r > 0 then
                    boardMatrix[r - 1][c] = boardMatrix[r - 1][c] + 1
                end

                if r < rows - 1 then
                    boardMatrix[r + 1][c] = boardMatrix[r + 1][c] + 1
                end

                if c > 0 then
                    boardMatrix[r][c - 1] = boardMatrix[r][c - 1] + 1
                end

                if c < cols - 1 then
                    boardMatrix[r][c + 1] = boardMatrix[r][c + 1] + 1
                end

            end

        end
    end

    level = {}

    for r = 0, (rows - 1) do
        level[r] = {}
        for c = 0, (cols - 1) do
            if boardMatrix[r][c] % 2 == 1 then
                level[r][c] = true
            end
        end
    end

    return level, solution

end

return levelMaker
