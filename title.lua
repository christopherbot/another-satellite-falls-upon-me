local class = require('libraries.middleclass')
local helpers = require('helpers')

local Title = class('Title')

local copy = {
  [1] = GAME_TITLE,
  [2] = 'A game by Chris Bot',
  [3] = 'For',
  [4] = 'For the',
  [5] = 'For the GitHub Game Off 2020',
  [6] = 'Music -',
  [7] = 'Music - "Into Space"',
  [8] = 'Music - "Into Space" (original song)',
  [9] = 'Music - "Into Space" (original song) -',
  [10] = 'Music - "Into Space" (original song) - Mute',
  [11] = 'Music - "Into Space" (original song) - Mute/unmute',
  [12] = 'Music - "Into Space" (original song) - Mute/unmute with',
  [13] = 'Music - "Into Space" (original song) - Mute/unmute with [m]',
  [14] = 'Press [Enter] to begin',
  [15] = 'Press  Enter  to begin',
}

local draw_indexes_by_index = {
  [1] = 1,
  [2] = 2,
  [3] = 3,
  [4] = 3,
  [5] = 3,
  [6] = 4,
  [7] = 4,
  [8] = 4,
  [9] = 4,
  [10] = 4,
  [11] = 4,
  [12] = 4,
  [13] = 4,
  [14] = 5,
  [15] = 5,
}

function Title:initialize()
  print('menu initialized')

  self.copy_display = {}
  for i, v in ipairs(copy) do
    self.copy_display[i] = false
  end

  self.copy_rendered = {}
  for i, v in ipairs(copy) do
    self.copy_rendered[i] = false
  end

  self.current_copy_index = 1
  self.copy_display[self.current_copy_index] = true
  self.copy_rendered[self.current_copy_index] = true

  self.timer = 0
end

function Title:update(dt)
  -- lol just don't look at this
  if not self.copy_rendered[2] and self.timer >= 2.8 then
    self.copy_rendered[2] = true
    self.current_copy_index = 2
  end
  if not self.copy_rendered[3] and self.timer >= 5.3 then
    self.copy_rendered[3] = true
    self.current_copy_index = 3
  end
  if not self.copy_rendered[4] and self.timer >= 5.49 then
    self.copy_rendered[4] = true
    self.current_copy_index = 4
    self.copy_display[3] = false
  end
  if not self.copy_rendered[5] and self.timer >= 5.69 then
    self.copy_rendered[5] = true
    self.current_copy_index = 5
    self.copy_display[4] = false
  end
  if not self.copy_rendered[6] and self.timer >= 7.9 then
    self.copy_rendered[6] = true
    self.current_copy_index = 6
  end
  if not self.copy_rendered[7] and self.timer >= 8.2 then
    self.copy_rendered[7] = true
    self.current_copy_index = 7
    self.copy_display[6] = false
  end
  if not self.copy_rendered[8] and self.timer >= 8.9 then
    self.copy_rendered[8] = true
    self.current_copy_index = 8
    self.copy_display[7] = false
  end
  if not self.copy_rendered[9] and self.timer >= 9.6 then
    self.copy_rendered[9] = true
    self.current_copy_index = 9
    self.copy_display[8] = false
  end
  if not self.copy_rendered[10] and self.timer >= 9.97 then
    self.copy_rendered[10] = true
    self.current_copy_index = 10
    self.copy_display[9] = false
  end
  if not self.copy_rendered[11] and self.timer >= 10.31 then
    self.copy_rendered[11] = true
    self.current_copy_index = 11
    self.copy_display[10] = false
  end
  if not self.copy_rendered[12] and self.timer >= 10.67 then
    self.copy_rendered[12] = true
    self.current_copy_index = 12
    self.copy_display[11] = false
  end
  if not self.copy_rendered[13] and self.timer >= 11.03 then
    self.copy_rendered[13] = true
    self.current_copy_index = 13
    self.copy_display[12] = false
  end
  if not self.copy_rendered[14] and self.timer >= 11.3 then
    self.copy_rendered[14] = true
    self.current_copy_index = 14
  end
  if not self.copy_rendered[15] and self.timer >= 12.1 then
    self.copy_rendered[15] = true
    self:toggle_enter_copy()
    self.flash_enter_timer = timer:every(0.71, function()
      self:toggle_enter_copy()
    end)
  end

  self.copy_display[self.current_copy_index] = true

  self.timer = self.timer + dt
end

function Title:draw()
  for i, should_display in ipairs(self.copy_display) do
    if should_display then
      local draw_index = draw_indexes_by_index[i]

      love.graphics.print(
        copy[i],
        250,
        120 + 50 * draw_index
      )
    end
  end
end

function Title:toggle_enter_copy()
  local prev_index = self.current_copy_index
  self.current_copy_index = prev_index == 14 and 15 or 14
  self.copy_display[prev_index] = false
  self.copy_display[self.current_copy_index] = true
end

function Title:destroy()
  helpers.cancelTimer(self.flash_enter_timer)
  print('menu destroyed')
end

return Title
