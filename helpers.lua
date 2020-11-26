local helpers = {}

function helpers.clamp(value, min, max)
  -- swap boundaries if provided in reverse
  if min > max then min, max = max, min end
  return math.max(min, math.min(max, value))
end

function helpers.round(num)
  return num % 1 >= 0.5 and math.ceil(num) or math.floor(num)
end


function helpers.hasValue(tab, value)
  for _, v in ipairs(tab) do
      if v == value then
          return true
      end
  end

  return false
end

local KEY_MAP = {
  up = { 'up', 'w' },
  left = { 'left', 'a' },
  down = { 'down', 's' },
  right = { 'right', 'd' },
}
function helpers.isDirectionKeyDown(direction)
  for _, v in ipairs(KEY_MAP[direction]) do
    if love.keyboard.isDown(v) then return true end
  end

  return false
end

function helpers.isDirectionKey(direction, key)
  for _, v in ipairs(KEY_MAP[direction]) do
    if v == key then return true end
  end

  return false
end

function helpers.printPairs(tab)
  if type(tab) ~= 'table' then return end
  for key, values in pairs(tab) do print(key, values) end
end

-- pass as callback to imageData:mapPixel
function helpers.brightenImage(x, y, r, g, b, a)
  r = math.min(r * 3, 1)
  g = math.min(g * 3, 1)
  b = math.min(b * 3, 1)
  return r, g, b, a
end

function helpers.randomizeCapitalization(str)
  local new_string = ''
  for i = 1, #str do
    local letter = math.random() < 0.5 and str:sub(i, i):upper() or str:sub(i, i):lower()
    new_string = new_string..letter
  end

  return new_string
end

function helpers.setColor(r, g, b, a)
  love.graphics.setColor(r / 255, g / 255, b / 255, (a or 255) / 255)
end

function helpers.resetColor()
  love.graphics.setColor(1, 1, 1)
end

return helpers
