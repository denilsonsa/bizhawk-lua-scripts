--Take screenshot of each Lunar Pool level
--Written by Denilson Sa (CrazyTerabyte)
--
--This simple script takes two screenshots of each Lunar Pool level. Two
--screenshots are made: one with just the background, and another with
--the balls.
--
--Notice: It's highly recommended to "Disable Sprite Limit", in order to
--get the best screenshots.
--
--Possible improvement: add code here to hide the "crosshair" before
--taking a screenshot.
--
--This script requires Lua-GD in order to save the screenshots. If
--Lua-GD is not available, a big error message will be displayed.
--
--In order to install Lua-GD...
-- 1. Download lua5_1_4_Win32_bin.zip (or similar) from
--    http://luabinaries.luaforge.net/download.html
-- 2. Extract Lua51.dll and Lua5.1.dll and place them at the fceux.exe
--    directory.
-- 3. Download lua-gd-2.0.33r2-win32.zip (or similar) from
--    http://sourceforge.net/projects/lua-gd/files/
-- 4. Extract all *.dll files and place them at the fceux.exe directory.


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
	skip_frames(500);

	-- Background screenshot
	FCEU.setrenderplanes(false, true);
	FCEU.frameadvance();
	--FCEU.frameadvance();
	local ss_str = gui.gdscreenshot();
	save_screenshot("Lunar Pool " .. level_number .. " bg", ss_str);
	
	-- Full screenshot
	FCEU.setrenderplanes(true, true);
	-- Waiting for the ball become black
	while(memory.readbyte(cue_ball_color_addr) == cue_ball_black_color) do
		FCEU.frameadvance();
	end;
	while(memory.readbyte(cue_ball_color_addr) ~= cue_ball_black_color) do
		FCEU.frameadvance();
	end;
	-- Skipping a frame to make sure the ball is at the correct color
	FCEU.frameadvance();
	-- screen shot string
	ss_str = gui.gdscreenshot();
	save_screenshot("Lunar Pool " .. level_number .. " fg", ss_str);
end;

