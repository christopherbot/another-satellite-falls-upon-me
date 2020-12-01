HC = require('libraries/hardoncollider')
Timer = require('libraries/timer')

GAME_TITLE       = 'Another Satellite Falls Upon Me'
GAME_TITLE_ALT_1 = ' not               al     on  e'
GAME_TITLE_ALT_2 = '         a  ll     al     on  e'

local Title = require('title')
local Room1 = require('room1')

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

local ROOMS = { Title, Room1 }

function love.load()
  -- images
  tile_sheet = love.graphics.newImage('images/background-tile-sheet.png')
  tile_sheet_frames = 4
  astronaut_without_fire_image_data = love.image.newImageData('images/astronaut-on-rocket-no-fire.png')
  astronaut_with_fire_image_data = love.image.newImageData('images/astronaut-on-rocket.png')
  celestial_objects_sheet = love.graphics.newImage('images/celestial-objects.png')
  oxygen_tank_image = love.graphics.newImage('images/oxygen-tank.png')
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

  -- fonts
  font = love.graphics.newFont('fonts/Share-TechMono.ttf', 20)
  love.graphics.setFont(font)

  -- audio
  -- Note: the music is played in title.lua to sync it with the title copy
  music = love.audio.newSource('sound/into-space.ogg', 'stream')
  music:setLooping(true)
  audio_enabled = true
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
  if key == 'm' then
    audio_enabled = not audio_enabled
    love.audio.setVolume(audio_enabled and 1 or 0)
  end

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
