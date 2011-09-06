local conf = {
    screenWidth = 340,
    screenHeight = 420
}

function love.conf(t)
    t.title = 'Lightaby'
    t.author = '@sharat87'
    t.identity = 'lightaby'
    t.version = 0.1
    t.screen.width = conf.screenWidth
    t.screen.height = conf.screenHeight
end

return conf
