-- Author: Denilson Sá (AKA CrazyTerabyte)
-- 2015-02-27

while true do

	HP = mainmemory.readbyte(0x03D3);
	MAX = 150;

	if HP > 0 and HP <= MAX then
		-- Color is 0xAARRGGBB.
		gui.drawRectangle(0,144-16, HP,8, 0, 0xFFFF0000);
		gui.drawRectangle(0,144-16, MAX,7, 0xFFFFFFFF, 0);
	end;

	emu.frameadvance();

end
