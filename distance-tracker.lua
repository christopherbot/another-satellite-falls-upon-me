local class = require('libraries.middleclass')
local helpers = require('helpers')

local DistanceTracker = class('DistanceTracker')

function DistanceTracker:initialize()
  self.width = measuring_tape_image:getWidth()
  self.height = measuring_tape_image:getHeight()
  self.x = love.graphics.getWidth() - 130
  self.y = love.graphics.getHeight() - 80
  self.opacity = 0
end

function DistanceTracker:update(dt)
end

function DistanceTracker:draw()
  helpers.setColor(255, 255, 255, self.opacity)

  love.graphics.draw(
    measuring_tape_image,
    self.x,
    self.y
  )

  if total_distance then
    local text_width = font:getWidth(math.floor(total_distance))
    love.graphics.print(
      math.floor(total_distance),
      self.x + self.width / 2,
      self.y + 42,
      0,
      1,
      1,
      text_width / 2
    )
  end

  helpers.resetColor()
end

function DistanceTracker:fade_in()
  self.fade_in_timer = timer:tween(
    1,
    self,
    { opacity = 1 },
    'linear'
  )
end

function DistanceTracker:destroy()
  helpers.cancelTimer(self.fade_in_timer)
end

return DistanceTracker
