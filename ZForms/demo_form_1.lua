Z = require("ZForms")


function run_demo()
  -- Creating some simple forms using ZForms.

  -- The minimum code, just a useless empty form window.
  local empty_form = Z.ZForm({
    type = "form",
  })
  empty_form:update_coords()
  empty_form:build()
end


if zform_demo_index_is_loaded ~= true then
  run_demo()

  while true do
    -- You must call this function on your main loop.
    Z.zform_run_event_handlers()

    emu.frameadvance()
  end

end
