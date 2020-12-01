local class = require('libraries.middleclass')
local GameTitle = require('game-title')
local Player = require('player')
local Controls = require('controls')
local DistanceTracker = require('distance-tracker')
local Planet = require('planet')
local Asteroid = require('asteroid')
local OxygenTank = require('oxygen-tank')
local OxygenLevel = require('oxygen-level')
local Jetpack = require('jetpack')
local Thrusters = require('thrusters')
local SpaceShuttle = require('space-shuttle')
local helpers = require('helpers')

local Room1 = class('Room1')

function Room1:initialize()
  print('room1 initialized')
  collider = HC(100)

  game_title = GameTitle:new()
  game_title:initialize()

  oxygen_level = OxygenLevel:new()
  oxygen_level:initialize()

  player = Player:new()
  player:initialize()

  controls = Controls:new()
  controls:initialize()

  total_distance = 0
  distance_tracker = DistanceTracker:new()
  distance_tracker:initialize()
  distance_tracker:fade_in()

  planets = {}
  asteroids = {}
  oxygen_tanks = {}
end

function Room1:start_creating_planets(every)
  every = every or 1
  self.new_planet_timer = timer:every(every, function()
    local planet = Planet:new()
    planet:initialize()
    table.insert(planets, planet)
  end)
end

function Room1:stop_planets()
  helpers.cancelTimer(self.new_planet_timer)
  for i, planet in ipairs(planets) do
    planet:fade_out(function()
      planets[i] = nil
    end)
  end
end

function Room1:start_creating_asteroids(every)
  every = every or 2
  self.new_asteroid_timer = timer:every(every, function()
    local asteroid = Asteroid:new()
    asteroid:initialize()
    table.insert(asteroids, asteroid)
  end)
end

function Room1:stop_asteroids()
  helpers.cancelTimer(self.new_asteroid_timer)
  for i, asteroid in ipairs(asteroids) do
    asteroid:fade_out(function()
      asteroids[i] = nil
    end)
  end
end

function Room1:start_creating_oxygen_tanks(every)
  every = every or 5
  self.new_oxygen_tank_timer = timer:every(every, function()
    local oxygen_tank = OxygenTank:new()
    oxygen_tank:initialize()
    table.insert(oxygen_tanks, oxygen_tank)
  end)
end

function Room1:stop_oxygen_tanks()
  helpers.cancelTimer(self.new_oxygen_tank_timer)
  for i, tank in ipairs(oxygen_tanks) do
    tank:fade_out(function()
      oxygen_tanks[i] = nil
    end)
  end
end

