local class = require('libraries.middleclass')
local helpers = require('helpers')

local GameTitle = class('GameTitle')

function GameTitle:initialize()
  self.x = love.graphics.getWidth() / 2
  self.y = 40
  self.flicker_1 = false
  self.flicker_2 = false
  self.current_text = GAME_TITLE
end

function GameTitle:update(dt)
  if not self.flicker_1 and current_game_state == game_states.level1 then
    self.flicker_1 = true

    self.flicker_timer_1 = timer:every({ 0.5, 5 }, function()
      self.current_text = GAME_TITLE_ALT_1
      self.reset_timer_1 = timer:after({ 0.1, 0.5 }, function()
        self.current_text = GAME_TITLE
      end)
    end)
  end

  if not self.flicker_2 and current_game_state == game_states.reach_shuttle then
    helpers.cancelTimer(self.flicker_timer_1)
    self.flicker_2 = true

    self.flicker_timer_2 = timer:every({ 2, 5 }, function()
      self.current_text = GAME_TITLE_ALT_2
      self.reset_timer_2 = timer:after({ 0.1, 0.7 }, function()
        self.current_text = GAME_TITLE
      end)
    end)
  end
end

function GameTitle:draw()
  love.graphics.print(
    self.current_text,
    self.x,
    self.y
  )
end

function GameTitle:destroy()
  helpers.cancelTimer(self.flicker_timer_1)
  helpers.cancelTimer(self.reset_timer_1)
  helpers.cancelTimer(self.flicker_timer_2)
  helpers.cancelTimer(self.reset_timer_2)
end

return GameTitle
