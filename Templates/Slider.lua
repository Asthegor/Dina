local Slider = {
  _TITLE       = 'Dina GE Slider',
  _VERSION     = '2.0.3',
  _URL         = 'https://dina.lacombedominique.com/documentation/templates/slider/',
  _LICENSE     = [[
    ZLIB Licence

    Copyright (c) 2020 LACOMBE Dominique

    This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
    Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
        1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
        2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
        3. This notice may not be removed or altered from any source distribution.
  ]]
}

-- Déclaration du parent
local CurrentFile = (...):gsub("^(.*/+)", "")
local CurrentFolder = (...):gsub('%/'..CurrentFile..'$', '')
local Parent = require(CurrentFolder.."/Panel")
setmetatable(Slider, {__index = Parent})
local Button = require(CurrentFolder.."/Button")


--[[
proto const Slider.New(X, Y, Width, Height, Value, Max, SliderColor, CursorColor, Orientation, Z)
.D This function creates a new Text object.
.P X
Position on the X axis of the text.
.P Y
Position on the Y axis of the text.
.P Width
Width of the space occupied by the text.
.P Height
Haight of the space occupied by the text.
.P Value
Current value of the slider.
.P Max
Max value of the slider.
.P SliderColor
Color of the slider (bar).
.P CursorColor
Color of the cursor.
.P Orientation
Orientation of the slider : horizontal or vertical.
.P Z
Z-Order of the slider.
.R Return an instance of Slider object.
]]--
function Slider.New(X, Y, Width, Height, Value, Max, SliderColor, CursorColor, Orientation, Z)
  local self = setmetatable(Parent.New(X, Y, Width, Height, nil, nil, Z), Slider)
  self.orientation = Orientation == "vertical" and Orientation or "horizontal"
  self.value = Value
  self.max = Max
  self.slidercolor = SliderColor or {1,1,1,1}
  local cursorx, cursory, cursorw, cursorh
  if self.orientation == "vertical" then
    self.thin = self.width * .2
    cursorw = self.width
    cursorh = self.thin
    self.step = (self.height - self.thin/2) / Max
    cursorx = self.x
    cursory = self.y + self.value * self.step
    self.xs = self.x + self.width/2 - self.thin/2
    self.ys = self.y
    self.ws = self.thin
    self.hs = self.height
  else
    self.thin = self.height * .2
    cursorw = self.thin
    cursorh = self.height
    self.step = (self.width - self.thin/2) / Max
    cursorx = self.x + self.value * self.step
    cursory = self.y
    self.xs = self.x
    self.ys = self.y + self.height/2 - self.thin/2
    self.ws = self.width
    self.hs = self.thin
  end
  self.cursor = Button.New(cursorx, cursory, cursorw, cursorh, "")
  self.cursor:SetBorderColor(CursorColor)
  self.cursor:SetBackColor(CursorColor)
  return self
end

function Slider:ChangeCursorPosition()
  local cursorx, cursory
  if self.orientation == "vertical" then
    cursorx = self.x
    cursory = self.y + self.value * self.step
  else
    cursorx = self.x + self.value * self.step
    cursory = self.y
  end
  self.cursor:SetPosition(cursorx, cursory)
end

function Slider:Draw()
  if self.visible then
    self:DrawSlider()
  end
end

function Slider:DrawSlider()
  love.graphics.setColor(self.slidercolor)
  love.graphics.rectangle("fill", self.xs, self.ys, self.ws, self.hs)
  love.graphics.setColor(1,1,1,1)
  self.cursor:Draw()
  love.graphics.setColor(1,1,1,1)
end

function Slider:SetColors(SliderColor, BorderCursorColor, BackCursorColor)
  self.slidercolor = SliderColor
  self.cursor:SetBorderColor(BorderCursorColor)
  self.cursor:SetBackColor(BackCursorColor)
end

function Slider:SetPosition(X, Y)
  self.x = X
  self.y = Y
  if self.orientation == "vertical" then
    self.xs = self.x + self.width/2 - self.thin/2
    self.ys = self.y
  else
    self.xs = self.x
    self.ys = self.y + self.height/2 - self.thin/2
  end
  self:ChangeCursorPosition()
end


function Slider:GetMaxValue()
  return self.max
end

function Slider:GetValue()
  return self.value
end

function Slider:SetMaxValue(pMax)
  self.max = pMax
end

function Slider:SetValue(pValue)
  if pValue >= 0 and pValue <= self.max then
    self.value = pValue
    self:ChangeCursorPosition()
  end
end


function Slider:Update(dt)
  if self.visible then
    self:UpdateSlider(dt)
  end
end

function Slider:UpdateSlider(dt)
  self:UpdatePanel(dt)
  self.cursor:Update(dt)
  if self.cursor.pressed and love.mouse.isDown(1) then
    if self.orientation == "vertical" then
      local my = love.mouse.getY()
      if my < self.cursor.y then
        local newval = math.floor((self.cursor.y-my) / self.step)
        self:SetValue(self.value - newval)
      elseif my > self.cursor.y+self.cursor.height then
        local newval = math.floor((my-self.cursor.y-self.cursor.height) / self.step)
        self:SetValue(self.value + newval)
      end
    else
      local mx = love.mouse.getX()
      if mx < self.cursor.x then
        local newval = math.floor((self.cursor.x-mx) / self.step)
        self:SetValue(self.value - newval)
      elseif mx > self.cursor.x+self.cursor.width then
        local newval = math.floor((mx-self.cursor.x-self.cursor.width) / self.step)
        self:SetValue(self.value + newval)
      end
    end
  end
end

function Slider:ToString(NoTitle)
  local str = ""
  if not NoTitle then
    str = str .. self._TITLE .. " (".. self._VERSION ..")"
  end
  str = str .. Parent:ToString(true)
  for k,v in pairs(self) do
    local vtype = type(v)
    if vtype == "function"        then goto continue end
    if vtype == "table"           then goto continue end
    if string.sub(k, 1, 1) == "_" then goto continue end
    str = str .. "\n" .. tostring(k) .. " : " .. tostring(v)
    ::continue::
  end
  return str
end
Slider.__tostring = function(Slider, NoTitle) return Slider:ToString(NoTitle) end
Slider.__call = function() return Slider.new() end
Slider.__index = Slider
return Slider