--Show all Lunar Pool levels
--Written by Denilson Sa (CrazyTerabyte)
--
--This simple script fast-forwards to show the first level, then return
--back to normal speed. Upon pressing Select, this script resets the NES
--and fast-forwards to the next level.


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


for level_number=1,60 do
	--FCEU.speedmode("nothrottle");
	FCEU.speedmode("maximum");

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

	FCEU.speedmode("normal");

	while(not joypad.get(1)["select"]) do
		FCEU.frameadvance();
	end;
end;

