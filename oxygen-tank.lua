local class = require('libraries.middleclass')
local helpers = require('helpers')

local min_y = 150
local max_y = love.graphics.getHeight() - min_y

local OxygenTank = class('OxygenTank')

function OxygenTank:initialize(x, y, speed)
  self.width = oxygen_tank_image:getWidth()
  self.height = oxygen_tank_image:getHeight()
  self.x = love.graphics.getWidth() + self.width / 2
  self.y = math.random(min_y, max_y)
  self.angle = math.random(0, 359)
  self.speed = math.random(50, 200)

  -- todo better hitbox
  self.shape = collider:rectangle(
    self.x,
    self.y,
    self.width,
    self.height
  )
end

function OxygenTank:update(dt)
  self.x = self.x - dt * self.speed
  self.y = self.y - player.angle / 70
  self.angle = self.angle + self.speed / 500

  if self.is_hit then
    self.angle = self.angle + self.speed / 100
  end

  self.shape:moveTo(self.x, self.y)
  self.shape:setRotation(math.rad(self.angle))
end

function OxygenTank:draw()
  self.shape:draw('line')
  love.graphics.draw(
    oxygen_tank_image,
    self.x,
    self.y,
    math.rad(self.angle),
    1,
    1,
    self.width / 2,
    self.height / 2
  )
end

function OxygenTank:isOffScreen()
  return self.x + self.width <= 0
end

function OxygenTank:onCollide(removeTank)
  -- ignore multiple hits at once
  if self.is_hit then return end

  -- timer:after(1, function() removeTank() end)
  self.is_hit = true
end

return OxygenTank
