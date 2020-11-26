-- local Demo = require('demo')
-- local SquareJump = require('square-jump')

-- local Current = Demo

-- function love.load()
--   Current.load()
-- end

-- function love.update(dt)
--   Current.update(dt)
-- end

-- function love.draw()
--   Current.draw()
-- end

-- function love.keypressed(key)
--   Current.keypressed(key)
-- end

-- function love.keyreleased(key)
--   Current.keyreleased(key)
-- end

-- function love.mousepressed(x, y, button)
--   Current.mousepressed(x, y, button)
-- end

-- function love.mousereleased(x, y, button)
--   Current.mousereleased(x, y, button)
-- end
HC = require('libraries/hardoncollider')
Timer = require('libraries/timer')

local Room1 = require('room1')
local Room2 = require('room2')

local ROOMS = { Room1, Room2 }

function love.load()
  -- images
  tile_sheet = love.graphics.newImage('images/background-tile-sheet.png')
  tile_sheet_frames = 4
  -- player_image = love.graphics.newImage('images/player.png')
  -- astronaut_image_data = love.image.newImageData('images/astronaut.png')
  -- astronaut_on_rocket_image_data = love.image.newImageData('images/astronaut-on-rocket.png')
  astronaut_image_data = love.image.newImageData('images/astronaut-on-rocket.png')
  -- astronaut_image_data = love.image.newImageData('images/assman72.png')
  -- astronaut_image = love.graphics.newImage('images/astronaut.png')
  celestial_objects_sheet = love.graphics.newImage('images/celestial-objects.png')
  oxygen_tank_image = love.graphics.newImage('images/oxygen-tank.png')
  transparent_oxygen_tank_image = love.graphics.newImage('images/transparent-oxygen-tank.png')
  tall_transparent_oxygen_tank_image = love.graphics.newImage('images/tall-transparent-oxygen-tank.png')

  -- settings
  love.window.setMode(1130, 640)

  -- timer
  timer = Timer()

  -- initial state
  current_room = ROOMS[1]
  current_room:initialize()
end

function love.update(dt)
  timer:update(dt)
  require("lurker").update()
  current_room:update(dt)
end

function love.draw()
  current_room:draw()
end

function love.keypressed(key)
  -- print('keypressed', key)
  local next_room
  if key == 'escape' then next_room = ROOMS[1] end
  if key == 'return' then next_room = ROOMS[2] end

  if next_room and next_room ~= current_room then
    current_room:destroy()
    next_room:initialize()
    current_room = next_room
  end

  if current_room.keypressed then
    current_room:keypressed(key)
  end
end

function love.keyreleased(key)
  -- print('keyreleased', key)

  if current_room.keyreleased then
    current_room:keyreleased(key)
  end
end
