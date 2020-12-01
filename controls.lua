local class = require('libraries.middleclass')
local helpers = require('helpers')

local Controls = class('Controls')

function Controls:initialize()
  self.width = arrow_keys_image:getWidth()
  self.height = arrow_keys_image:getHeight()
  self.scale = 0.8
  self.x = love.graphics.getWidth() - 190
  self.y = love.graphics.getHeight() - 90
  self.is_visible = false
end

function Controls:update(dt)
end

function Controls:draw()
  if not self.is_visible then return end

  love.graphics.draw(
    arrow_keys_image,
    self.x,
    self.y,
    0,
    self.scale,
    self.scale,
    self.width / 2,
    self.height / 2
  )

  love.graphics.setFont(small_font)

  love.graphics.print(
    'Rotate',
    self.x - 110,
    self.y + 12
  )

  love.graphics.print(
    'Rotate',
    self.x + 55,
    self.y + 12
  )

  love.graphics.print(
    'Rotate',
    self.x + 55,
    self.y + 12
  )

  if player.is_boosting_enabled then
    love.graphics.print(
      'Jetpack (hold)',
      self.x - 63,
      self.y - 71
    )
  end

  if player.is_diving_enabled then
    love.graphics.print(
      'Thrust',
      self.x - 27,
      self.y + 52
    )
  end

  love.graphics.setFont(font)
end

function Controls:show()
  self.is_visible = true
end

function Controls:destroy()
end

return Controls
