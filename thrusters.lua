local class = require('libraries.middleclass')
local helpers = require('helpers')

local Thrusters = class('Thrusters')

function Thrusters:initialize()
  self.width = thrusters_image:getWidth()
  self.height = thrusters_image:getHeight()
  self.x = love.graphics.getWidth() + self.width / 2
  self.y = love.graphics.getHeight() / 2
  self.speed = 40
  self.is_moving_towards_player = true
  self.circling_radius = 100
  self.circling_angle = 0
  self.is_circling = false
  self.is_visible = true
  self.is_usable = false
  self.scale = 0.2
end

function Thrusters:update(dt)
  if self.is_circling then
    self.x = self.cx + self.circling_radius * math.cos(self.circling_angle)
    self.y = self.cy + self.circling_radius * math.sin(self.circling_angle)

    self.circling_angle = self.circling_angle + math.pi * dt
  end

  if self.is_moving_towards_player then
    self.scale = math.min(self.scale + dt / 20, 1)
    self.x = self.x - dt * self.speed
  end
end

function Thrusters:draw()
  if not self.is_visible then return end

  love.graphics.draw(
    thrusters_image,
    self.x,
    self.y,
    0,
    self.scale,
    self.scale,
    self.width / 2,
    self.height / 2
  )
end

function Thrusters:is_at_x(x)
  return self.x <= x
end

function Thrusters:stop_moving()
  self.is_moving_towards_player = false
end

function Thrusters:start_circling(done)
  self.cx = self.x
  self.cy = self.y
  self.circling_timer = timer:tween(
    0.5,
    self,
    { x = self.x + self.circling_radius },
    'in-sine',
    function()
      self.is_circling = true
      self.circling_timer = timer:after(4, function()
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

function Thrusters:hide()
  self.is_visible = false
end

function Thrusters:show(x, y)
  self.cx = x
  self.cy = y
  self.is_visible = true
end

function Thrusters:destroy()
  helpers.cancelTimer(self.circling_timer)
end

return Thrusters
