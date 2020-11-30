local class = require('libraries.middleclass')

local Menu = class('Menu')

function Menu:initialize()
  print('menu initialized')
end

function Menu:update(dt)

end

function Menu:draw()
  love.graphics.print(GAME_TITLE, 400, 300)
end

function Menu:destroy()
  print('menu destroyed')
end

return Menu
