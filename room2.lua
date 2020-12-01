local class = require('libraries.middleclass')
local Player = require('player')
local SpaceShuttle = require('space-shuttle')

local Room2 = class('Room2')

function Room2:initialize()
  print('room2 initialized')

  _player = Player:new()
  _player:initialize()

  _space_shuttle = SpaceShuttle:new()
  _space_shuttle:initialize()
end

function Room2:update(dt)
  _player:update(dt)

  if _space_shuttle:is_at_x(love.graphics.getWidth() / 2) and not self.stopped then
    self.stopped = true
    _space_shuttle:stop_moving()
    -- _player:move_to({
    --   x = _space_shuttle.x - 100,
    --   y = _space_shuttle.y - 20,
    -- })
    _player.x = _space_shuttle.x + 90
    _player.y = _space_shuttle.y
    _player:say("Nobodies here...")
  end
  _space_shuttle:update(dt)
end

function Room2:draw()
  love.graphics.print('Demo Room', 50, 50)
  _space_shuttle:draw()
  _player:draw()
end

function Room2:destroy()
  print('room2 destroyed')
end

return Room2
