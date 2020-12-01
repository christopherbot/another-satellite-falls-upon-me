local class = require('libraries.middleclass')
local helpers = require('helpers')

local Jetpack = class('Jetpack')

function Jetpack:initialize()
  self.width = jetpack_image:getWidth()
  self.height = jetpack_image:getHeight()
  self.x = love.graphics.getWidth() + self.width / 2
  self.y = love.graphics.getHeight() / 2
  self.speed = 1000 -- 80
  self.is_moving_towards_player = true
  self.circling_radius = 100
  self.circling_angle = 0
  self.is_circling = false
  self.is_visible = true
  self.is_usable = false
  self.scale = 0.2
end

function Jetpack:update(dt)
  if self.is_circling then
    self.cx = player.x
    self.cy = player.y
    self.x = self.cx + self.circling_radius * math.cos(self.circling_angle)
    self.y = self.cy + self.circling_radius * math.sin(self.circling_angle)

    self.circling_angle = self.circling_angle + math.pi * dt
  end

  if self.is_moving_towards_player then
    self.scale = math.min(self.scale + dt / 5, 1)
    self.x = self.x - dt * self.speed
  end
end

function Jetpack:draw()
  if not self.is_visible then return end

  love.graphics.draw(
    jetpack_image,
    self.x,
    self.y,
    0,
    self.scale,
    self.scale,
    self.width / 2,
    self.height / 2
  )
end

function Jetpack:is_at_x(x)
  return self.x <= x
end

function Jetpack:stop_moving()
  self.is_moving_towards_player = false
end

function Jetpack:start_circling(done)
  self.cx = self.x
  self.cy = self.y
  self.circling_timer = timer:tween(
    0.5,
    self,
    { x = self.x + self.circling_radius },
    'in-sine',
    function()
      self.is_circling = true
      self.circling_timer = timer:after(0.4, function()
      -- self.circling_timer = timer:after(4, function()
        self.is_circling = false
        self.circling_timer = timer:tween(
          0.5,
          self,
          { x = self.x - self.circling_radius },
          'in-sine',
          function()
            self.is_circling = true
            self.is_visible = false
            self.is_usable = true
            self.circling_radius = 50
            done()
          end
        )
      end)
    end
  )
end

function Jetpack:hide()
  self.is_visible = false
end

function Jetpack:show()
  self.is_visible = true
end

function Jetpack:destroy()
  helpers.cancelTimer(self.circling_timer)
end

return Jetpack
