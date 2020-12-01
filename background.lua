local class = require('libraries.middleclass')
local helpers = require('helpers')

local Background = class('Background')

local tile_speed_x = 0.8
local tile_gif_speed = 0.6

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

  self.tile_y = self.tile_y - (player or { angle = 0 }).angle / 100
  if self.tile_y <= -self.tile_height then self.tile_y = 0 end
  if self.tile_y >= self.tile_height then self.tile_y = 0 end

  self.quad_timer = self.quad_timer + dt * tile_gif_speed
end

function Background:draw()
  for i = -1, math.ceil(love.graphics.getHeight() / self.tile_height) do
    for j = 0, math.ceil(love.graphics.getWidth() / self.tile_width) do
      love.graphics.draw(
        tile_sheet,
        self.quads[(math.floor(self.quad_timer) % tile_sheet_frames) + 1],
        self.tile_x + j * self.tile_width,
        self.tile_y + i * self.tile_height
      )
    end
  end
end

return Background
