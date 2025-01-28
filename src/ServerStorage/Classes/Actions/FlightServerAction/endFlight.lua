--!strict
-- Programmer: Hati (hati_bati)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local function endFlight(primaryPart: BasePart): ()

	local linearVelocity = primaryPart:FindFirstChild("FlightConstraint") :: LinearVelocity;
	linearVelocity:SetAttribute("PlayerControls", false);

	linearVelocity.VectorVelocity = Vector3.new(0,15,0)
	linearVelocity.MaxAxesForce = Vector3.new(math.huge,math.huge,math.huge);
	linearVelocity.Parent = primaryPart;
	linearVelocity.Attachment0 = primaryPart:FindFirstChild("RootAttachment") :: Attachment;

	task.wait(0.15)
	linearVelocity.VectorVelocity = primaryPart.CFrame.LookVector * 30
	task.delay(0.1, function()

		linearVelocity:Destroy();

	end);

end

return endFlight;