function Room1:update(dt)
  if current_game_state == game_states.intro and not self.intro_started then
    self.intro_started = true
    player:fade_in(3, function()
      player:say("I need to get to the space shuttle.\nI hope the crew is alr--")
      timer:after(1, function()
        oxygen_level:fade_in(1, function()
          self.intro_planet = Planet:new()
          self.intro_planet:initialize({
            y = love.graphics.getHeight() / 2,
            speed = 400,
          })
          timer:after(0.7, function()
            player:say("Yikes!", 1)
          end)
        end)
      end)
    end)
  end

  if current_game_state == game_states.level1 and not self.level1_started then
    self.level1_started = true
    player:enable_control()
    oxygen_level:start_decreasing()
    self:start_creating_oxygen_tanks()
    self:start_creating_planets()
  end

  game_title:update(dt)
  player:update(dt)
  total_distance = total_distance + dt
  oxygen_level:update(dt)

  if self.intro_planet then
    self.intro_planet:update(dt)

    if self.intro_planet:collidesWith(player.shape) then
      hit_sound:play()
      self.intro_planet:onCollide()
      oxygen_level:decrease()
      player:onCollide()
      player:say("Ouch! I should avoid getting hit.", 3)
      self.intro_tank_timer = timer:after(3.5, function()
        self.intro_oxygen_tank = OxygenTank:new()
        self.intro_oxygen_tank:initialize({
          y = love.graphics.getHeight() / 2,
          speed = 300,
        })
        timer:after(0.7, function()
          player:say("I better catch that spare tank..!")
        end)
      end)
    end

    if self.intro_planet:isOffScreen() then
      self.intro_planet = nil
    end
  end

  if self.intro_oxygen_tank then
    self.intro_oxygen_tank:update(dt)

    if self.intro_oxygen_tank:collidesWith(player.shape) then
      player:collectOxygen()
      oxygen_level:increase()
      self.intro_oxygen_tank = nil
      player:say("This should help a bit.", 2)
      timer:after(3, function()
        player:say("Ugh, that debris punctured my tank.\nI’ll run out of oxygen soon.", 2.5)
        timer:after(3, function()
          player:say("Where’s all my gear?\nFinding it will make this journey easier.")
          timer:after(4, function()
            controls:fade_in()
            player:endSpeech()
            jetpack = Jetpack:new()
            jetpack:initialize()

            current_game_state = game_states.level1
          end)
        end)
      end)
    end
  end

  if jetpack then
    jetpack:update(dt)

    if jetpack:is_at_x(player.x) and current_game_state == game_states.level1 then
      current_game_state = game_states.get_boost
      self:stop_oxygen_tanks()
      self:stop_planets()
      player:disable_control()
      oxygen_level:stop_decreasing()
      jetpack:stop_moving()
      player:say(
        "My jetpack! Now I can launch myself upwards.\n\n"..
        "With enough momentum, I should be able to\n"..
        "break through the debris.",
        8
      )
      player:move_to({ x = jetpack.x, y = jetpack.y }, function()
        achievement_sound:play()
        jetpack:start_circling(function()
          player:enable_control()
          player:enable_boost()
          oxygen_level:start_decreasing()
          self:start_creating_oxygen_tanks()
          self:start_creating_planets()
          self:start_creating_asteroids()

          thrusters = Thrusters:new()
          thrusters:initialize()

          current_game_state = game_states.level2
        end)
      end)
    end
  end

  if thrusters then
    thrusters:update(dt)

    if thrusters:is_at_x(player.x) and current_game_state == game_states.level2 then
      current_game_state = game_states.get_dive
      self:stop_oxygen_tanks()
      self:stop_planets()
      self:stop_asteroids()
      player:disable_control()
      oxygen_level:stop_decreasing()
      thrusters:stop_moving()
      player:say("Some fuel for my rocket thrusters!\n\nThis’ll allow me to burst forward in a pinch.")
      player:move_to({ x = thrusters.x, y = thrusters.y }, function()
        achievement_sound:play()
        thrusters:start_circling(function()
          player:endSpeech()
          player:enable_control()
          player:enable_dive()
          oxygen_level:start_decreasing()
          self:start_creating_oxygen_tanks(3)
          self:start_creating_planets()
          self:start_creating_asteroids()

          space_shuttle = SpaceShuttle:new()
          space_shuttle:initialize()

          current_game_state = game_states.level3
        end)
      end)
    end
  end

  if space_shuttle then
    space_shuttle:update(dt)

    if space_shuttle:is_at_scale(0.4) and not self.is_shuttle_in_sight then
      self.is_shuttle_in_sight = true
      player:say("Is that the shuttle?")
      timer:after(3, function()
        player:say("I’ve almost made it.")
        timer:after(3, function()
          player:say("Hang in there guys. I know you’re alright.")
          timer:after(3, function()
            player:say("I suppose I better hang in there too.")
            timer:after(3, function()
              player:endSpeech()
            end)
          end)
        end)
      end)
    end

    if space_shuttle:is_at_x(love.graphics.getWidth() / 2) and current_game_state == game_states.level3 then
      current_game_state = game_states.reach_shuttle
      self:stop_oxygen_tanks()
      self:stop_planets()
      self:stop_asteroids()
      player:disable_control()
      oxygen_level:stop_decreasing()
      space_shuttle:stop_moving()

      player:move_to({
        x = space_shuttle.x - 270,
        y = space_shuttle.y - 20,
        duration = 2,
      }, function()
        player:say("Nobodies here...?")
        self.moving_around_shuttle_timer = timer:after(3, function()
          player:endSpeech()
          player:move_to({
            x = space_shuttle.x + 50,
            y = space_shuttle.y + 150,
            duration = 3,
          }, function()
            player:say("...")
            self.moving_around_shuttle_timer = timer:after(1, function()
              player:endSpeech()
              player:move_to({
                x = space_shuttle.x + 90,
                y = space_shuttle.y,
                duration = 3,
              }, function()
                player:say("I’m all alone..?")
                space_shuttle:increase_speed()
                space_shuttle:start_moving()
                self.moving_around_shuttle_timer = timer:after(3, function()
                  player:say("I guess I’ll just keep going...")
                  player:move_to({
                    x = 150,
                    y = love.graphics.getHeight() / 2,
                    duration = 8,
                  }, function()
                    timer:after(3, function()
                      player:say("...", 3)
                    end)
                    player:enable_control()

                    oxygen_level:start_decreasing()
                    self:start_creating_oxygen_tanks(3)
                    self:start_creating_planets()
                    self:start_creating_asteroids()

                    current_game_state = game_states.neverending
                  end)
                end)
              end)
            end)
          end)
        end)
      end)
    end

    if space_shuttle:isOffScreen() then
      space_shuttle = nil
    end
  end

  for i, planet in ipairs(planets) do
    planet:update(dt)

    if planet:collidesWith(player.shape) then
      if player:onCollide(planet) then
        hit_sound:play()
        planet:onCollide()
        oxygen_level:decrease(10)
      end
    end

    if planet:isOffScreen() then
      table.remove(planets, i)
    end
  end

  for i, asteroid in ipairs(asteroids) do
    asteroid:update(dt)

    if asteroid:collidesWith(player.shape) then
      if player:onCollide(asteroid) then
        small_hit_sound:play()
        asteroid:onCollide()
        oxygen_level:decrease(8)
      end
    end

    if asteroid:isOffScreen() then
      table.remove(asteroids, i)
    end
  end

  for i, tank in ipairs(oxygen_tanks) do
    tank:update(dt)

    if tank:collidesWith(player.shape) then
      table.remove(oxygen_tanks, i)
      player:collectOxygen()
      oxygen_level:increase()
    end

    if tank:isOffScreen() then
      table.remove(oxygen_tanks, i)
    end
  end
