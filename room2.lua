local class = require('libraries.middleclass')

local Room2 = class('Room2')

function Room2:initialize()
  print('room2 initialized')
end

function Room2:update(dt)

end

function Room2:draw()
  love.graphics.print('Room 2! Welcome '..name..'.', 400, 300)
end

function Room2:destroy()
  print('room2 destroyed')
end

return Room2
