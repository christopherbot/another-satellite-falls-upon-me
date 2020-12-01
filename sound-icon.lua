local class = require('libraries.middleclass')
local helpers = require('helpers')

local SoundIcon = class('SoundIcon')
local padding = 20

function SoundIcon:initialize()
  self.width = sound_image:getWidth()
  self.height = sound_image:getHeight()
  self.x = love.graphics.getWidth() - self.width - padding
  self.y = love.graphics.getHeight() - self.height - padding
end

function SoundIcon:update(dt)
end

function SoundIcon:draw()
  love.graphics.draw(
    audio_enabled and sound_image or no_sound_image,
    self.x,
    self.y
  )
  love.graphics.print(
    '[m]',
    self.x - 2 * padding,
    self.y + 5
  )
end

function SoundIcon:destroy()
end

return SoundIcon
