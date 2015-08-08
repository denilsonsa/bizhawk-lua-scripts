local Z = require("ZForms")

local open_forms = {}


local function destroy_open_forms()
  for _,f in ipairs(open_forms) do
    f:destroy()
  end
  open_forms = {}
end

-- Declaring open_question() function before it is defined.
-- Solves a dependency cycle when defining these functions.
local open_question

local function open_using_numbers()
  destroy_open_forms()

  for i=0,16 do
    local form = Z.Form({
      type = "form",
      height = 64,
      width = 128,
      title = tostring(i),
      where = i,
      child = {type = "label", label = "where = " .. tostring(i)}
    })
    open_forms[#open_forms + 1] = form
  end

  open_question()
end

local function open_using_strings()
  destroy_open_forms()

  for _,value in ipairs({
    "center",
    "top-left",
    "top-center",
    "top-right",
    "corner-top-right",
    "corner-right-top",
    "right-top",
    "right-center",
    "right-bottom",
    "corner-bottom-right",
    "corner-right-bottom",
    "bottom-right",
    "bottom-center",
    "bottom-left",
    "corner-bottom-left",
    "corner-left-bottom",
    "left-bottom",
    "left-center",
    "left-top",
    "corner-top-left",
    "corner-left-top",
  }) do
    local form = Z.Form({
      type = "form",
      height = 64,
      width = 160,
      title = value,
      where = value,
      child = {type = "label", label = "where = " .. value}
    })
    open_forms[#open_forms + 1] = form
  end

  open_question()
end

-- Already declared as local.
function open_question()
  local question = Z.Form({
    type = "form",
    title = "Form \"where\" demo",
    where = "center",
    child = {
      type = "stacking",
      children = {
        {type = "button", label = "Using numbers", onclick = open_using_numbers},
        {type = "button", label = "Using strings", onclick = open_using_strings},
        {type = "button", label = "Close all", onclick = destroy_open_forms},
      },
    },
  })
  question:Top(question:Top() - question:Height())
  open_forms[#open_forms + 1] = question
end

local function start_demo()
  open_question()
end


local function stop_demo()
  destroy_open_forms()
end


if zform_demo_index_is_loaded then
  return {
    start = start_demo,
    stop = stop_demo,
  }
else

  start_demo()

  while true do
    -- You must call this function on your main loop.
    Z.form_run_event_handlers()

    emu.frameadvance()
  end

end
