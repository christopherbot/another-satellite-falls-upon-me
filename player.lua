local class = require('libraries.middleclass')
local helpers = require('helpers')

local Player = class('Player')

local max_angle = 50
local player_x = 150
local min_y = 50
local max_y = love.graphics.getHeight() - min_y
local delta_angle = 3
local player_scale = 0.1
local deg_per_y = 7
local boost_angle_correction_duration = 0.15
local max_boost_charge_duration = 1
local boost_distance_charge_rate = (max_y - min_y) / 2
local dive_duration = 0.4
local dive_distance_rate = 15
local dive_cooldown_duration = 1
local shape_size_adj = 25
local shape_y_adj = 15
local powerful_boost_amount = 200

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
  self.image_without_fire = love.graphics.newImage(astronaut_without_fire_image_data)
  self.image_with_fire = love.graphics.newImage(astronaut_with_fire_image_data)
  self.image = self.image_without_fire

  local brightened_image_without_fire_data = astronaut_without_fire_image_data:clone()
  local brightened_image_with_fire_data = astronaut_with_fire_image_data:clone()
  brightened_image_without_fire_data:mapPixel(helpers.brightenImage)
  brightened_image_with_fire_data:mapPixel(helpers.brightenImage)

  self.brightened_image_without_fire = love.graphics.newImage(brightened_image_without_fire_data)
  self.brightened_image_with_fire = love.graphics.newImage(brightened_image_with_fire_data)
  self.brightened_image = self.brightened_image_without_fire

  self.current_image = self.image_without_fire

  self.width = self.current_image:getWidth()
  self.height = self.current_image:getHeight()
  self.x = -self.width * player_scale / 2
  self.y = (max_y + min_y) / 2 + 35
  self.angle = 0

  -- TODO use polygon to improve hit box
  self.shape = collider:rectangle(
    self.x,
    self.y,
    self.width * player_scale,
    self.height * player_scale - shape_size_adj
  )

  self.is_boosting_enabled = false
  self.boost_distance = 0
  self.boost_state = boost_states.idle

  self.is_diving_enabled = false
  self.dive_state = dive_states.idle

  self.is_hit = false
  self.is_invincible = false

  self.has_control = false
end

function Player:fade_in(duration, done)
  self.fade_in_timer = timer:tween(
    duration,
    self,
    { x = player_x },
    'linear',
    function()
      if self.shape then
        self.shape:moveTo(self.x, self.y - shape_y_adj)
        done()
      end
    end
  )
end

