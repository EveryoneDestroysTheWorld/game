--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

export type AnimationData = {
	frameRate: number;
	sprite: ImageLabel;
	spriteSheet: string;
}

local function animateSprite(data: AnimationData, target: number, loop: boolean?)
	
	local size = data.sprite.ImageRectSize;
	local dimensions = string.split(data.spriteSheet, "x");
	local x = tonumber(dimensions[1]);
	local y = tonumber(dimensions[2]);
	assert(x and y);

	if target <= 1 then

		target = ((x * y) * target)

	end

	data.sprite:SetAttribute("Goal", target);
	local xOffset = math.floor(data.sprite.ImageRectOffset.X / size.X)
	local yOffset = math.floor(data.sprite.ImageRectOffset.Y / size.Y)
	local frame = yOffset * y + xOffset 

	repeat
		
		if loop then

			frame = 0 
			xOffset = 0
			yOffset = 0
			
		end

		if frame < target then

			for i = 1, target - frame do

				data.sprite.ImageRectOffset = Vector2.new((size.X * xOffset), (size.Y * yOffset))

				if xOffset + 1 >= x then

					yOffset+= 1
					xOffset = 0
					
				else

					xOffset += 1

				end

				task.wait(1 / data.frameRate);

				if data.sprite:GetAttribute("Goal") ~= target then

					break

				end

			end

		elseif frame > target then

			for i = 1, frame - target + 1 do

				data.sprite.ImageRectOffset = Vector2.new((size.X * xOffset), (size.Y * yOffset))

				if xOffset <= 0 then

					yOffset -= 1
					xOffset = x - 1

				else

					xOffset -= 1

				end

				task.wait(1 / data.frameRate)

				if data.sprite:GetAttribute("Goal") ~= target then

					break

				end

			end

		else

			warn("TargetFrame is currentFrame????")

		end

	until not loop

end


return animateSprite;