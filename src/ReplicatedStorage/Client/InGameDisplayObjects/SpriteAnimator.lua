--!strict
-- Programmer: Hati (hati_bati)
-- © 2024 Beastslash LLC

local module = {}


function module.animateSprite(data, target)
	local size = data.Sprite.ImageRectSize
	local x = string.split(data.SpriteSheet, "x")
	local y = tonumber(x[2])
	x = tonumber(x[1])

	if target <= 1 then
		target = ((x * y) * target)
	end
	data.Sprite:SetAttribute("Goal", target)
	local currentFrame = data.Sprite.ImageRectOffset
	local Xoffset = math.floor(data.Sprite.ImageRectOffset.X / size.X)
	local Yoffset = math.floor(data.Sprite.ImageRectOffset.Y / size.Y)
	local frame = Yoffset * y + Xoffset 
	if frame < target then
		for i=1, (target - frame) do
			data.Sprite.ImageRectOffset = Vector2.new((size.X * Xoffset),(size.Y * Yoffset))
			if Xoffset + 1 >= x then
				Yoffset+= 1
				Xoffset = 0
			else
				Xoffset += 1
			end
			task.wait(1/data.FrameRate)
			if data.Sprite:GetAttribute("Goal") ~= target then
				break
			end
		end
	elseif frame > target then
		for i=1, (frame - target + 1) do
			data.Sprite.ImageRectOffset = Vector2.new((size.X * Xoffset),(size.Y * Yoffset))
			if Xoffset <= 0 then
				Yoffset-= 1
				Xoffset = x - 1
			else
				Xoffset -= 1
			end
			task.wait(1/data.FrameRate)
			if data.Sprite:GetAttribute("Goal") ~= target then
				break
			end
		end
	else
		warn("TargetFrame is currentFrame????")
	end
end


return module
