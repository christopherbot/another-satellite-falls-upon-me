local class = require('libraries.middleclass')
local helpers = require('helpers')

local SoundIcon = class('SoundIcon')
local padding = 20

function SoundIcon:initialize()
  self.width = sound_image:getWidth()
  self.height = sound_image:getHeight()
  self.x = love.graphics.getWidth() - padding
  self.y = love.graphics.getHeight() - padding
end

function SoundIcon:update(dt)
end

function SoundIcon:draw()
  love.graphics.draw(
    audio_enabled and sound_image or no_sound_image,
    self.x,
    self.y,
    0,
    1,
    1,
    self.width,
    self.height
  )
end

function SoundIcon:destroy()
end

return SoundIcon
