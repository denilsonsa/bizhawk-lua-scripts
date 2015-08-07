-- ZForms
--
-- An easy-to-use UI building library.
-- Works as a wrapper around BizHawk "forms" module.
--
-- Add the following line to your Lua script:
-- Z = require("ZForms")


-- The module contents.
local Z = {}


---------------------------------------------------------------------------
-- General-purpose stuff (i.e. "utils").

-- Useful single value for the concept of "not initialized".
-- Useful to mark table keys that exist but have no value yet.
-- A table key with nil value is the same as a non-existent key.
Z.UNDEFINED = setmetatable({}, {
  __tostring = function() return "UNDEFINED" end,
})

function Z.table_join(...)
  -- Receives an arbitrary number of tables as arguments and join them into a
  -- new table. Returns this new table.

  local ret = {}
  for _,t in ipairs(arg) do
    for i,v in ipairs(t) do
      ret[#ret + 1] = v
    end
    for k,v in pairs(t) do
      ret[k] = v
    end
  end
  return ret
end

---------------------------------------------------------------------------
-- Generic functions for working with objects.

function Z.ClassCallMethod(cls, ...)
  -- This function calls the class new() method, followed by the class init()
  -- method.
  --
  -- It allows using a simpler syntax:
  --   instance = ClassName()

  local instance = cls:new()
  if cls.init ~= nil then
    instance:init(...)
  end
  return instance
end

function Z.ClassNewMethod(cls)
  -- Similar to Python, new() creates a new instance of this class, while
  -- init() initializes the instance values.

  local instance = setmetatable({}, cls)
  return instance
end

function Z.NewClass(...)
  -- This function encapsulates the boilerplate required to declare a new class.
  -- http://lua-users.org/wiki/ObjectOrientationTutorial
  -- http://www.lua.org/pil/16.1.html
  --
  -- Usage:
  --   BaseClass = Z.NewClass()
  --   DerivedClass = Z.NewClass(BaseClass)

  -- Copying the tables of the base classes into the new class.
  local cls = Z.table_join(...)

  -- Failed lookups on the instances will look at the class table.
  cls.__index = cls

  -- The constructor method.
  cls.new = Z.ClassNewMethod

  -- Some magic...
  setmetatable(cls, {
    __call = Z.ClassCallMethod,
  })

  return cls
end

function Z.SetInitialInstanceAttributes(self, default_attributes, initial_values)
  -- Sets the instance attributes based on the default attributes and the
  -- initial passed upon instantiating the object.

  for key, value in pairs(default_attributes) do
    self[key] = value
    if initial_values ~= nil and initial_values[key] ~= nil then
      self[key] = initial_values[key]
    end
  end
end

---------------------------------------------------------------------------
-- jQuery-inspired properties.

function Z.NewProperty(type, prop)
  -- This function returns a function that behaves like jQuery properties.
  -- Calling the function with a value will set the value.
  -- Either way, returns the value from the underlying .Net object.
  --
  -- Examples:
  --   is_checked = some_checkbox:Checked()
  --   is_checked = some_checkbox:Checked(False)
  --   some_checkbox:Checked(False)

  local conversion_func
  if type == "string" then
    conversion_func = Z.PropertyConvertToString
  elseif type == "number" then
    conversion_func = tonumber
  elseif type == "int" then
    conversion_func = Z.PropertyConvertToInt
  elseif type == "boolean" then
    conversion_func = Z.PropertyConvertToBoolean
  else
    error("Invalid property type: " .. tostring(type))
  end

  return function(self, value)
    if value ~= nil then
      self:set(prop, value)
    end
    return conversion_func(self:get(prop))
  end
end

function Z.PropertyConvertToString(value)
  -- forms.getproperty() will always return a string.
  return value
end

function Z.PropertyConvertToInt(value)
  return math.floor(tonumber(value))
end

function Z.PropertyConvertToBoolean(value)
  value = string.lower(value)
  if value == "true" or value == "1" then
    return true
  elseif value == "false" or value == "0" then
    return false
  else
    print("Invalid boolean string: " .. value)
    return nil
  end
end

---------------------------------------------------------------------------
-- Basic ZForms code.

Z.COMMON_COORD_ATTRIBUTES = {
  x = Z.UNDEFINED,
  y = Z.UNDEFINED,
  width = Z.UNDEFINED,
  height = Z.UNDEFINED,
}
Z.COMMON_WIDGET_ATTRIBUTES = Z.table_join(Z.COMMON_COORD_ATTRIBUTES, {
  id = Z.UNDEFINED,  -- TODO: use id for something
  onclick = Z.UNDEFINED,  -- onclick is only supported on Button, Checkbox.
  handle = Z.UNDEFINED,  -- Numeric id used by BizHawk.
})

-- Based on .Net System.Drawing.ContentAlignment, used by Z.Checkbox and Z.Label.
Z.CONTENT_ALIGNMENT = {
  topleft = 1,
  topcenter = 2,
  topright = 4,
  middleleft = 16,
  middlecenter = 32,
  middleright = 64,
  bottomleft = 256,
  bottomcenter = 512,
  bottomright = 1024,
  ["top-left"] = 1,
  ["top-center"] = 2,
  ["top-right"] = 4,
  ["middle-left"] = 16,
  ["middle-center"] = 32,
  ["middle-right"] = 64,
  ["bottom-left"] = 256,
  ["bottom-center"] = 512,
  ["bottom-right"] = 1024,
}

-- Constants (that may, someday, be auto-calculated).
-- TODO: auto-detect it using Z.Form property "ClientSize" (which returns "{Width=192, Height=257}")
Z.BORDER_WIDTH = 8  -- The form window bevel.
Z.BORDER_HEIGHT = 28  -- The form window bevel.
Z.CLIENT_BORDER_WIDTH = 8  -- The bevel of the main window.
Z.CLIENT_BORDER_HEIGHT = 70  -- The bevel of the main window.

function Z.construct_children(children)
  local new_children = {}
  for i,t in ipairs(children) do
    if t ~= nil and t ~= Z.UNDEFINED then
      local obj = Z.TYPE_STRING_TO_CLASS[t.type](t)
      new_children[i] = obj
    end
  end
  return new_children
end

---------------------------------------------------------------------------
-- Base classes containing some common methods.

Z.BaseClass = Z.NewClass()

function Z.BaseClass.update_coords(self, x, y, available_width, available_height)
  -- Default behavior is to expand to all available space.
  -- However, if width/height had been previously defined, those values will be preserved.
  -- x/y coordinates will always be modified.
  self.x = x
  self.y = y
  if self.width == Z.UNDEFINED then
    self.width = available_width
  end
  if self.height == Z.UNDEFINED then
    self.height = available_height
  end
end

Z.BaseWidgetClass = Z.NewClass(Z.BaseClass)

function Z.BaseWidgetClass.get(self, prop)
  return forms.getproperty(self.handle, prop)
end

function Z.BaseWidgetClass.set(self, prop, value)
  forms.setproperty(self.handle, prop, value)
end

function Z.BaseWidgetClass.setlocation(self)
  forms.setlocation(self.handle, self.x, self.y)
end

function Z.BaseWidgetClass.setsize(self)
  forms.setsize(self.handle, self.width, self.height)
end

function Z.BaseWidgetClass._set_text_align(self)
  if self.align ~= Z.UNDEFINED then
    local value = Z.CONTENT_ALIGNMENT[string.lower(self.align)]
    if value ~= nil then
      forms.setproperty(self.handle, 'TextAlign', value)
    end
  end
end

---------------------------------------------------------------------------
-- ZForms event handling functions.

-- Populated by Z.click_handler_wrapper(), consumed by Z.form_run_event_handlers().
Z.form_event_handlers_to_be_run = {}

-- This function should be added to the main loop!
function Z.form_run_event_handlers()
  local funcs = Z.form_event_handlers_to_be_run
  Z.form_event_handlers_to_be_run = {}

  for i,v in ipairs(funcs) do
    funcs[i]()
  end
end

-- Some BizHawk functions cannot be executed from within the GUI thread,
-- which is the case for click handlers.
-- This function is a wrapper to work around this issue.
function Z.click_handler_wrapper(func)
  return function()
    if func and func ~= Z.UNDEFINED then
      Z.form_event_handlers_to_be_run[#Z.form_event_handlers_to_be_run + 1] = func
    end
  end
end

---------------------------------------------------------------------------
-- Z.Form object.

Z.Form = Z.NewClass(Z.BaseWidgetClass)
Z.Form.type = "form"

Z.Form.Left   = Z.NewProperty("int", "Left")
Z.Form.Right  = Z.NewProperty("int", "Right")
Z.Form.Top    = Z.NewProperty("int", "Top")
Z.Form.Bottom = Z.NewProperty("int", "Bottom")
Z.Form.Width  = Z.NewProperty("int", "Width")
Z.Form.Height = Z.NewProperty("int", "Height")

Z.Form.Title   = Z.NewProperty("string", "Text")
Z.Form.Text    = Z.NewProperty("string", "Text")

function Z.Form:init(initial_values)
  Z.SetInitialInstanceAttributes(
    self,
    Z.table_join(Z.COMMON_WIDGET_ATTRIBUTES, {
      title = "Lua script window",
      where = Z.UNDEFINED,
      default_width = 128,
      default_height = 128,
      child = Z.UNDEFINED,
    }),
    initial_values)

  local children = Z.construct_children({[1] = self.child})
  self.child = children[1]
end

function Z.Form:update_coords()
  -- update_coords() for the Form does not receive any parameters.

  if self.child == nil or self.child == Z.UNDEFINED then
    print("Error! Form must have a child.")
    return
  end

  -- First execute the method with UNDEFINED values, to calculate and propagate
  -- automatic dimensions.
  self.child:update_coords(Z.UNDEFINED, Z.UNDEFINED, Z.UNDEFINED, Z.UNDEFINED)

  -- Calculate the suggested dimensions.
  local width = self.default_width
  local height = self.default_height
  if self.width ~= Z.UNDEFINED then
    width = self.width - Z.BORDER_WIDTH
  end
  if self.height ~= Z.UNDEFINED then
    height = self.height - Z.BORDER_HEIGHT
  end

  -- Run again with suggested dimensions.
  self.child:update_coords(0, 0, width, height)

  -- Update the width/height, if undefined.
  if self.width == Z.UNDEFINED then
    self.width = self.child.width + Z.BORDER_WIDTH
  end
  if self.height == Z.UNDEFINED then
    self.height = self.child.height + Z.BORDER_HEIGHT
  end

  self:calculate_xy_from_where()
end

--[[
Z.Form.where can be:
  16 1       2       3 4
    .-----------------.
  15| EmuHawk     _[]X|5
    |                 |
  14|                 |6
    |                 |
  13|                 |7
    '-----------------'
  12 11      10      9 8

  1 - top-left
  2 - top-center
  3 - top-right
  4 - corner-top-right or corner-right-top
  5 - right-top
  6 - right-center
  7 - right-bottom
  8 - corner-bottom-right or corner-right-bottom
  9 - bottom-right
  10 - bottom-center
  11 - bottom-left
  12 - corner-bottom-left or corner-left-bottom
  13 - left-bottom
  14 - left-center
  15 - left-top
  16 - corner-top-left or corner-left-top
--]]

function Z.Form:calculate_xy_from_where()
  if self.where == Z.UNDEFINED then
    return
  end

  -- Main EmuHawk window:
  local main_x = client.xpos()
  local main_y = client.ypos()
  local main_width = client.screenwidth() + Z.CLIENT_BORDER_WIDTH
  local main_height = client.screenheight() + Z.CLIENT_BORDER_HEIGHT

  local w = self.where

  if false then
    -- Just to make all branches be elseif
  elseif w == 15 or w == 'left-top'
      or w == 14 or w == 'left-center'
      or w == 13 or w == 'left-bottom'
      or w == 16 or w == 'corner-top-left' or w == 'corner-left-top'
      or w == 12 or w == 'corner-bottom-left' or w == 'corner-left-bottom' then
    self.x = main_x - self.width + 2
  elseif w == 1 or w == 'top-left'
      or w == 11 or w == 'bottom-left' then
    self.x = main_x
  elseif w == 2 or w == 'top-center'
      or w == 10 or w == 'bottom-center' then
    self.x = main_x + (main_width - self.width + 2) / 2
  elseif w == 3 or w == 'top-right'
      or w == 9 or w == 'bottom-right' then
    self.x = main_x + main_width - self.width + 2
  elseif w == 5 or w == 'right-top'
      or w == 6 or w == 'right-center'
      or w == 7 or w == 'right-bottom'
      or w == 4 or w == 'corner-top-right' or w == 'corner-right-top'
      or w == 8 or w == 'corner-bottom-right' or w == 'corner-right-bottom' then
    self.x = main_x + main_width
  end

  if false then
    -- Just to make all branches be elseif
  elseif w == 1 or w == 'top-left'
      or w == 2 or w == 'top-center'
      or w == 3 or w == 'top-right'
      or w == 4 or w == 'corner-top-right' or w == 'corner-right-top'
      or w == 16 or w == 'corner-top-left' or w == 'corner-left-top' then
    self.y = main_y - self.height + 2
  elseif w == 5 or w == 'right-top'
      or w == 15 or w == 'left-top' then
    self.y = main_y
  elseif w == 6 or w == 'right-center'
      or w == 14 or w == 'left-center' then
    self.y = main_y + (main_height - self.height + 2) / 2
  elseif w == 7 or w == 'right-bottom'
      or w == 13 or w == 'left-bottom' then
    self.y = main_y + main_height - self.height + 2
  elseif w == 11 or w == 'bottom-left'
      or w == 10 or w == 'bottom-center'
      or w == 9 or w == 'bottom-right'
      or w == 8 or w == 'corner-bottom-right' or w == 'corner-right-bottom'
      or w == 12 or w == 'corner-bottom-left' or w == 'corner-left-bottom' then
    self.y = main_y + main_height
  end
end

function Z.Form:build()
  -- build() for the Form does not receive any parameters.
  self.handle = forms.newform(self.width, self.height, self.title)
  if self.x ~= Z.UNDEFINED and self.y ~= Z.UNDEFINED then
    self:setlocation()
  end
  self.child:build(self.handle)
end

---------------------------------------------------------------------------
-- Z.Stacking object.

Z.Stacking = Z.NewClass(Z.BaseClass)
Z.Stacking.type = "stacking"

function Z.Stacking:init(initial_values)
  Z.SetInitialInstanceAttributes(
    self,
    Z.table_join(Z.COMMON_COORD_ATTRIBUTES, {
      children_base_height = 24,
      children = {},
    }),
    initial_values)

  self.children = Z.construct_children(self.children)
end

function Z.Stacking:update_coords(x, y, available_width, available_height)
  local children_width = Z.UNDEFINED
  self.height = 0  -- Will be the sum of children heights.

  self.x = x
  self.y = y
  local child_x = x
  local child_y = y

  for i,c in ipairs(self.children) do
    c:update_coords(child_x, child_y, available_width, self.children_base_height)

    if child_y ~= Z.UNDEFINED then
      child_y = child_y + c.height
    end

    self.height = self.height + c.height

    if c.width ~= Z.UNDEFINED then
      if children_width == Z.UNDEFINED then
        children_width = c.width
      else
        children_width = math.max(children_width, c.width)
      end
    end
  end

  self.width = children_width
end

function Z.Stacking:build(form_handle)
  for i,c in ipairs(self.children) do
    c:build(form_handle)
  end
end

---------------------------------------------------------------------------
-- Z.Checkbox object.

Z.Checkbox = Z.NewClass(Z.BaseWidgetClass)
Z.Checkbox.type = "checkbox"

function Z.Checkbox:init(initial_values)
  Z.SetInitialInstanceAttributes(
    self,
    Z.table_join(Z.COMMON_WIDGET_ATTRIBUTES, {
      label = "",
      align = Z.UNDEFINED,
    }),
    initial_values)
end

function Z.Checkbox:build(form_handle)
  self.handle = forms.checkbox(form_handle, self.label, self.x, self.y)
  self:setsize()
  if self.onclick ~= Z.UNDEFINED then
    forms.addclick(self.handle, Z.click_handler_wrapper(self.onclick))
  end
  self:_set_text_align()
end

---------------------------------------------------------------------------
-- Z.Button object.

Z.Button = Z.NewClass(Z.BaseWidgetClass)
Z.Button.type = "button"

function Z.Button:init(initial_values)
  Z.SetInitialInstanceAttributes(
    self,
    Z.table_join(Z.COMMON_WIDGET_ATTRIBUTES, {
      label = "",
    }),
    initial_values)
end

function Z.Button:build(form_handle)
  self.handle = forms.button(form_handle, self.label,
    Z.click_handler_wrapper(self.onclick), self.x, self.y, self.width, self.height)
end

---------------------------------------------------------------------------
-- Z.Label object.

Z.Label = Z.NewClass(Z.BaseWidgetClass)
Z.Label.type = "label"

function Z.Label:init(initial_values)
  Z.SetInitialInstanceAttributes(
    self,
    Z.table_join(Z.COMMON_WIDGET_ATTRIBUTES, {
      label = "",
      fixedWidth = false,
      align = Z.UNDEFINED,
    }),
    initial_values)
end

function Z.Label:build(form_handle)
  self.handle = forms.label(form_handle, self.label, self.x, self.y,
    self.width, self.height, self.fixedWidth)
  if self.onclick ~= Z.UNDEFINED then
    forms.addclick(self.handle, Z.click_handler_wrapper(self.onclick))
  end
  self:_set_text_align()
end

---------------------------------------------------------------------------
-- Z.Spacer object.

Z.Spacer = Z.NewClass(Z.BaseClass)
Z.Spacer.type = "spacer"

function Z.Spacer:init(initial_values)
  Z.SetInitialInstanceAttributes(
    self,
    Z.table_join(Z.COMMON_WIDGET_ATTRIBUTES, {
    }),
    initial_values)
end

function Z.Spacer:build(form_handle)
end

---------------------------------------------------------------------------
-- Mapping each "type" to their class.

Z.TYPE_STRING_TO_CLASS = {}
for _,cls in ipairs({
  Z.Form,
  Z.Stacking,
  Z.Checkbox,
  Z.Button,
  Z.Label,
  Z.Spacer,
}) do
  Z.TYPE_STRING_TO_CLASS[cls.type] = cls
end


-- Returning this module.
return Z
