-- Author: Denilson Sá (AKA CrazyTerabyte)
-- 2015-03-24

-- How to install:
-- 1. Make sure the directory containing this lua script is writable.
-- 2. Save the PNG image from the comment below into the same directory as the lua script.

-- Must be placed in the same directory of the lua script.
NUMBERS_PNG = "SNES_Push-Over_numbers.png"
-- The contents of this image are:
-- data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAACgBAMAAAD3F/EnAAAAGFBMVEUAAAAAAAAxY2NjlJSUxcXF9/f3//////8aUowxAAAAAXRSTlMAQObYZgAAAYRJREFUOE+llLFuwyAQht036AUCs6u+gBU5nRlsz1aLOqO2ZLbk5l6/xx3YidpmiJk+YQMf/51dPQCPxwo+Dk80oFIyU1c7UN6/Mhy/9rFJ8D4BjgmQYGpWUH9AflnB8VPL8mVDHqGCdOThANWicdMHWi+gYxQYEPOjBM0K6j9IPlCWd96/bfDR5TrRHaPjWMBikA0HDOyjER2fPuCZNWgiMLzQBPv0cTS8ytMYN/nIdfqgs89kcJINTfaxWQP0KYM8UuVltS7fWi9oRwEdg8BA3cGqSJB8hplBaQQBOxdAGuxDBcvLwY8bfJZ46QCZWQHxXCefGFHSYFcBWxrblnyM5PNMgdf3+6hO6rXro+MZjd/yyLAY+aQQzpIGnR4KTAuQD4UrPrtuk4+6aD/aU8CikwriLN/XgO76s0pPGFg65WOoXHzBPZVrQ73a3H7LBcuVUz5W+pn+ADOfXsBcB0U+Ji0Plxve6VPi/e1TiiJi3C2n1L2lf5aOctzP9P+q84bNTZ8fVWfYWcUIhNMAAAAASUVORK5CYII=

-- Will be saved at the same directory of the lua script.
MAINMENU_SAVESTATE = "SNES_Push-Over_MainMenu.State"

-- Some constants.
PASSCODE_BASE = 0x001100
TIME_TICK   = 0x000303  -- 1/50 of second
TIME_SECOND = 0x000304  -- seconds

-- Tables in Lua start counting from 1.
-- Number literals starting with zero are still represented in base 10.
PASSCODES = {
	00512,  -- Level 01
	01536,  -- Level 02
	01024,  -- Level 03
	03072,  -- Level 04
	03584,  -- Level 05
	02560,  -- Level 06
	02048,  -- Level 07
	06144,  -- Level 08
	06656,  -- Level 09
	07680,  -- Level 10
	07168,  -- Level 11
	05122,  -- Level 12
	05634,  -- Level 13
	04610,  -- Level 14
	04098,  -- Level 15
	12290,  -- Level 16
	12802,  -- Level 17
	13826,  -- Level 18
	13314,  -- Level 19
	15362,  -- Level 20
	15878,  -- Level 21
	14854,  -- Level 22
	14342,  -- Level 23
	10246,  -- Level 24
	10758,  -- Level 25
	11782,  -- Level 26
	11270,  -- Level 27
	09222,  -- Level 28
	09734,  -- Level 29
	08718,  -- Level 30
	08206,  -- Level 31
	24590,  -- Level 32
	25102,  -- Level 33
	26126,  -- Level 34
	25614,  -- Level 35
	27662,  -- Level 36
	28174,  -- Level 37
	27150,  -- Level 38
	26638,  -- Level 39
	30734,  -- Level 40
	31246,  -- Level 41
	32270,  -- Level 42
	31758,  -- Level 43
	29726,  -- Level 44
	30238,  -- Level 45
	29214,  -- Level 46
	28702,  -- Level 47
	20510,  -- Level 48
	21022,  -- Level 49
	22046,  -- Level 50
	21534,  -- Level 51
	23582,  -- Level 52
	24094,  -- Level 53
	23070,  -- Level 54
	22558,  -- Level 55
	18494,  -- Level 56
	19006,  -- Level 57
	20030,  -- Level 58
	19518,  -- Level 59
	17470,  -- Level 60
	17982,  -- Level 61
	16958,  -- Level 62
	16510,  -- Level 63
	16511,  -- Level 64
	17023,  -- Level 65
	18047,  -- Level 66
	17535,  -- Level 67
	19583,  -- Level 68
	20095,  -- Level 69
	19071,  -- Level 70
	18559,  -- Level 71
	22655,  -- Level 72
	23167,  -- Level 73
	24191,  -- Level 74
	23679,  -- Level 75
	21631,  -- Level 76
	22143,  -- Level 77
	21247,  -- Level 78
	20735,  -- Level 79
	28927,  -- Level 80
	29439,  -- Level 81
	30463,  -- Level 82
	29951,  -- Level 83
	31999,  -- Level 84
	32511,  -- Level 85
	31487,  -- Level 86
	30975,  -- Level 87
	26879,  -- Level 88
	27647,  -- Level 89
	28671,  -- Level 90
	28159,  -- Level 91
	26111,  -- Level 92
	26623,  -- Level 93
	25599,  -- Level 94
	25087,  -- Level 95
	08703,  -- Level 96
	09215,  -- Level 97
	10239,  -- Level 98
	09727,  -- Level 99
	44543   -- Level 00?
}

