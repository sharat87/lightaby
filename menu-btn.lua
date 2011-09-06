u = require 'utils'
local goo = goo or require('goo')

local MenuBtn = class('MenuBtn', goo.button)

MenuBtn.commonOpts = {}

function MenuBtn:initialize(opts)

    opts = u.mergeTables(MenuBtn.commonOpts, opts)

    goo.button.initialize(self, opts.parent)

    self.style = {
        textColor = {0, 0, 0},
        textFont = buttonFont,
    }

    for k, v in pairs(opts.style or {}) do
        self.style[k] = v
    end

    self.w = self.style.inactiveImage:getWidth()
    self.h = self.style.inactiveImage:getHeight()

    self:setPos(opts.x, opts.y)

    if opts.centerHorizontallyWithin then
        self:centerHorizontally(opts.centerHorizontallyWithin)
    end

    if opts.text then
        self:setText(opts.text)
    end

    self.onClick = opts.onClick
    self.onLeftClick = opts.onLeftClick

end

function MenuBtn:draw()

    if love.mouse.isDown('l') and self:inBounds(love.mouse.getPosition()) then
        love.graphics.draw(self.style.activeImage, 0, 0)
    else
        love.graphics.draw(self.style.inactiveImage, 0, 0)
    end

    love.graphics.setFont(self.style.textFont)
    love.graphics.setColor(self.style.textColor)
    love.graphics.printf(self.text, 0, 0 + 8, self.w, 'center')

end

function MenuBtn:centerHorizontally(width)
    self:setPos(width/2 - self.w/2, self.y)
end

function MenuBtn:mousereleased(x, y, btn)
    if self.onClick then self:onClick(btn) end
    if self.onLeftClick and btn == 'l' then
        self:onLeftClick(btn)
    end
    self:updateBounds('children', self.updateBounds)
end

function MenuBtn:mousepressed(x, y, btn) end

return MenuBtn
