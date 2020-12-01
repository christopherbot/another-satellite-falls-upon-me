local class = require('libraries.middleclass')
local helpers = require('helpers')

local min_y = 0
local max_y = love.graphics.getHeight()

local Planet = class('Planet')

function Planet:initialize(options)
  self.options = options or {}
  self.width = 64
  self.height = 64
  self.x = love.graphics.getWidth() + self.width / 2
  self.y = self.options.y or math.random(min_y, max_y)
  self.angle = 0
  self.speed = self.options.speed or math.random(100, 350)
  self.opacity = 1

  -- celestial_objects_sheet has a 4x3 grid of
  -- 64x64 planets, so pick one at random:
  self.quad = love.graphics.newQuad(
    self.width * math.random(0, 3),
    self.height * math.random(0, 2),
    self.width,
    self.height,
    celestial_objects_sheet:getWidth(),
    celestial_objects_sheet:getHeight()
  )

  self.shape = collider:circle(
    self.x,
    self.y,
    self.width / 2
  )
end

function Planet:update(dt)
  self.x = self.x - dt * self.speed
  self.y = self.y - player.angle / 70

  if self.is_hit then
    self.angle = self.angle + self.speed / 20
  end

  if self.shape then
    self.shape:moveTo(self.x, self.y)
    self.shape:setRotation(math.rad(self.angle))
  end
end

function Planet:draw()
  if self.shape then
    self.shape:draw('line')
  end

  helpers.setColor(255, 255, 255, self.opacity)
  love.graphics.draw(
    celestial_objects_sheet,
    self.quad,
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

function Planet:fade_out(done)
  self.fade_out_timer = timer:tween(
    0.2,
    self,
    { opacity = 0 },
    'linear',
    done
  )
end

function Planet:isOffScreen()
  return self.x + self.width <= 0
end

function Planet:collidesWith(...)
  if not self.shape then return false end

  return self.shape:collidesWith(...)
end

function Planet:onCollide()
  -- ignore multiple hits at once
  if self.is_hit then return end

  self.is_hit = true
  collider:remove(self.shape)
  self.shape = nil
end

return Planet
