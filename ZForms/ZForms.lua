-- ZForms
--
-- An easy-to-use UI building library.
-- Works as a wrapper around BizHawk "forms" module.


---------------------------------------------------------------------------
-- General-purpose stuff (i.e. "utils").

-- Useful single value for the concept of "not initialized".
-- Useful to mark table keys that exist but have no value yet.
-- A table key with nil value is the same as a non-existent key.
UNDEFINED = setmetatable({}, {
  __tostring = function() return "UNDEFINED" end,
})

function table_join(...)
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

function NewClass()
  -- This function encapsulates the boilerplate required to declare a new class.
  -- http://lua-users.org/wiki/ObjectOrientationTutorial
  -- http://www.lua.org/pil/16.1.html

  local t = {}
  t.__index = t
  setmetatable(t, {
    __call = function(cls, ...)
      return cls:new(...)
    end,
  })
  return t
end

function ObjectConstructor(cls, default_attributes, init_values)
  -- This function has the code for creating a new object of a class.
  --
  -- cls                = The object class.
  -- default_attributes = Default values for attributes that can be initialized.
  -- init_values        = Initialization values for attributes.

  -- Making a copy of default_attributes.
  local instance = table_join(default_attributes)

  -- Updating attributes with values from initialization.
  if init_values ~= nil then
    for key, value in pairs(instance) do
      if init_values[key] ~= nil then
        instance[key] = init_values[key]
      end
    end
  end

  setmetatable(instance, cls)

  return instance
end

---------------------------------------------------------------------------
-- Basic ZForms code.

COMMON_COORD_ATTRIBUTES = {
  x = UNDEFINED,
  y = UNDEFINED,
  width = UNDEFINED,
  height = UNDEFINED,
}
COMMON_WIDGET_ATTRIBUTES = table_join(COMMON_COORD_ATTRIBUTES, {
  id = UNDEFINED,  -- TODO: use id for something
  onclick = UNDEFINED,  -- onclick is only supported on Button, Checkbox.
  handle = UNDEFINED,  -- Numeric id used by BizHawk.
  update_coords = function(self, x, y, available_width, available_height)
    -- Default behavior is to expand to all available space.
    -- However, if width/height had been previously defined, those values will be preserved.
    -- x/y coordinates will always be modified.
    self.x = x
    self.y = y
    if self.width == UNDEFINED then
      self.width = available_width
    end
    if self.height == UNDEFINED then
      self.height = available_height
    end
  end,
  _set_text_align = function(self)
    if self.align ~= UNDEFINED then
      local value = CONTENT_ALIGNMENT[string.lower(self.align)]
      if value ~= nil then
        forms.setproperty(self.handle, 'TextAlign', value)
      end
    end
  end,
})

