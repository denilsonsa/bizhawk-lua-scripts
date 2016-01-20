--Take screenshot of each Lunar Pool level title
--Written by Denilson Sa (CrazyTerabyte)
--
--This simple script takes a screenshots of the "STAGE 00 START" screen
--for each level.
--
--Then, to crop each screenshot to just the title line, run this:
--
-- for a in stagenum_*.png ; do convert "$a" -crop 256x8+0+112 +repage "title_$a" ; done
--


local friction_addr = 0x0002;
local level_addr = 0x0187;
local cue_ball_color_addr = 0x0092;
local cue_ball_color_ppu_addr = 0x3F12;
local cue_ball_black_color = 0x0E;

function skip_frames(frames)
	for i=1,frames do
		FCEU.frameadvance();
	end;
end;

function press(key)
	local keys = {
		up     = false,
		down   = false,
		left   = false,
		right  = false,
		A      = false,
		B      = false,
		start  = false,
		select = false
	};

	keys[key] = true;
	joypad.set(1, keys);

	FCEU.frameadvance();
	keys[key] = false;
	joypad.set(1, keys);
end;

require "gd";

if not gd then
	-- Actually... This message is never shown.
	-- A big error message is displayed, instead.
	FCEU.message("Warning! Lua-GD binding was not found.");
	FCEU.message("Falling back to writing raw dumps in GD format.");

	function save_screenshot(filename, raw_string)
		local f = io.open(filename .. ".gd_dump", "wb");
		f:write(raw_string);
		f:close()
	end;
else
	function save_screenshot(filename, raw_string)
		local gd_img = gd.createFromGdStr(raw_string);
		gd_img:png(filename .. ".png");
	end;
end;



--FCEU.speedmode("nothrottle");
FCEU.speedmode("maximum");

for level_number=1,60 do
	FCEU.poweron();

	-- Wait about 60 frames for the title screen
	skip_frames(60);
	press("start");

	-- Wait about 60~90 frames before starting a game
	skip_frames(60);

	-- Select a level and press start
	memory.writebyte(level_addr, level_number)
	press("start");

	-- Wait about 400~500 frames for the level load
	skip_frames(70);

	local ss_str = gui.gdscreenshot();
	save_screenshot("stagenum_" .. level_number, ss_str);
end;

