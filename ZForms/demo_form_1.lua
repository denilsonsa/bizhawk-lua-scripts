local Z = require("ZForms")

local almost_empty_form
local better_form


local function start_demo()
  -- Creating some simple forms using ZForms.

  -- The minimum code, just a useless form window with a text label.
  almost_empty_form = Z.Form({
    type = "form",
    child = {
      type = "label", label = "Almost empty form!",
    }
  })

  -- A Z.Form must have a single child widget. Since most of the time you want
  -- multiple widgets in the same window, you can use a layout manager
  -- pseudo-widget to hold several children, and also to position them
  -- correctly or automatically.

  -- Using Z.Stacking to place several widgets in the same form window.
  better_form = Z.Form({
    type = "form",
    title = "Custom title!",
    width = 200,
    child = {
      type = "stacking",
      children = {
        {type = "label", label = "Now we can have multiple widgets in a single form!", height = 64},
        {type = "checkbox", label = "Like checkboxes!"},
        {type = "button", label = "Or buttons!"},
        {type = "label", label = "Or spacers!"},
        {type = "spacer"},
        {type = "label", label = "Observe that Z.Stacking automatically calculates the height to fit all widgets.", height = 64},
        {type = "label", label = "Note: These widgets have no behavior in this demo.", height = 32},
      }
    }
  })
end


local function stop_demo()
  almost_empty_form:destroy()
  better_form:destroy()
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