end

function Room1:draw()
  if space_shuttle then
    space_shuttle:draw()
  end

  game_title:draw()
  player:draw()
  controls:draw()
  distance_tracker:draw()
  oxygen_level:draw()

  if self.intro_planet then
    self.intro_planet:draw()
  end

  if self.intro_oxygen_tank then
    self.intro_oxygen_tank:draw()
  end

  if jetpack then
    jetpack:draw()
  end

  if thrusters then
    thrusters:draw()
  end

  for _, planet in ipairs(planets) do
    planet:draw()
  end

  for _, asteroid in ipairs(asteroids) do
    asteroid:draw()
  end

  for _, tank in ipairs(oxygen_tanks) do
    tank:draw()
  end
end

function Room1:keypressed(key)
  player:keypressed(key)
end

function Room1:keyreleased(key)
  player:keyreleased(key)
end

function Room1:destroy()
  game_title:destroy()
  player:destroy()
  oxygen_level:destroy()

  if distance_tracker then
    distance_tracker:destroy()
    distance_tracker = nil
  end

  if controls then
    controls:destroy()
    controls = nil
  end

  if jetpack then
    jetpack:destroy()
    jetpack = nil
  end

  if thrusters then
    thrusters:destroy()
    thrusters = nil
  end

  if space_shuttle then
    space_shuttle:destroy()
    space_shuttle = nil
  end

  if self.intro_planet then
    self.intro_planet = nil
  end

  helpers.cancelTimer(self.new_planet_timer)
  helpers.cancelTimer(self.new_asteroid_timer)
  helpers.cancelTimer(self.new_oxygen_tank_timer)
  helpers.cancelTimer(self.intro_tank_timer)
  helpers.cancelTimer(self.moving_around_shuttle_timer)

  current_game_state = game_states.intro

  self.intro_started = false
  self.level1_started = false
  self.is_shuttle_in_sight = false
  total_distance = 0
  print('room1 destroyed')
end

return Room1
