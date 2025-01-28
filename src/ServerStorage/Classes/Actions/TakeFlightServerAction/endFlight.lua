--!strict
-- Programmer: Hati (hati_bati)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Classes.types);

local function endFlight(action: types.TakeFlightServerAction, primaryPart: BasePart): ()

	local linearVelocity = action.linearVelocity;
	if linearVelocity then

		linearVelocity:SetAttribute("PlayerControls", false);

		linearVelocity.VectorVelocity = Vector3.new(0,15,0)
		linearVelocity.MaxAxesForce = Vector3.new(math.huge,math.huge,math.huge);
		linearVelocity.Parent = primaryPart;
		linearVelocity.Attachment0 = primaryPart:FindFirstChild("RootAttachment") :: Attachment;

		task.wait(0.15)
		linearVelocity.VectorVelocity = primaryPart.CFrame.LookVector * 30
		task.delay(0.1, function()

			if action.linearVelocity and action.linearVelocity == linearVelocity then

				action.linearVelocity = nil;
				linearVelocity:Destroy();

			end;

		end);

	end;

end

return endFlight;