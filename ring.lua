local class = require('libraries.middleclass')
local helpers = require('helpers')

local min_y = 150
local max_y = love.graphics.getHeight() - min_y

local Ring = class('Ring')

function Ring:initialize(x, y, speed)
  self.width = 64
  self.height = 64
  self.x = love.graphics.getWidth() + self.width / 2
  self.y = math.random(min_y, max_y)
  self.angle = 0
  self.speed = math.random(100, 300)

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

function Ring:update(dt)
  self.x = self.x - dt * self.speed
  self.y = self.y - player.angle / 70

  if self.is_hit then
    self.angle = self.angle + self.speed / 20
  end

  self.shape:moveTo(self.x, self.y)
  self.shape:setRotation(math.rad(self.angle))
end

function Ring:draw()
  self.shape:draw('line')
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
end

function Ring:isOffScreen()
  return self.x + self.width <= 0
end

function Ring:onCollide()
  -- ignore multiple hits at once
  if self.is_hit then return end

  -- print('ring collide!')
  self.is_hit = true
end

return Ring