-- Based on .Net System.Drawing.ContentAlignment, used by ZCheckbox and ZLabel.
CONTENT_ALIGNMENT = {
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

function construct_children(children)
  local new_children = {}
  for i,t in ipairs(children) do
    local obj = form_classes[t.type]:new(t)
    new_children[i] = obj
  end
  return new_children
end

---------------------------------------------------------------------------
-- ZForms event handling functions.

-- Populated by click_handler_wrapper(), consumed by zform_run_event_handlers().
form_event_handlers_to_be_run = {}

-- This function should be added to the main loop!
function zform_run_event_handlers()
  local funcs = form_event_handlers_to_be_run
  form_event_handlers_to_be_run = {}

  for i,v in ipairs(funcs) do
    funcs[i]()
  end
end

-- Some BizHawk functions cannot be executed from within the GUI thread,
-- which is the case for click handlers.
-- This function is a wrapper to work around this issue.
function click_handler_wrapper(func)
  return function()
    if func and func ~= UNDEFINED then
      form_event_handlers_to_be_run[#form_event_handlers_to_be_run + 1] = func
    end
    --pretty.dump(form_event_handlers_to_be_run)
  end
end

---------------------------------------------------------------------------
-- ZForm object.

ZForm = NewClass()

function ZForm:new(init)
  local instance = ObjectConstructor(
    self,
    table_join(COMMON_COORD_ATTRIBUTES, {
      type = "form",
      title = "Lua script window",
      where = UNDEFINED,
      base_width = 128,
      base_height = 128,
      border_width = 8,  -- The window bevel.
      border_height = 28,  -- The window bevel.
      client_border_width = 8,  -- The bevel of the main window.
      client_border_height = 70,  -- The bevel of the main window.
      handle = UNDEFINED,
      child = UNDEFINED,
    }),
    init)

  local children = construct_children({[1] = instance.child})
  instance.child = children[1]

  return instance
end

function ZForm:update_coords()
  -- update_coords() for the Form does not receive any parameters.

  -- First execute the method with UNDEFINED values, to calculate and propagate
  -- automatic dimensions.
  self.child:update_coords(UNDEFINED, UNDEFINED, UNDEFINED, UNDEFINED)

  -- Calculate the suggested dimensions.
  local width = self.base_width
  local height = self.base_height
  if self.width ~= UNDEFINED then
    width = self.width - self.border_width
  end
  if self.height ~= UNDEFINED then
    height = self.height - self.border_height
  end

  -- Run again with suggested dimensions.
  self.child:update_coords(0, 0, width, height)

  -- Update the width/height, if undefined.
  if self.width == UNDEFINED then
    self.width = self.child.width + self.border_width
  end
  if self.height == UNDEFINED then
    self.height = self.child.height + self.border_height
  end

  self:calculate_xy_from_where()
end

--[[
ZForm.where can be:
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

function ZForm:calculate_xy_from_where()
  if self.where == UNDEFINED then
    return
  end

  -- Main EmuHawk window:
  local main_x = client.xpos()
  local main_y = client.ypos()
  local main_width = client.screenwidth() + self.client_border_width
  local main_height = client.screenheight() + self.client_border_height

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

function ZForm:build()
  -- build() for the Form does not receive any parameters.
  self.handle = forms.newform(self.width, self.height, self.title)
  if self.x ~= UNDEFINED and self.y ~= UNDEFINED then
    forms.setlocation(self.handle, self.x, self.y)
  end
  self.child:build(self.handle)
end

---------------------------------------------------------------------------
-- ZStacking object.

ZStacking = NewClass()

function ZStacking:new(init)
  local instance = ObjectConstructor(
    self,
    table_join(COMMON_COORD_ATTRIBUTES, {
      type = "stacking",
      children_base_height = 24,
      children = {},
    }),
    init)

  instance.children = construct_children(instance.children)
  return instance
end

function ZStacking:update_coords(x, y, available_width, available_height)
  local children_width = UNDEFINED
  self.height = 0  -- Will be the sum of children heights.

  self.x = x
  self.y = y
  local child_x = x
  local child_y = y

  for i,c in ipairs(self.children) do
    c:update_coords(child_x, child_y, available_width, self.children_base_height)

    if child_y ~= UNDEFINED then
      child_y = child_y + c.height
    end

    self.height = self.height + c.height

    if c.width ~= UNDEFINED then
      if children_width == UNDEFINED then
        children_width = c.width
      else
        children_width = math.max(children_width, c.width)
      end
    end
  end

  self.width = children_width
end

function ZStacking:build(form_handle)
  for i,c in ipairs(self.children) do
    c:build(form_handle)
  end
end

---------------------------------------------------------------------------
-- ZCheckbox object.

ZCheckbox = NewClass()

function ZCheckbox:new(init)
  local instance = ObjectConstructor(
    self,
    table_join(COMMON_WIDGET_ATTRIBUTES, {
      type = "checkbox",
      label = "",
    }),
    init)
  return instance
end

function ZCheckbox:build(form_handle)
  self.handle = forms.checkbox(form_handle, self.label, self.x, self.y)
  forms.setsize(self.handle, self.width, self.height)
  if self.onclick ~= UNDEFINED then
    forms.addclick(self.handle, click_handler_wrapper(self.onclick))
  end
  self:_set_text_align()
end

---------------------------------------------------------------------------
-- ZButton object.

ZButton = NewClass()

function ZButton:new(init)
  local instance = ObjectConstructor(
    self,
    table_join(COMMON_WIDGET_ATTRIBUTES, {
      type = "button",
      label = "",
    }),
    init)
  return instance
end

function ZButton:build(form_handle)
  self.handle = forms.button(form_handle, self.label,
    click_handler_wrapper(self.onclick), self.x, self.y, self.width, self.height)
end

---------------------------------------------------------------------------
-- ZLabel object.

ZLabel = NewClass()

function ZLabel:new(init)
  local instance = ObjectConstructor(
    self,
    table_join(COMMON_WIDGET_ATTRIBUTES, {
      type = "label",
      label = "",
      fixedWidth = false,
      align = UNDEFINED,
    }),
    init)
  return instance
end

function ZLabel:build(form_handle)
  self.handle = forms.label(form_handle, self.label, self.x, self.y,
    self.width, self.height, self.fixedWidth)
  if self.onclick ~= UNDEFINED then
    forms.addclick(self.handle, click_handler_wrapper(self.onclick))
  end
  self:_set_text_align()
end

---------------------------------------------------------------------------
-- ZSpacer object.

ZSpacer = NewClass()

function ZSpacer:new(init)
  local instance = ObjectConstructor(
    self,
    table_join(COMMON_WIDGET_ATTRIBUTES, {
      type = "spacer",
    }),
    init)
  return instance
end

function ZSpacer:build(form_handle)
end

---------------------------------------------------------------------------
-- Mapping each "type" to their class.

form_classes = {
  form = ZForm,
  stacking = ZStacking,
  checkbox = ZCheckbox,
  button = ZButton,
  label = ZLabel,
  spacer = ZSpacer,
}
