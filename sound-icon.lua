local class = require('libraries.middleclass')
local helpers = require('helpers')

local SoundIcon = class('SoundIcon')

function SoundIcon:initialize()
  self.width = sound_image:getWidth()
  self.height = sound_image:getHeight()
  self.x = love.graphics.getWidth() - 60
  self.y = love.graphics.getHeight() - 80
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
    self.x,
    self.y + 40
  )
end

function SoundIcon:destroy()
end

return SoundIcon
