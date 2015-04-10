-- Author: Denilson Sá (AKA CrazyTerabyte)
-- 2015-03-07

-- Sprite Table for Disney's Aladdin
SPRITE_TABLE = 0xF400
-- Information about sprite table layout: http://md.squee.co/wiki/VDP#Sprites


function get_sprite_pattern(index)
	local data

	memory.usememorydomain("VRAM")
	data = memory.read_u16_be(SPRITE_TABLE + 8*index + 2*2)
	return bit.band(data, 0x7FF)
end


function set_sprite_x(index, pos)
	memory.usememorydomain("VRAM")
	pos = bit.band(pos, 0x1FF)
	memory.write_u16_be(SPRITE_TABLE + 8*index + 3*2, pos)
end


function set_sprite_priority(index, priority)
	local data
	memory.usememorydomain("VRAM")
	data = memory.read_u16_be(SPRITE_TABLE + 8*index + 2*2)
	if priority == 1 then
		data = bit.bor(data, 0x8000)
	elseif priority == 0 then
		data = bit.band(data, 0x7FFF)
	end
	memory.write_u16_be(SPRITE_TABLE + 8*index + 2*2, data)
end


FORM = forms.newform(160, 96, "Aladdin")
CHECK_HIDE_HUD = forms.checkbox(FORM, "Hide HUD", 0, 0)
CHECK_SPRITES_ON_TOP = forms.checkbox(FORM, "Sprites on-top", 0, 24)
CHECK_HIDE_SPRITES = forms.checkbox(FORM, "Hide all sprites", 0, 48)

while true do

	for i = 0, 160, 1 do
		local pat = get_sprite_pattern(i)
		if
			(pat >= 0x680 and pat <= 0x6FF)  -- Health, Lives, Apples, Gems
			or (pat >= 0x7C0 and pat <= 0x7E4)  -- Score
		then
			if forms.ischecked(CHECK_HIDE_HUD) then
				-- 32 is to the left, outside the screen
				set_sprite_x(i, 32)
			end
		else
			if forms.ischecked(CHECK_SPRITES_ON_TOP) then
				-- Set all other sprites above the layers
				set_sprite_priority(i, 1)
			end
			if forms.ischecked(CHECK_HIDE_SPRITES) then
				-- 32 is to the left, outside the screen
				set_sprite_x(i, 32)
			end
		end
	end
	emu.frameadvance()

end
