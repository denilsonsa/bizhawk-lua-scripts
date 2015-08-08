local Z = require("ZForms")

local main_form = {}

local function start_demo()
  main_form = Z.Form({
    type = "form",
    title = ".Net enum properties",
    child = {
      type = "stacking",
      children = {
        {type = "label", label = "It is not possible to set enum properties from Lua code. Trying to do so will raise an InvalidCastException.", width = 200, height = 24},
        {type = "button", label = "Set FormBorderStyle", onclick = function()
          print(main_form:get("FormBorderStyle"))
          main_form:set("FormBorderStyle", 6)
          -- main_form:set("FormBorderStyle", "FixedToolWindow")
          print(main_form:get("FormBorderStyle"))
        end},
        {type = "button", label = "Set label TextAlign", onclick = function()
          print("TODO: retrieve the label by id")

          local label = main_form.child.children[1]
          print(label:get("TextAlign"))
          label:set("TextAlign", 32)
          label:set("TextAlign", "MiddleCenter")
          print(label:get("TextAlign"))
        end},
      },
    },
  })

end

local function stop_demo()
  main_form:destroy()
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
