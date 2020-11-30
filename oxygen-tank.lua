local class = require('libraries.middleclass')
local helpers = require('helpers')

local min_y = 150
local max_y = love.graphics.getHeight() - min_y

local OxygenTank = class('OxygenTank')

function OxygenTank:initialize(options)
  self.options = options or {}
  self.width = oxygen_tank_image:getWidth()
  self.height = oxygen_tank_image:getHeight()
  self.x = love.graphics.getWidth() + self.width / 2
  self.y = self.options.y or math.random(min_y, max_y)
  self.angle = math.random(0, 359)
  self.speed = self.options.speed or math.random(50, 200)
  self.opacity = 1

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

  if self.shape then
    self.shape:moveTo(self.x, self.y)
    self.shape:setRotation(math.rad(self.angle))
  end
end

function OxygenTank:draw()
  if self.shape then
    self.shape:draw('line')
  end

  helpers.setColor(255, 255, 255, self.opacity)
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
  helpers.resetColor()
end

function OxygenTank:fade_out(done)
  self.fade_out_timer = timer:tween(
    0.2,
    self,
    { opacity = 0 },
    'linear',
    done
  )
end

function OxygenTank:isOffScreen()
  return self.x + self.width <= 0
end

function OxygenTank:collidesWith(...)
  if not self.shape then return false end

  return self.shape:collidesWith(...)
end

function OxygenTank:onCollide(removeTank)
  -- ignore multiple hits at once
  if self.is_hit then return end

  -- timer:after(1, function() removeTank() end)
  self.is_hit = true
end

return OxygenTank
