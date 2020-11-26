local class = require('libraries.middleclass')
local Background = require('background')
local Player = require('player')
local Player2 = require('player2')
local Ring = require('ring')
local Asteroid = require('asteroid')
local OxygenTank = require('oxygen-tank')
local OxygenLevel = require('oxygen-level')
local helpers = require('helpers')

local Room1 = class('Player')

function Room1:initialize()
  print('room1 initialized')
  collider = HC(100)

  name = 'joe'

  background = Background:new()
  background:initialize()

  player = Player:new()
  player:initialize()

  player2 = Player2:new()
  player2:initialize()

  oxygen_level = OxygenLevel:new()
  oxygen_level:initialize()

  rings = {}
  self.new_ring_timer = timer:every(1, function()
    -- print('new ring')
    local ring = Ring:new()
    ring:initialize()
    table.insert(rings, ring)
  end)

  asteroids = {}
  self.new_asteroid_timer = timer:every(1, function()
    -- print('new asteroid')
    local asteroid = Asteroid:new()
    asteroid:initialize()
    table.insert(asteroids, asteroid)
  end)

  oxygen_tanks = {}
  self.new_oxygen_tank_timer = timer:every(1, function()
    -- print('new tank')
    local oxygen_tank = OxygenTank:new()
    oxygen_tank:initialize()
    table.insert(oxygen_tanks, oxygen_tank)
  end)
end

function Room1:update(dt)
  -- collider:update(dt)
  background:update(dt)
  player:update(dt)
  player2:update(dt)
  oxygen_level:update(dt)

  for i, ring in ipairs(rings) do
    ring:update(dt)

    if ring:isOffScreen() then
      table.remove(rings, i)
    end

    if ring.shape:collidesWith(player2.shape) then
      ring:onCollide()
      player2:onCollide()
    end
  end

  for i, asteroid in ipairs(asteroids) do
    asteroid:update(dt)

    if asteroid:isOffScreen() then
      table.remove(asteroids, i)
    end

    if asteroid.shape:collidesWith(player2.shape) then
      asteroid:onCollide()
      player2:onCollide()
    end
  end

  for i, tank in ipairs(oxygen_tanks) do
    tank:update(dt)

    if tank:isOffScreen() then
      table.remove(oxygen_tanks, i)
    end

    if tank.shape:collidesWith(player2.shape) then
      -- tank:onCollide(function()
      --   table.remove(oxygen_tanks, i)
      -- end)
      table.remove(oxygen_tanks, i)
      player2:collectOxygen()
      oxygen_level:increase()
    end
  end
end

function Room1:draw()
  background:draw()
  love.graphics.print('Welcome to room 1, '..name..'.', 100, 100)
  player:draw()
  player2:draw()
  oxygen_level:draw()

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
  player2:keypressed(key)
end

function Room1:keyreleased(key)
  player2:keyreleased(key)
end

function Room1:destroy()
  timer:cancel(self.new_ring_timer)
  timer:cancel(self.new_asteroid_timer)
  timer:cancel(self.new_oxygen_tank_timer)
  print('room1 destroyed')
end

return Room1
