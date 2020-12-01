local class = require('libraries.middleclass')
local helpers = require('helpers')

local SpaceShuttle = class('SpaceShuttle')

function SpaceShuttle:initialize()
  self.width = space_shuttle_image:getWidth()
  self.height = space_shuttle_image:getHeight()
  self.x = love.graphics.getWidth() + self.width / 2
  self.y = love.graphics.getHeight() / 2
  self.speed = 14
  self.is_growing = true
  self.is_moving_towards_player = true
  self.scale = 0.05
end

function SpaceShuttle:update(dt)
  if self.is_growing then
    self.scale = math.min(self.scale + dt / 50, 1)
  end
  if self.is_moving_towards_player then
    self.x = self.x - dt * self.speed
  end
  if self.is_moving_downwards then
    self.y = self.y - dt * self.speed / 4
  end
end

function SpaceShuttle:draw()
  love.graphics.draw(
    space_shuttle_image,
    self.x,
    self.y,
    0,
    self.scale,
    self.scale,
    self.width / 2,
    self.height / 2
  )
end

function SpaceShuttle:is_at_scale(scale)
  return self.scale >= scale
end

function SpaceShuttle:is_at_x(x)
  return self.x <= x
end

function SpaceShuttle:increase_speed()
  self.speed = 50
end

function SpaceShuttle:start_moving()
  self.is_moving_towards_player = true
  self.is_moving_downwards = true
end

function SpaceShuttle:stop_moving()
  self.is_moving_towards_player = false
end

function SpaceShuttle:isOffScreen()
  return self.x + self.width <= 0
end

function SpaceShuttle:destroy()
end

return SpaceShuttle
