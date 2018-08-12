lurker = require "lurker"
lurker.postswap = function (f) 
    init() 
end

-- Load some default values for our rectangle.
function love.load()
  init()
end

function init()
  W = love.graphics.getWidth()
  H = love.graphics.getHeight()
  x, y, w, h = 20, 10, 60, 20
  dx, dy, ddy = 100, 100, 9.82
end

--[[
 https://github.com/overtone/emacs-live
]]--

function sign(x)
  if x >= 0 then
    return 1
  else
    return -1
  end
end
 
-- Increase the size of the rectangle every frame.
function love.update(dt)
  if y<0 or y+h >= H then
    dy= -dy
  end

  if x<0 or x+w >= W then
    dx= -dx
  end
  dy = dy + 40*ddy*dt
  x = x + dx*dt
  y = y + dy*dt
  lurker.update()
end


-- Draw a coloured rectangle.
function love.draw()
  love.graphics.setColor(0, 0.4, 0.4)
  love.graphics.rectangle("fill", x, y, w, h)
end

function test()
    -- body

end
