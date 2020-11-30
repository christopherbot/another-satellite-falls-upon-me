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

GAME_TITLE       = 'Another Satellite Falls Upon Me'
GAME_TITLE_ALT_1 = ' not               al     on  e'
GAME_TITLE_ALT_2 = '         a  ll     al     on  e'

local Menu = require('menu')
local Room1 = require('room1')
local Room2 = require('room2')

game_states = {
  intro = 'intro',
  level1 = 'level1',
  get_boost = 'get_boost',
  level2 = 'level2',
  get_dive = 'get_dive',
  level3 = 'level3',
  reach_shuttle = 'reach_shuttle',
  neverending = 'neverending',
}

local ROOMS = { Menu, Room1, Room2 }

function love.load()
  -- audio
  music = love.audio.newSource('sound/into-space.ogg', 'stream')
  music:setLooping(true)
  music:play()

  -- images
  tile_sheet = love.graphics.newImage('images/background-tile-sheet.png')
  tile_sheet_frames = 4
  -- player_image = love.graphics.newImage('images/player.png')
  -- astronaut_image_data = love.image.newImageData('images/astronaut.png')
  -- astronaut_on_rocket_image_data = love.image.newImageData('images/astronaut-on-rocket.png')
  astronaut_without_fire_image_data = love.image.newImageData('images/astronaut-on-rocket-no-fire.png')
  astronaut_with_fire_image_data = love.image.newImageData('images/astronaut-on-rocket.png')
  -- astronaut_image_data = love.image.newImageData('images/assman72.png')
  -- astronaut_image = love.graphics.newImage('images/astronaut.png')
  celestial_objects_sheet = love.graphics.newImage('images/celestial-objects.png')
  oxygen_tank_image = love.graphics.newImage('images/oxygen-tank.png')
  transparent_oxygen_tank_image = love.graphics.newImage('images/transparent-oxygen-tank.png')
  tall_transparent_oxygen_tank_image = love.graphics.newImage('images/tall-transparent-oxygen-tank.png')
  jetpack_image = love.graphics.newImage('images/jetpack.png')
  thrusters_image = love.graphics.newImage('images/thrusters.png')
  space_shuttle_image = love.graphics.newImage('images/space-shuttle.png')

  -- settings
  love.window.setMode(1130, 640)

  -- timer
  timer = Timer()

  -- initial state
  current_game_state = game_states.intro
  current_room_index = 1
  current_room = ROOMS[current_room_index]
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
  local next_room
  if key == 'escape' then
    current_game_state = game_states.intro
    current_room_index = 1
  end
  if key == 'return' then
    current_room_index = current_room_index + 1
  end
  next_room = ROOMS[current_room_index]

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
  if current_room.keyreleased then
    current_room:keyreleased(key)
  end
end
