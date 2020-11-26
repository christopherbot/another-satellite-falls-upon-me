local class = require('libraries.middleclass')
local helpers = require('helpers')

local Player = class('Player')

local max_angle = 50
local starting_x = 150
-- local max_x = 300
local min_y = 50
local max_y = love.graphics.getHeight() - min_y
local delta_angle = 3
local player_scale = 0.1
-- local player_scale = 1
local deg_per_y = 7
local boost_angle_correction_duration = 0.15
local max_boost_charge_duration = 1
local boost_distance_charge_rate = (max_y - min_y) / 2
local dive_duration = 0.4
local dive_distance_rate = 15
local dive_cooldown_duration = 1
local boost_states = {
  idle = 'idle',
  charging = 'charging',
  done_charging = 'done_charging',
  boosting = 'boosting',
  cooldown = 'cooldown',
}
local dive_states = {
  idle = 'idle',
  diving = 'diving',
  returning = 'returning',
  cooldown = 'cooldown',
}

function Player:initialize()
  self.image = love.graphics.newImage(astronaut_image_data)
  local brightened_image_data = astronaut_image_data:clone()
  brightened_image_data:mapPixel(helpers.brightenImage)
  self.brightened_image = love.graphics.newImage(brightened_image_data)
  self.current_image = self.image

  self.x = starting_x
  self.y = (max_y + min_y) / 2
  self.width = self.current_image:getWidth()
  self.height = self.current_image:getHeight()
  self.angle = 0

  -- TODO use polygon to improve hit box
  self.shape = collider:rectangle(
    self.x,
    self.y,
    self.width * player_scale,
    self.height * player_scale
  )

  self.is_boosting_enabled = true
  self.boost_distance = 0
  self.boost_state = boost_states.idle

  self.is_diving_enabled = true
  self.dive_state = dive_states.idle

  self.is_hit = false
end

function Player:update(dt)
  local next_y

  if not self.is_hit then
    if
      self.is_boosting_enabled and
      self.boost_state == boost_states.idle and
      helpers.isDirectionKeyDown('up')
    then
      -- print('holding "up", correcting angle and charging boost...')
      self.boost_state = boost_states.charging
      self.boost_angle_correction_tween = timer:tween(
        boost_angle_correction_duration,
        self,
        { angle = 0 },
        'in-cubic',
        function()
          -- print('done angle correction')
        end
      )
      self.boost_charging_timer = timer:after(max_boost_charge_duration, function()
        -- print('boost_charging_timer done')
        self.boost_state = boost_states.done_charging
      end)
    end

    if self.boost_state == boost_states.charging and helpers.isDirectionKeyDown('up') then
      self.boost_distance = self.boost_distance + dt * boost_distance_charge_rate
      -- print('boost_distance', self.boost_distance)
    end

    if self.boost_state == boost_states.done_charging then
      self.boost_state = boost_states.boosting
      -- print('boosting')
      self.boosting_timer = timer:tween(
        0.15,
        self,
        { y = self.y - self.boost_distance },
        'in-cubic',
        function()
          -- print('done boosting')
          self.boost_state = boost_states.cooldown
          timer:after(self.boost_distance / 100, function()
            self.boost_distance = 0
            self.boost_state = boost_states.idle
          end)
        end
      )
    end

    if
      (self.boost_state == boost_states.idle or self.boost_state == boost_states.cooldown) and
      (
        self.dive_state == dive_states.idle or
        self.dive_state == dive_states.returning or
        self.dive_state == dive_states.cooldown
      ) and
      helpers.isDirectionKeyDown('right') and
      self.angle < max_angle
    then
      self.angle = math.min(self.angle + delta_angle, max_angle)
    end

    if
      (self.boost_state == boost_states.idle or self.boost_state == boost_states.cooldown) and
      (
        self.dive_state == dive_states.idle or
        self.dive_state == dive_states.returning or
        self.dive_state == dive_states.cooldown
      ) and
      helpers.isDirectionKeyDown('left') and
      self.angle > -max_angle
    then
        self.angle = math.max(self.angle - delta_angle, -max_angle)
    end
  end

  if self.boost_state == boost_states.charging and helpers.round(self.angle) == 0 then
    -- shoddy shake effect
    local shake_distance = 0.5
    if self.boost_distance > 210 then
      shake_distance = 6
    elseif self.boost_distance > 140 then
      shake_distance = 3
    elseif self.boost_distance > 70 then
      shake_distance = 1
    end

    next_y = self.y + math.random(-shake_distance, shake_distance)
    next_x = self.x + math.random(-shake_distance, shake_distance)
  elseif self.dive_state == dive_states.diving then
    next_x = self.x + dive_distance_rate
    -- if not self.diving_tween_timer then
    --   self.diving_tween_timer = timer:tween(
    --     dive_duration,
    --     self,
    --     { x = 400 },
    --     'out-sine',
    --     function()
    --       self.diving_tween_timer = nil
    --     end
    --   )
    -- end
    next_y = self.y + self.angle * 0.4
  elseif self.dive_state == dive_states.returning then
    if not self.dive_returning_timer then
      self.dive_returning_timer = timer:tween(
        dive_cooldown_duration,
        self,
        { x = starting_x },
        'in-cubic',
        function()
          self.dive_returning_timer = nil

          -- Set idle here in case the normal state
          -- flow gets interrupted by a collision
          self.dive_state = dive_states.idle
        end
      )
    end
    next_y = self.y + self.angle / deg_per_y
  else
    next_x = starting_x
    next_y = self.y + self.angle / deg_per_y
  end

  -- if next_x and not self.dive_returning_timer then
  if next_x and not self.diving_tween_timer and not self.dive_returning_timer then
    self.x = next_x
  end
  if next_y then
    self.y = helpers.clamp(next_y, min_y, max_y)
  end

  -- add to x constantly, remove from x when colliding with breeze
  -- x = helpers.clamp(x + (angle / 30), starting_x, max_x)

  self.shape:moveTo(self.x, self.y)
  self.shape:setRotation(math.rad(self.angle))
