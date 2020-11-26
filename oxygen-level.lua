local class = require('libraries.middleclass')
local helpers = require('helpers')

local OxygenLevel = class('OxygenLevel')

local padding_from_edge = 20
local rate_of_decrease = 4
local max_oxygen_level = 165

function OxygenLevel:initialize(x, y, speed)
  self.image_width = tall_transparent_oxygen_tank_image:getWidth()
  self.image_height = tall_transparent_oxygen_tank_image:getHeight()
  self.image_x = padding_from_edge
  self.image_y = love.graphics.getHeight() - padding_from_edge - self.image_height
  self.level_bottom = love.graphics.getHeight() - padding_from_edge - 31
  self.level_x = self.image_x + 7
  self.level_width = 52
  self.oxygen_level = max_oxygen_level
  self.next_oxygen_level = max_oxygen_level
end

function OxygenLevel:update(dt)
  if self.oxygen_level > 0 then
    self.oxygen_level = math.max(self.oxygen_level - dt * rate_of_decrease, 0)
  end

  if self.next_oxygen_level > 0 then
    self.next_oxygen_level = math.max(self.next_oxygen_level - dt * rate_of_decrease, 0)
  end
end

function OxygenLevel:draw()
  -- transparent background
  helpers.setColor(255, 140, 0, 40)
  love.graphics.rectangle(
    'fill',
    self.level_x,
    self.level_bottom - max_oxygen_level,
    self.level_width,
    max_oxygen_level
  )

  -- next level preview
  helpers.setColor(255, 25, 0)
  love.graphics.rectangle(
    'fill',
    self.level_x,
    self.level_bottom - self.next_oxygen_level,
    self.level_width,
    self.next_oxygen_level
  )

  -- current level
  helpers.setColor(255, 140, 0)
  love.graphics.rectangle(
    'fill',
    self.level_x,
    self.level_bottom - self.oxygen_level,
    self.level_width,
    self.oxygen_level
  )
  helpers.resetColor()

  -- overlay the tank image on top
  love.graphics.draw(
    tall_transparent_oxygen_tank_image,
    self.image_x,
    self.image_y
    -- math.rad(self.angle),
    -- 1,
    -- 1,
    -- self.width / 2,
    -- self.height / 2
  )
end

function OxygenLevel:increase(level)
  timer:tween(
    0.05,
    self,
    { next_oxygen_level = math.min(self.next_oxygen_level + 25, max_oxygen_level) },
    'out-sine',
    function()
      timer:after(0.5, function()
        timer:tween(
          0.5,
          self,
          { oxygen_level = math.min(self.next_oxygen_level, max_oxygen_level) },
          'out-sine',
          function()
            -- print('done increasing oxygen')
          end
        )
      end)
    end
  )
end

return OxygenLevel
