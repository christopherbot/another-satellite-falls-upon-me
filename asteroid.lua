local class = require('libraries.middleclass')
local helpers = require('helpers')

local min_x = love.graphics.getWidth() / 2
local max_x = love.graphics.getWidth() * 1.5

local Asteroid = class('Asteroid')

local asteroids = {
  {
    sheet_x = 0,
    sheet_y = 224,
    diameter = 32,
    shape_diameter = 32,
  },
  {
    sheet_x = 32,
    sheet_y = 224,
    width = 64,
    height = 32,
    shape_width = 64,
    shape_height = 32,
  },
  {
    sheet_x = 96,
    sheet_y = 224,
    diameter = 32,
    shape_diameter = 26,
  },
  {
    sheet_x = 128,
    sheet_y = 224,
    diameter = 32,
    shape_diameter = 16,
  }
}

function Asteroid:initialize()
  local asteroid = asteroids[math.random(1, #asteroids)]
  self.width = asteroid.width or asteroid.diameter
  self.height = asteroid.height or asteroid.diameter
  self.shape_width = asteroid.shape_width or asteroid.shape_diameter
  self.shape_height = asteroid.shape_height or asteroid.shape_diameter
  self.x = math.random(min_x, max_x)
  self.y = -self.height
  self.angle = 0
  self.speed = math.random(100, 300)
  self.opacity = 1

  self.quad = love.graphics.newQuad(
    asteroid.sheet_x,
    asteroid.sheet_y,
    self.width,
    self.height,
    celestial_objects_sheet:getWidth(),
    celestial_objects_sheet:getHeight()
  )

  -- quack
  self.shape = asteroid.diameter and
    collider:circle(
      self.x,
      self.y,
      self.shape_width / 2
    ) or
    collider:rectangle(
      self.x,
      self.y,
      self.shape_width,
      self.shape_height
    )
end

function Asteroid:update(dt)
  self.x = self.x - dt * 2 * self.speed
  self.y = self.y + dt * self.speed - player.angle / 70

  if self.is_hit then
    self.angle = self.angle + self.speed / 20
  end

  if self.shape then
    self.shape:moveTo(self.x, self.y)
    self.shape:setRotation(math.rad(self.angle))
  end
end

function Asteroid:draw()
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

function Asteroid:fade_out(done)
  self.fade_out_timer = timer:tween(
    0.2,
    self,
    { opacity = 0 },
    'linear',
    done
  )
end

function Asteroid:isOffScreen()
  return self.x + self.width <= 0
end

function Asteroid:collidesWith(...)
  if not self.shape then return false end

  return self.shape:collidesWith(...)
end

function Asteroid:onCollide()
  -- ignore multiple hits at once
  if self.is_hit then return end

  self.is_hit = true
  collider:remove(self.shape)
  self.shape = nil
end

return Asteroid