end

function Player:draw()
  -- outline for debugging:
  self.shape:draw('line')

  love.graphics.draw(
    self.current_image,
    self.x,
    self.y,
    math.rad(self.angle),
    player_scale,
    player_scale,
    self.width / 2,
    self.height / 2
  )

  if self.is_hit then
    love.graphics.print(
      self.ouch_string,
      self.x + (self.width * player_scale / 2),
      self.y - (self.height * player_scale / 2)
    )
  end

  if self.boost_state == boost_states.charging then
    love.graphics.setLineStyle('smooth')
    -- love.graphics.setColor()
    love.graphics.line(
      self.x,
      self.y,
      self.x,
      self.y - self.boost_distance
    )
  end
end

function Player:keypressed(key)
  if
    self.is_diving_enabled and
    self.dive_state == dive_states.idle and
    helpers.isDirectionKey('down', key)
  then
    self.dive_state = dive_states.diving
    self.diving_timer = timer:after(dive_duration, function()
      self.dive_state = dive_states.returning

      timer:after(dive_cooldown_duration, function()
        self.dive_state = dive_states.cooldown

        timer:after(dive_cooldown_duration, function()
          self.dive_state = dive_states.idle
        end)
      end)
    end)
  end
end

function Player:keyreleased(key)
  if helpers.isDirectionKey('up', key) and self.boost_state == boost_states.charging then
    timer:cancel(self.boost_charging_timer)
    self.boost_state = boost_states.done_charging
  end
end

function Player:onCollide()
  -- ignore multiple hits at once
  if self.is_hit then return end

  self.is_hit = true
  self.ouch_string = helpers.randomizeCapitalization('ouch')

  local delay = 0.1
  local count = 8 -- i.e. 4 flashes
  self.hit_timer = timer:every(
    delay,
    function()
      self.current_image =
        self.current_image == self.image and
        self.brightened_image or
        self.image
    end,
    count,
    function()
      self.is_hit = false
    end
  )

  if self.boost_state == boost_states.charging then
    timer:cancel(self.boost_charging_timer)
    self.boost_state = boost_states.idle
  elseif self.boost_state == boost_states.boosting then
    timer:cancel(self.boosting_timer)
    self.boost_distance = 0
    self.boost_state = boost_states.idle
  end

  if self.dive_state == dive_states.diving then
    timer:cancel(self.diving_timer)
    self.dive_state = dive_states.returning
  end

  timer:tween(
    delay * count,
    self,
    { angle = 0 },
    'out-elastic',
    function()
      -- print('Player regained control!')
    end
  )
end

function Player:collectOxygen()
end

return Player
