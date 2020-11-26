local class = require('libraries.middleclass')
local helpers = require('helpers')

local Background = class('Background')

local tile_speed_x = 0.8
local tile_speed_y_1 = 0.1
local tile_speed_y_2 = 0.3
local tile_speed_y_3 = 0.6
local tile_gif_speed = 0.6

local gif_locations = {
  ['1-3'] = true,
  ['1-5'] = true,
  ['2-2'] = true,
  ['2-7'] = true,
  ['4-2'] = true,
  ['5-4'] = true,
  ['6-8'] = true,
  ['8-3'] = true,
}
is_gif = function (i, j)
  return gif_locations[tostring(i)..'-'..tostring(j)]
end

function Background:initialize()
  self.tile_x = 0
  self.tile_y = 0
  self.quad_timer = 0
  self.quads = {}

  local sheet_width, sheet_height = tile_sheet:getDimensions()
  self.tile_width = sheet_width / tile_sheet_frames
  self.tile_height = sheet_height

  for i = 0, tile_sheet_frames - 1 do
    table.insert(
      self.quads,
      love.graphics.newQuad(
        i * self.tile_width,
        0,
        self.tile_width,
        self.tile_height,
        sheet_width,
        sheet_height
      )
    )
  end
end

function Background:update(dt)
  self.tile_x = self.tile_x - tile_speed_x
  if self.tile_x <= -self.tile_width then self.tile_x = 0 end

  self.tile_y = self.tile_y - player.angle / 100
  if self.tile_y <= -self.tile_height then self.tile_y = 0 end
  if self.tile_y >= self.tile_height then self.tile_y = 0 end

  self.quad_timer = self.quad_timer + dt * tile_gif_speed
end

function Background:draw()
  for i = -1, math.ceil(love.graphics.getHeight() / self.tile_height) do
    for j = 0, math.ceil(love.graphics.getWidth() / self.tile_width) do
      -- if math.random() < 0.3 then
      -- if i == 3 and j == 3 then
      -- if is_gif(i, j) then
      if true then
        love.graphics.draw(
          tile_sheet,
          self.quads[(math.floor(self.quad_timer) % tile_sheet_frames) + 1],
          self.tile_x + j * self.tile_width,
          self.tile_y + i * self.tile_height
        )
      else
        -- love.graphics.draw(
        --   tile_image,
        --   self.tile_x + j * self.tile_width,
        --   self.tile_y + i * self.tile_height
        -- )
      end
    end
  end
end

return Background


-- local Background = {}

-- function Background.load()
--   -- tile constants
--   tile_speed_x = 0.8
--   tile_speed_y_1 = 0.1
--   tile_speed_y_2 = 0.3
--   tile_speed_y_3 = 0.6
--   tile_gif_speed = 0.6
--   quads = {}
--   local sheet_width, sheet_height = tile_sheet:getWidth(), tile_sheet:getHeight()
--   local tile_gif_width = sheet_width / tile_sheet_frames
--   for i = 0, tile_sheet_frames - 1 do
--     table.insert(
--       quads,
--       love.graphics.newQuad(
--         i * tile_gif_width,
--         0,
--         tile_gif_width,
--         sheet_height,
--         sheet_width,
--         sheet_height
--       )
--     )
--   end

--   local gif_locations = {
--     ['1-3'] = true,
--     ['1-5'] = true,
--     ['2-2'] = true,
--     ['2-7'] = true,
--     ['4-2'] = true,
--     ['5-4'] = true,
--     ['6-8'] = true,
--     ['8-3'] = true,
--   }
--   is_gif = function (i, j)
--     return gif_locations[tostring(i)..'-'..tostring(j)]
--   end

--   -- tile starting vars
--   tile_x = 0
--   tile_y = 0
--   timer = 0
-- end

-- function Background.update(dt)
--   tile_x = tile_x - tile_speed_x
--   if tile_x <= -tile:getWidth() then tile_x = 0 end

--   tile_y = tile_y - player.angle / 100
--   if tile_y <= -tile:getHeight() then tile_y = 0 end
--   if tile_y >= tile:getHeight() then tile_y = 0 end

--   timer = timer + dt * tile_gif_speed

-- end

-- function Background.draw()
--   for i = -1, math.ceil(love.graphics.getHeight() / tile:getHeight()) do
--     for j = 0, math.ceil(love.graphics.getWidth() / tile:getWidth()) do
--       -- if math.random() < 0.3 then
--       -- if i == 3 and j == 3 then
--       -- if is_gif(i, j) then
--       if true then
--         love.graphics.draw(
--           tile_sheet,
--           quads[(math.floor(timer) % tile_sheet_frames) + 1],
--           tile_x + j * tile:getWidth(),
--           tile_y + i * tile:getHeight()
--         )
--       else
--         love.graphics.draw(
--           tile,
--           tile_x + j * tile:getWidth(),
--           tile_y + i * tile:getHeight()
--         )
--       end
--     end
--   end
-- end

-- return Background