function input_passcode(passcode)
	for index = 8, 0, -2 do
		local digit = passcode % 10
		passcode = (passcode-digit) / 10
		mainmemory.write_u16_le(PASSCODE_BASE + index, digit)
	end
end

function get_passcode_digit(index)
	return mainmemory.read_u16_le(PASSCODE_BASE + 2 * index) % 10
end

function draw_passcode()
	for i = 0, 4, 1 do
		local value = get_passcode_digit(i)
		if gui.drawImageRegion then
			-- Implemented in BizHawk revision 9265, fixed a few revisions later.
			gui.drawImageRegion(NUMBERS_PNG, 0, value * 16, 16, 16, 128 - 40 + i * 16, -1)
		else
			gui.drawText(128 - 40 + i * 16, 0, value, 0xFFFFFFFF, 16)
		end
	end
end

-- joypad.set sets the value for a single frame
function reset()
	joypad.set({Reset = true})
end
function start()
	joypad.set({Start = true}, 1)
end

function wait_until(domain, address, byte_value)
	memory.usememorydomain(domain)
	while memory.readbyte(address) ~= byte_value do
		emu.frameadvance()
	end
	memory.usememorydomain("WRAM")
end

function wait_until_tick_equals_to(value)
	wait_until("WRAM", TIME_TICK, value)
end

function wait_main_character_is_getting_out()
	wait_until("VRAM", 0xC08A, 195)
end

function is_incorrect_code_screen()
	local BASE = 0x0022D0
	local text = "incorrect code"
	for i = 1, 14, 1 do
		local ascii = string.byte(text, i)
		local value = mainmemory.readbyte(BASE + i*2)
		if ascii ~= 32 then  -- Ignore space
			if value ~= ascii then
				return false
			end
		end
	end
	return true
end

function go_to_main_screen()
	reset()
	client.unpause()
	input_passcode(00000)

	client.speedmode(400)

	-- Waiting until the game resets to the passcode of the first level.
	-- wait_until("WRAM", PASSCODE_BASE + 4, 5)

	-- Waiting and auto-firing the Start button.
	while mainmemory.readbyte(PASSCODE_BASE + 4) ~= 5 do
		start()
		emu.frameadvance()
		emu.frameadvance()
	end

	-- Waiting one more frame to let the screen be drawn.
	emu.frameadvance()

	client.speedmode(100)
	savestate.save(MAINMENU_SAVESTATE)
	client.pause()
end

function go_to_level(level_number)
	savestate.load(MAINMENU_SAVESTATE)
	client.unpause()
	input_passcode(PASSCODES[level_number])
	start()

	-- Setting the TICK to a known, arbitrary value.
	mainmemory.writebyte(TIME_TICK, 33)
	-- Waiting until it gets reset when the level starts.
	client.speedmode(400)
	wait_until_tick_equals_to(0)
	wait_main_character_is_getting_out()
	client.speedmode(100)
	client.pause()
end

