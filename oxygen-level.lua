local class = require('libraries.middleclass')
local helpers = require('helpers')

local OxygenLevel = class('OxygenLevel')

local padding_from_edge = 20
local rate_of_decrease = 4
local max_oxygen_level = 165

function OxygenLevel:initialize(options)
  -- options = options or {}
  -- self.opacity = options.opacity or 1
  self.opacity = 0
  self.image_width = tall_transparent_oxygen_tank_image:getWidth()
  self.image_height = tall_transparent_oxygen_tank_image:getHeight()
  self.image_x = padding_from_edge
  self.image_y = love.graphics.getHeight() - padding_from_edge - self.image_height
  self.level_bottom = love.graphics.getHeight() - padding_from_edge - 31
  self.level_x = self.image_x + 7
  self.level_width = 52
  self.oxygen_level = max_oxygen_level
  self.next_oxygen_level = max_oxygen_level
  self.should_decrease = false
end

function OxygenLevel:update(dt)
  if not self.should_decrease then return end

  if self.oxygen_level > 0 then
    self.oxygen_level = math.max(self.oxygen_level - dt * rate_of_decrease, 0)
  end

  if self.next_oxygen_level > 0 then
    self.next_oxygen_level = math.max(self.next_oxygen_level - dt * rate_of_decrease, 0)
  end
end

function OxygenLevel:draw()
  -- transparent background
  helpers.setColor(255, 140, 0, self.opacity * 0.15)
  love.graphics.rectangle(
    'fill',
    self.level_x,
    self.level_bottom - max_oxygen_level,
    self.level_width,
    max_oxygen_level
  )

  -- next level preview
  helpers.setColor(255, 25, 0, self.opacity)
  love.graphics.rectangle(
    'fill',
    self.level_x,
    self.level_bottom - self.next_oxygen_level,
    self.level_width,
    self.next_oxygen_level
  )

  -- current level
  helpers.setColor(255, 140, 0, self.opacity)
  love.graphics.rectangle(
    'fill',
    self.level_x,
    self.level_bottom - self.oxygen_level,
    self.level_width,
    self.oxygen_level
  )

  -- overlay the tank image on top
  helpers.setColor(255, 255, 255, self.opacity)
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

  helpers.resetColor()
end

function OxygenLevel:fade_in(duration, done)
  self.fade_in_timer = timer:tween(
    duration,
    self,
    { opacity = 1 },
    'linear',
    done
  )
end

function OxygenLevel:start_decreasing()
  self.should_decrease = true
end

function OxygenLevel:stop_decreasing()
  self.should_decrease = false
end

function OxygenLevel:increase(amount)
  amount = amount or 25
  self.increase_timer = timer:tween(
    0.05,
    self,
    { next_oxygen_level = math.min(self.next_oxygen_level + 25, max_oxygen_level) },
    'out-sine',
    function()
      self.increase_timer = timer:after(0.5, function()
        self.increase_timer = timer:tween(
          0.5,
          self,
          { oxygen_level = math.min(self.next_oxygen_level, max_oxygen_level) },
          'out-sine',
          function()
          end
        )
      end)
    end
  )
end

function OxygenLevel:decrease(amount)
  amount = amount or 25
  self.decrease_timer = timer:tween(
    0.05,
    self,
    { oxygen_level = math.max(self.oxygen_level - amount, 0) },
    'out-sine',
    function()
      self.decrease_timer = timer:after(0.5, function()
        self.decrease_timer = timer:tween(
          0.5,
          self,
          { next_oxygen_level = math.max(self.oxygen_level, 0) },
          'out-sine',
          function()
          end
        )
      end)
    end
  )
end

function OxygenLevel:destroy()
  helpers.cancelTimer(self.fade_in_timer)
  helpers.cancelTimer(self.increase_timer)
end

return OxygenLevel
