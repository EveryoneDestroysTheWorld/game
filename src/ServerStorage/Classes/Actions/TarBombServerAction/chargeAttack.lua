--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local TweenService = game:GetService("TweenService");

local displayObjects = ReplicatedStorage.Shared.InGameDisplayObjects;
local types = require(ServerStorage.Modules.types);

local animateSprite = require(ReplicatedStorage.Shared.Modules.animateSprite);

local function chargeAttack(action: types.TarBombServerAction, primaryPart: BasePart): ()

	local fireBreathChargeGUI = displayObjects:FindFirstChild("ChargeMeter"):Clone()
	fireBreathChargeGUI.Parent = primaryPart
	fireBreathChargeGUI.Adornee = primaryPart

	local data = {
		frameRate = 64/2,
		sprite = fireBreathChargeGUI.Sprite,
		spriteSheet = "8x8"
	}

	coroutine.wrap(animateSprite)(data, 1)

	local originalChargeTime = DateTime.now().UnixTimestampMillis;

	action.startChargeTimeMilliseconds = originalChargeTime;

	task.delay(action.maxChargeTimeMilliseconds / 1000, function()

		if action.startChargeTimeMilliseconds == originalChargeTime then

			task.delay(1/15, function()
      
				local highlight = Instance.new("Highlight", primaryPart.Parent)
				highlight.Name = "FullyChargedHighlight"
				highlight.OutlineTransparency = 1
				highlight.FillTransparency = 1
	
				while action.startChargeTimeMilliseconds == originalChargeTime do
	
					local tween = TweenService:Create(highlight, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 1, true), {FillTransparency = 0.7})
					tween:Play()
					task.wait(1)
	
				end

				highlight:Destroy();
	
			end)

		end;
	
	end);

end

return chargeAttack;