function take_screenshots_of_all_levels()
	for level_number = 1, 100, 1 do
		go_to_level(level_number)

		-- Drawing the passcode at the top of the level.
		-- It is only captured in screenshots if "File->Screenshot->Capture OSD" is enabled.
		client.unpause()
		for i = 0, 32, 1 do
			-- Clearing OSD messages.
			gui.addmessage("")
		end
		if forms.ischecked(CHCK_SHOWPASSCODE) then
			draw_passcode()
			emu.frameadvance()
		end

		client.screenshot(string.format("Push-Over_level_%02d_passcode_%05d.png", level_number, PASSCODES[level_number]))
	end
end

function bruteforce_all_passcodes()
	client.speedmode(800)
	for passcode = 0, 99999, 1 do
		local passcode_string = string.format("%05d", passcode)

		savestate.load(MAINMENU_SAVESTATE)
		client.unpause()
		input_passcode(passcode)
		gui.addmessage(passcode_string)
		start()

		-- Setting the TICK to a known, arbitrary value.
		mainmemory.writebyte(TIME_TICK, 33)
		-- Waiting until it gets reset when the level starts.
		wait_until_tick_equals_to(0)

		if not is_incorrect_code_screen() then
			print(passcode_string)
		end
	end
	client.speedmode(100)
	client.pause()
end

-- GUI-related functions below.

function button_mainmenu_click()
	SHOULD_GO_TO_LEVEL = -1
	client.unpause()
end

function button_goToLevel_click()
	local level_number = forms.gettext(TEXT_LEVELNUM)
	level_number = tonumber(level_number)
	if level_number == nil then return; end
	level_number = math.floor(level_number)
	if level_number <= 0 or level_number > 100 then return; end

	SHOULD_GO_TO_LEVEL = level_number
	client.unpause()
end

function button_previousLevel_click()
	local level_number = forms.gettext(TEXT_LEVELNUM)
	forms.settext(TEXT_LEVELNUM, level_number - 1)
	button_goToLevel_click()
end

function button_nextLevel_click()
	local level_number = forms.gettext(TEXT_LEVELNUM)
	forms.settext(TEXT_LEVELNUM, level_number + 1)
	button_goToLevel_click()
end

function button_screenshots_click()
	SHOULD_GO_TO_LEVEL = -2
	client.unpause()
end

function button_findpasscodes_click()
	SHOULD_GO_TO_LEVEL = -3
	client.unpause()
end

FORM = forms.newform(128, 240, "Push-Over")
BUTT_MAINMENU = forms.button(FORM, "Initialize Save State", button_mainmenu_click, 0, 0, 120, 20)
LABL_LEVELNUM = forms.label(FORM, "Level:", 0, 30, 40, 20, false)
TEXT_LEVELNUM = forms.textbox(FORM, "1", 40, 20, "UNSIGNED", 40, 30, false, true)
BUTT_GOTOLEVEL = forms.button(FORM, "Go to level", button_goToLevel_click, 80, 30, 40, 20)
BUTT_PREVLEVEL = forms.button(FORM, "< Prev", button_previousLevel_click, 0, 50, 60, 20)
BUTT_NEXTLEVEL = forms.button(FORM, "Next >", button_nextLevel_click, 60, 50, 60, 20)
CHCK_SHOWPASSCODE = forms.checkbox(FORM, "Show passcode", 0, 80)
BUTT_SCREENSHOTS = forms.button(FORM, "Take screenshots of all levels", button_screenshots_click, 0, 110, 120, 40)
BUTT_FINDPASSCODES = forms.button(FORM, "Bruteforce passcodes (very slow!)", button_findpasscodes_click, 0, 150, 120, 40)

-- This is needed because we can't call emu.frameadvance from the GUI thread.
SHOULD_GO_TO_LEVEL = nil

while true do
	if SHOULD_GO_TO_LEVEL ~= nil then
		if SHOULD_GO_TO_LEVEL == -1 then
			go_to_main_screen()
		elseif SHOULD_GO_TO_LEVEL == -2 then
			take_screenshots_of_all_levels()
		elseif SHOULD_GO_TO_LEVEL == -3 then
			bruteforce_all_passcodes()
		elseif SHOULD_GO_TO_LEVEL > 0 and SHOULD_GO_TO_LEVEL <= 100 then
			go_to_level(SHOULD_GO_TO_LEVEL)
		end
		SHOULD_GO_TO_LEVEL = nil
	end
	if forms.ischecked(CHCK_SHOWPASSCODE) then
		draw_passcode()
	end

	emu.frameadvance()
end
