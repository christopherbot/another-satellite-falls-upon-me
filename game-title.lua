local class = require('libraries.middleclass')
local helpers = require('helpers')

local GameTitle = class('GameTitle')

function GameTitle:initialize()
  self.x = love.graphics.getWidth() / 2
  self.y = 40
  self.flicker_1 = false
  self.flicker_2 = false
  self.current_text = GAME_TITLE
  self.has_faded_in = false
  self.opacity = 0

  -- All game titles variants are the same width so that
  -- they overlap nicely, so any can be used here:
  self.text_width = font:getWidth(self.current_text)
end

function GameTitle:update(dt)
  if not self.has_faded_in then
    self:fade_in()
  end

  if not self.flicker_1 and current_game_state == game_states.level2 then
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
  helpers.setColor(255, 255, 255, self.opacity)
  love.graphics.print(
    self.current_text,
    self.x,
    self.y,
    0,
    1,
    1,
    self.text_width / 2
  )
  helpers.resetColor()
end

function GameTitle:fade_in()
  self.has_faded_in = true
  self.fade_in_timer = timer:tween(
    2,
    self,
    { opacity = 0.3 },
    'linear'
  )
end

function GameTitle:destroy()
  helpers.cancelTimer(self.flicker_timer_1)
  helpers.cancelTimer(self.reset_timer_1)
  helpers.cancelTimer(self.flicker_timer_2)
  helpers.cancelTimer(self.reset_timer_2)
end

return GameTitle
