local class = require('libraries.middleclass')
local helpers = require('helpers')

local Player = class('Player')

local max_angle = 60
local min_x = 150
local max_x = 300
local min_y = 50
local max_y = love.graphics.getHeight() - min_y
local delta_angle = 5
local player_scale = 0.04

function Player:initialize()
  self.x = min_x
  self.y = (max_y + min_y) / 2
  self.angle = 0
end

function Player:update(dt)
  if helpers.isDirectionKeyDown('right') and self.angle < max_angle then
    self.angle = self.angle + delta_angle
  end
  if helpers.isDirectionKeyDown('left') and self.angle > -max_angle then
    self.angle = self.angle - delta_angle
  end

  -- add to x constantly, remove from x when colliding with breeze
  -- x = helpers.clamp(x + (angle / 30), min_x, max_x)
  self.y = helpers.clamp(self.y + self.angle / 5, min_y, max_y)
end

function Player:draw()
  -- love.graphics.draw(
  --   player_image,
  --   self.x,
  --   self.y,
  --   math.rad(self.angle),
  --   player_scale,
  --   player_scale,
  --   player_image:getWidth() / 2,
  --   player_image:getHeight() / 2
  -- )
end

return Player

-- local Player = {}

-- function Player.load()
--   -- player constants
--   max_angle = 60
--   min_x = 150
--   max_x = 300
--   min_y = 50
--   max_y = love.graphics.getHeight() - min_y
--   delta_angle = 5
--   player_scale = 0.04

--   -- player starting vars
--   angle = 0
--   x = min_x
--   y = (max_y + min_y) / 2
-- end

-- function Player.update(dt)
--   if helpers.isDirectionKeyDown('right') and angle < max_angle then
--     angle = angle + delta_angle
--   end
--   if helpers.isDirectionKeyDown('left') and angle > -max_angle then
--     angle = angle - delta_angle
--   end

--   -- add to x constantly, remove from x when colliding with breeze
--   -- x = helpers.clamp(x + (angle / 30), min_x, max_x)
--   y = helpers.clamp(y + angle / 5, min_y, max_y)
-- end

-- function Player.draw()
--   love.graphics.draw(
--     player_image,
--     x,
--     y,
--     math.rad(angle),
--     player_scale,
--     player_scale,
--     player_image:getWidth() / 2,
--     player_image:getHeight() / 2
--   )
-- end

-- return Player