function Player:update(dt)
  if not self.has_control then return end

  local next_y

  if not self.is_hit then
    if
      self.is_boosting_enabled and
      self.boost_state == boost_states.idle and
      helpers.isDirectionKeyDown('up')
    then
      jetpack:show()
      self.boost_state = boost_states.charging
      self.boost_angle_correction_tween = timer:tween(
        boost_angle_correction_duration,
        self,
        { angle = 0 },
        'in-cubic',
        function()
        end
      )
      self.boost_charging_timer = timer:after(max_boost_charge_duration, function()
        jetpack:hide()
        self.boost_state = boost_states.done_charging
      end)
    end

    if self.boost_state == boost_states.charging and helpers.isDirectionKeyDown('up') then
      self.boost_distance = self.boost_distance + dt * boost_distance_charge_rate
    end

    if self.boost_state == boost_states.done_charging then
      self.boost_state = boost_states.boosting
      self.boosting_timer = timer:tween(
        0.15,
        self,
        { y = self.y - self.boost_distance },
        'in-cubic',
        function()
          -- TODO cooldown animation? maybe near keyboard image?
          self.boost_state = boost_states.cooldown
          local prev_boost_distance = self.boost_distance
          self.boost_distance = 0
          timer:after(prev_boost_distance / 100, function()
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
    next_y = self.y + self.angle * 0.4
  elseif self.dive_state == dive_states.returning then
    if not self.dive_returning_timer then
      self.dive_returning_timer = timer:tween(
        dive_cooldown_duration,
        self,
        { x = player_x },
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
    next_x = player_x
    next_y = self.y + self.angle / deg_per_y
  end

  if next_x and not self.diving_tween_timer and not self.dive_returning_timer then
    self.x = next_x
  end
  if next_y then
    self.y = helpers.clamp(next_y, min_y, max_y)
  end

  if self.shape then
    self.shape:moveTo(self.x, self.y - shape_y_adj)
    self.shape:setRotation(math.rad(self.angle))
  end
end

function Player:draw()
  if self.shape then
    self.shape:draw('line')
  end

  if self.boost_distance >= powerful_boost_amount then
    helpers.setColor(245, 170, 60, 1)
  end

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

  if self.boost_distance >= powerful_boost_amount then
    helpers.resetColor()
  end

  if self.text then
    love.graphics.print(
      self.text,
      self.x + (self.width * player_scale / 2),
      self.y - (self.height * player_scale / 2)
    )
  elseif self.is_hit then
    love.graphics.print(
      self.ouch_string,
      self.x + (self.width * player_scale / 2),
      self.y - (self.height * player_scale / 2)
    )
  end

  if self.boost_state == boost_states.charging then
    love.graphics.setLineStyle('smooth')
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
    self:enable_rocket_fire()

    self.diving_timer = timer:after(dive_duration, function()
      self.dive_state = dive_states.returning

      timer:after(dive_cooldown_duration, function()
        self.dive_state = dive_states.cooldown
        self:disable_rocket_fire()

        timer:after(dive_cooldown_duration, function()
          self.dive_state = dive_states.idle
        end)
      end)
    end)
  end
end

function Player:enable_rocket_fire()
  self.image = self.image_with_fire
  self.brightened_image = self.brightened_image_with_fire
  self.current_image = self.image
end

function Player:disable_rocket_fire()
  self.image = self.image_without_fire
  self.brightened_image = self.brightened_image_without_fire
  self.current_image = self.image
end

function Player:keyreleased(key)
  if helpers.isDirectionKey('up', key) and self.boost_state == boost_states.charging then
    timer:cancel(self.boost_charging_timer)
    jetpack:hide()
    self.boost_state = boost_states.done_charging
  end
end

function Player:enable_control()
  self.has_control = true
end

function Player:disable_control()
  self.has_control = false
  self.disabling_control_timer = timer:tween(
    0.1,
    self,
    { angle = 0 },
    'out-sine',
    function() end
  )
end

function Player:collidesWith(...)
  if self.shape then return false end

  return self.shape:collidesWith(...)
end

function Player:onCollide(collided_object)
  if self.boost_distance >= powerful_boost_amount and collided_object.fade_out then
    collided_object:fade_out()
    return true
  end

  -- ignore multiple hits at once and add short invincibility
  if self.is_hit or self.is_invincible then return false end

  self.is_hit = true
  self.is_invincible = true
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
      self.current_image = self.brightened_image

      self.hit_timer = timer:every(
        delay * 2,
        function()
          self.current_image =
            self.current_image == self.image and
            self.brightened_image or
            self.image
        end,
        count / 2,
        function()
          self.current_image = self.image
          self.is_invincible = false
        end
      )
    end
  )

  if self.boost_state == boost_states.charging then
    timer:cancel(self.boost_charging_timer)
    jetpack:hide()
    self.boost_distance = 0
    self.boost_state = boost_states.idle
  elseif self.boost_state == boost_states.boosting and self.boost_distance < powerful_boost_amount then
    timer:cancel(self.boosting_timer)
    self.boost_distance = 0
    self.boost_state = boost_states.idle
  end

  if self.dive_state == dive_states.diving then
    timer:cancel(self.diving_timer)
    self.dive_state = dive_states.returning
    self:disable_rocket_fire()
  end

  timer:tween(
    delay * count,
    self,
    { angle = 0 },
    'out-elastic',
    function()
    end
  )

  return true
end

function Player:move_to(options, done)
  self.move_to_timer = timer:tween(
    options.duration or 1,
    self,
    {
      x = options.x,
      y = options.y,
    },
    'out-sine',
    done
  )
end

function Player:collectOxygen()
end

function Player:enable_boost()
  self.is_boosting_enabled = true
end

function Player:enable_dive()
  self.is_diving_enabled = true
end

function Player:say(text, duration)
  self.text = text
  if duration then
    self.text_timer = timer:after(duration, function()
      self.text = nil
    end)
  end
end

function Player:endSpeech()
  self.text = nil
end

function Player:destroy()
  helpers.cancelTimer(self.fade_in_timer)
  helpers.cancelTimer(self.boost_angle_correction_tween)
  helpers.cancelTimer(self.boost_charging_timer)
  helpers.cancelTimer(self.boosting_timer)
  helpers.cancelTimer(self.dive_returning_timer)
  helpers.cancelTimer(self.diving_timer)
  helpers.cancelTimer(self.hit_timer)
  helpers.cancelTimer(self.text_timer)
  helpers.cancelTimer(self.move_to_timer)
  helpers.cancelTimer(self.disabling_control_timer)
  self:endSpeech()
end

return Player
