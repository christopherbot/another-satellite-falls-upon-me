local class = require('libraries.middleclass')
local helpers = require('helpers')

local Title = class('Title')

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

  self.timer = 0

  self.copy = {
    [1] = {
      startTime = 0,
      text = GAME_TITLE,
      should_display = false,
    },
    [2] = {
      startTime = 2.8,
      text = 'A game by Chris Bot',
      should_display = false,
    },
    [3] = {
      startTime = 5.3,
      text = 'For',
      should_display = false,
    },
    [4] = {
      startTime = 5.49,
      text = 'For the',
      should_display = false,
      hide_index = 3,
    },
    [5] = {
      startTime = 5.69,
      text = 'For the GitHub Game Off 2020',
      should_display = false,
      hide_index = 4,
    },
    [6] = {
      startTime = 7.9,
      text = 'Music -',
      should_display = false,
    },
    [7] = {
      startTime = 8.2,
      text = 'Music - "Into Space"',
      should_display = false,
      hide_index = 6,
    },
    [8] = {
      startTime = 8.9,
      text = 'Music - "Into Space" (original song)',
      should_display = false,
      hide_index = 7,
    },
    [9] = {
      startTime = 9.6,
      text = 'Music - "Into Space" (original song) - Mute',
      should_display = false,
      hide_index = 8,
    },
    [10] = {
      startTime = 9.97,
      text = 'Music - "Into Space" (original song) - Mute/unmute',
      should_display = false,
      hide_index = 9,
    },
    [11] = {
      startTime = 10.31,
      text = 'Music - "Into Space" (original song) - Mute/unmute with',
      should_display = false,
      hide_index = 10,
    },
    [12] = {
      startTime = 10.67,
      text = 'Music - "Into Space" (original song) - Mute/unmute with [ ]',
      should_display = false,
      hide_index = 11,
    },
    [13] = {
      startTime = 11.03,
      text = 'Music - "Into Space" (original song) - Mute/unmute with [m]',
      should_display = false,
      hide_index = 12,
    },
    [14] = {
      startTime = 11.3,
      text = 'Press [Enter] to begin',
      should_display = false,
    },
    [15] = {
      startTime = 12.1,
      text = 'Press  Enter  to begin',
      should_display = false,
      run = function()
        self:toggle_enter_copy()
        self.flash_enter_timer = timer:every(0.71, function()
          self:toggle_enter_copy()
        end)
      end,
    },
  }
end

function Title:update(dt)
  for i, v in pairs(self.copy) do
    if self.timer >= v.startTime and not v.started then
      -- Note: start the music here to sync it with the title copy
      if i == 1 then music:play() end
      v.started = true

      if v.hide_index then
        self.copy[v.hide_index].should_display = false
      end

      if v.run then
        v.run()
      else
        v.should_display = true
      end
    end
  end

  self.timer = self.timer + dt
end

function Title:draw()
  for i, v in ipairs(self.copy) do
    if v.should_display then
      local draw_index = draw_indexes_by_index[i]

      love.graphics.print(
        v.text,
        250,
        120 + 50 * draw_index
      )
    end
  end
end

function Title:toggle_enter_copy()
  self.copy[14].should_display = not self.copy[14].should_display
  self.copy[15].should_display = not self.copy[15].should_display
end

function Title:destroy()
  helpers.cancelTimer(self.flash_enter_timer)
  print('menu destroyed')
end

return Title
