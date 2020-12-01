HC = require('libraries/hardoncollider')
Timer = require('libraries/timer')

GAME_TITLE       = 'Another Satellite Falls Upon Me'
GAME_TITLE_ALT_1 = ' not               al     on  e'
GAME_TITLE_ALT_2 = '         a  ll     al     on  e'

local helpers = require('helpers')
local Title = require('title')
local Room1 = require('room1')
local SoundIcon = require('sound-icon')

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
  sound_image = love.graphics.newImage('images/sound.png')
  no_sound_image = love.graphics.newImage('images/no-sound.png')

  -- settings
  love.window.setMode(1130, 640)

  -- timer
  timer = Timer()

  -- initial state
  current_game_state = game_states.intro
  current_room_index = 1
  current_room = ROOMS[current_room_index]
  current_room:initialize()
  paused = false

  -- fonts
  font = love.graphics.newFont('fonts/Share-TechMono.ttf', 20)
  love.graphics.setFont(font)

  -- audio
  -- Note: the music is played in title.lua to sync it with the title copy
  music = love.audio.newSource('sound/into-space.ogg', 'stream')
  music:setLooping(true)
  audio_enabled = true
  sound_icon = SoundIcon:new()
  sound_icon:initialize()
end

function love.update(dt)
  if paused then return end
  timer:update(dt)
  require("lurker").update()
  current_room:update(dt)
end

function love.draw()
  -- only dim the background, not the pause menu or sound icon
  if paused then helpers.setColor(255, 255, 255, 0.6) end
  current_room:draw()
  if paused then helpers.resetColor() end

  sound_icon:draw()

  if paused then
    local pause_text = {
      'The journey is on pause.',
      '',
      'Press [Enter] or [Esc] to resume.',
      'Press 1 to return to the main menu.',
    }
    for i, text in ipairs(pause_text) do
      local text_width, text_height = font:getWidth(text), font:getHeight(text)
      local padding = 70
      love.graphics.print(
        text,
        love.graphics.getWidth() - padding,
        text_height * (i - 1) + padding,
        0,
        1,
        1,
        text_width,
        text_height
      )
    end
  end
end

function toggle_pause()
  paused = not paused
  if paused then music:pause() else music:play() end
end

function love.keypressed(key)
  if key == 'm' then
    audio_enabled = not audio_enabled
    love.audio.setVolume(audio_enabled and 1 or 0)
  end
  if key == 'escape' then
    toggle_pause()
  end

  local next_room

  if paused and key == '1' then
    if paused then
      -- Stop the music so that it restarts from the beginning
      -- when switching back to the title screen
      music:stop()
      toggle_pause()
    end
    current_game_state = game_states.intro
    current_room_index = 1
  end

  if key == 'return' then
    if paused then
      toggle_pause()
    else
      current_room_index = current_room_index + 1
    end
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
