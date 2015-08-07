local Z = require("ZForms")


local function run_demo()
  -- Creating some simple forms using ZForms.

  -- The minimum code, just a useless form window with a text label.
  local almost_empty_form = Z.Form({
    type = "form",
    child = {
      type = "label", label = "Almost empty form!",
    }
  })
  almost_empty_form:update_coords()
  almost_empty_form:build()

  -- A Z.Form must have a single child widget. Since most of the time you want
  -- multiple widgets in the same window, you can use a layout widget to hold
  -- several children, and also to position them correctly.

  -- Using Z.Stacking to put several widgets in the same form window. 
  local better_form = Z.Form({
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
        {type = "label", label = "Note: These widgets have no behavior in this demo.", height = 32},
      }
    }
  })
  better_form:update_coords()
  better_form:build()
end


if zform_demo_index_is_loaded == true then
  return {
    run_demo = run_demo,
  }
else
  run_demo()

  while true do
    -- You must call this function on your main loop.
    Z.form_run_event_handlers()

    emu.frameadvance()
  end

end
