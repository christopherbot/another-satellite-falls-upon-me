HC = require('libraries/hardoncollider')
Timer = require('libraries/timer')

GAME_TITLE       = 'Another Satellite Falls Upon Me'
GAME_TITLE_ALT_1 = ' not               al     on  e'
GAME_TITLE_ALT_2 = '         a  ll     al     on  e'

FONT_SIZE = 20
SMALL_FONT_SIZE = 17

local helpers = require('helpers')
local Title = require('title')
local Room1 = require('room1')
local Background = require('background')
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
  arrow_keys_image = love.graphics.newImage('images/arrow-keys.png')
  measuring_tape_image = love.graphics.newImage('images/measuring-tape.png')

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

  -- background for all rooms
  background = Background:new()
  background:initialize()

  -- fonts
  font = love.graphics.newFont('fonts/Share-TechMono.ttf', FONT_SIZE)
  small_font = love.graphics.newFont('fonts/Share-TechMono.ttf', SMALL_FONT_SIZE)
  love.graphics.setFont(font)

  -- audio
  -- Note: the music is played in title.lua to sync it with the title copy
  blip_sound = love.audio.newSource('sound/blip.wav', 'static')
  blip_sound:setVolume(0.3)
  achievement_sound = love.audio.newSource('sound/achievement.wav', 'static')
  achievement_sound:setVolume(0.4)
  small_hit_sound = love.audio.newSource('sound/small-hit.wav', 'static')
  small_hit_sound:setVolume(0.5)
  hit_sound = love.audio.newSource('sound/hit.wav', 'static')
  hit_sound:setVolume(0.3)
  break_sound = love.audio.newSource('sound/break.wav', 'static')
  break_sound:setVolume(0.4)
  whoosh_sound = love.audio.newSource('sound/whoosh.wav', 'static')
  whoosh_sound:setVolume(0.3)
  thrust_sound = love.audio.newSource('sound/thrust.wav', 'static')
  thrust_sound:setVolume(0.3)
  music = love.audio.newSource('sound/into-space.ogg', 'stream')
  music:setLooping(true)
  audio_enabled = true
  sound_icon = SoundIcon:new()
  sound_icon:initialize()
end

function love.update(dt)
  if paused then return end
  timer:update(dt)
  -- for debugging:
  -- require("lurker").update()
  background:update(dt)
  current_room:update(dt)
end

function love.draw()
  -- only dim the background, not the pause menu or sound icon
  if paused then helpers.setColor(255, 255, 255, 0.6) end
  background:draw()
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
    next_room = ROOMS[current_room_index]
  end

  if key == 'return' then
    if paused then
      toggle_pause()
    else
      current_room_index = current_room_index + 1
      next_room = ROOMS[current_room_index]
    end
  end

  if next_room and next_room ~= current_room then
    current_room:destroy()
    next_room:initialize()
    current_room = next_room
  elseif next_room and next_room == current_room and current_room.reset then
    current_room:reset()
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
