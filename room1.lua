local class = require('libraries.middleclass')
local Background = require('background')
local Player = require('player')
local Ring = require('ring')
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

  background = Background:new()
  background:initialize()

  player = Player:new()
  player:initialize()

  oxygen_level = OxygenLevel:new()
  oxygen_level:initialize()

  rings = {}
  asteroids = {}
  oxygen_tanks = {}
end

function Room1:start_creating_rings(every)
  every = every or 1
  self.new_ring_timer = timer:every(every, function()
    local ring = Ring:new()
    ring:initialize()
    table.insert(rings, ring)
  end)
end

function Room1:stop_rings()
  helpers.cancelTimer(self.new_ring_timer)
  for i, ring in ipairs(rings) do
    ring:fade_out(function()
      rings[i] = nil
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
    player:fade_in(1, function()
      oxygen_level:fade_in(1, function()
        self.intro_ring = Ring:new()
        self.intro_ring:initialize({
          y = love.graphics.getHeight() / 2,
          speed = 1500,
          -- speed = 400,
        })
      end)
    end)
  end

  if current_game_state == game_states.level1 and not self.level1_started then
    self.level1_started = true
    player:enable_control()
    oxygen_level:start_decreasing()
    self:start_creating_oxygen_tanks()
    self:start_creating_rings()
  end

  background:update(dt)
  player:update(dt)
  oxygen_level:update(dt)

  if self.intro_ring then
    self.intro_ring:update(dt)

    if self.intro_ring:collidesWith(player.shape) then
      self.intro_ring:onCollide()
      oxygen_level:decrease()
      player:onCollide()
      player:say("Ouch! I should avoid getting hit, my oxygen will run out soon.")
      self.intro_tank_timer = timer:after(0.3, function()
      -- self.intro_tank_timer = timer:after(3, function()
        self.intro_oxygen_tank = OxygenTank:new()
        self.intro_oxygen_tank:initialize({
          y = love.graphics.getHeight() / 2,
          speed = 1500,
          -- speed = 400,
        })
        player:say("Oh what's that coming this way..?")
      end)
    end

    if self.intro_ring:isOffScreen() then
      self.intro_ring = nil
    end
  end

  if self.intro_oxygen_tank then
    self.intro_oxygen_tank:update(dt)

    if self.intro_oxygen_tank:collidesWith(player.shape) then
      player:collectOxygen()
      oxygen_level:increase()
      self.intro_oxygen_tank = nil
      player:say("This should help.")
      timer:after(0.3, function()
      -- timer:after(3, function()
        player:say("I need to get to the space shuttle. Where’s all my gear?")
        timer:after(0.3, function()
        -- timer:after(3, function()
          player:endSpeech()
          jetpack = Jetpack:new()
          jetpack:initialize()

          current_game_state = game_states.level1
        end)
      end)
    end
  end

  if jetpack then
    jetpack:update(dt)

    if jetpack:is_at_x(player.x) and current_game_state == game_states.level1 then
      current_game_state = game_states.get_boost
      self:stop_oxygen_tanks()
      self:stop_rings()
      player:disable_control()
      oxygen_level:stop_decreasing()
      jetpack:stop_moving()
      player:say("My jetpack! Now I can launch myself upwards.")
      player:move_to({ x = jetpack.x, y = jetpack.y }, function()
        jetpack:start_circling(function()
          player:endSpeech()
          player:enable_control()
          player:enable_boost()
          oxygen_level:start_decreasing()
          self:start_creating_oxygen_tanks()
          self:start_creating_rings()
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
      self:stop_rings()
      self:stop_asteroids()
      player:disable_control()
      oxygen_level:stop_decreasing()
      thrusters:stop_moving()
      player:say("Some fuel for my rocket thrusters! This will help me move faster.")
      player:move_to({ x = thrusters.x, y = thrusters.y }, function()
        thrusters:start_circling(function()
          player:endSpeech()
          player:enable_control()
          player:enable_dive()
          oxygen_level:start_decreasing()
          self:start_creating_oxygen_tanks(3)
          self:start_creating_rings()
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

    if space_shuttle:is_at_scale(0.5) and not self.is_shuttle_in_sight then
      self.is_shuttle_in_sight = true
      player:say("Is that the shuttle?")
      timer:after(0.3, function()
      -- timer:after(3, function()
        player:say("I've almost made it.")
        timer:after(0.3, function()
        -- timer:after(3, function()
          player:endSpeech()
        end)
      end)
    end

    if space_shuttle:is_at_x(love.graphics.getWidth() / 2) and current_game_state == game_states.level3 then
      current_game_state = game_states.reach_shuttle
      self:stop_oxygen_tanks()
      self:stop_rings()
      self:stop_asteroids()
      player:disable_control()
      oxygen_level:stop_decreasing()
      space_shuttle:stop_moving()

      player:move_to({
        x = space_shuttle.x - 270,
        y = space_shuttle.y - 20,
        duration = 2,
      }, function()
        player:say("Nobodies here...")
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
                player:say("I guess I’ll just keep going...")
                space_shuttle:increase_speed()
                space_shuttle:start_moving()
                self.moving_around_shuttle_timer = timer:after(2, function()
                  player:say("...")
                  player:move_to({
                    x = 150,
                    y = love.graphics.getHeight() / 2,
                    duration = 8,
                  }, function()
                    player:endSpeech()
                    player:enable_control()

                    oxygen_level:start_decreasing()
                    self:start_creating_oxygen_tanks(3)
                    self:start_creating_rings()
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

  for i, ring in ipairs(rings) do
    ring:update(dt)

    if ring:collidesWith(player.shape) then
      if player:onCollide() then
        ring:onCollide()
        oxygen_level:decrease(10)
      end
    end

    if ring:isOffScreen() then
      table.remove(rings, i)
    end
  end

  for i, asteroid in ipairs(asteroids) do
    asteroid:update(dt)

    if asteroid:collidesWith(player.shape) then
      if player:onCollide() then
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
  background:draw()

  if space_shuttle then
    space_shuttle:draw()
  end

  player:draw()
  oxygen_level:draw()

  if self.intro_ring then
    self.intro_ring:draw()
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

  for _, ring in ipairs(rings) do
    ring:draw()
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
  player:destroy()
  oxygen_level:destroy()

  if jetpack then
    jetpack:destroy()
    jetpack = nil
  end

  if thrusters then
    thrusters:destroy()
    thrusters = nil
  end

  if self.intro_ring then
    self.intro_ring = nil
  end

  helpers.cancelTimer(self.new_ring_timer)
  helpers.cancelTimer(self.new_asteroid_timer)
  helpers.cancelTimer(self.new_oxygen_tank_timer)
  helpers.cancelTimer(self.intro_tank_timer)
  helpers.cancelTimer(self.moving_around_shuttle_timer)

  current_game_state = game_states.intro

  self.intro_started = false
  self.level1_started = false
  self.is_shuttle_in_sight = false
  print('room1 destroyed')
end

return Room1
