Z = require("ZForms")

zform_demo_index_is_loaded = true


function run_external_demo(name)
  local demo = require(name)
  demo.run_demo()
end


form_description = {
  type = "form",
  width = 200,
  where = 1,
  child = {
    type = "stacking",
    --children_base_height = 32,  -- Default height for children, can be overriden
    children = {
      -- optional: height
      --[[{type = "checkbox", id = "HIDE_HUD", label = "Hide HUD"},
      {type = "checkbox", id = "SPRITES_ON_TOP", label = "Sprites on-top", checked = true},
      {type = "checkbox", id = "HIDE_SPRITES", label = "Hide sprites", onclick=advance100},
      {type = "spacer", height = 8},
      {type = "checkbox", id = "SCREENSHOTS", label = "Save screenshots for stitching a level map"},
      {type = "label", label = "Label 1"},
      {type = "label", label = "Label 2", fixedWidth = true, onclick=advance100},
      {type = "label", label = "Label 3", height = 32},
      {type = "label", label = "Foo bar baz off", width = 16},
      {type = "button", id = "BUTTON1", label = "Button 1", onclick=advance100},
      {type = "button", id = "BUTTON2", label = "Button 2"},
      {type = "spacer", height = 8},
      {type = "button", id = "BUTTON3", label = "Button 3"},
      {type = "button", id = "BUTTON4", label = "Button 4", height=32},
      {type = "button", id = "BUTTON5", label = "Button 5", width=64},
      --]]
      {type = "button", label = "Form demo 1", onclick = function()
        run_external_demo("demo_form_1")
      end},
      {type = "button", id = "MOVE", label = "MOVE", onclick = function()
        ff.where = ff.where + 1
        if ff.where > 16 then
          ff.where = 1
        end
        ff:calculate_xy_from_where()
        forms.setlocation(ff.handle, ff.x, ff.y)
      end},
    },
  },
}

ff = Z.ZForm(form_description)
ff:update_coords()
ff:build()


while true do
  -- You must call this function on your main loop.
  Z.zform_run_event_handlers()

  emu.frameadvance()
end
