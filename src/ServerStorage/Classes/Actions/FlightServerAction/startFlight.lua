--!strict
-- Programmer: Hati (hati_bati)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");
local TweenService = game:GetService("TweenService");

local types = require(ServerStorage.Classes.types);

local function startFlight(contestant: types.ServerContestant, primaryPart: BasePart)

	--perhaps some of this could be clientside
	local linearVelocity = Instance.new("LinearVelocity");
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector;
 	 linearVelocity.Name = "FlightConstraint"
  	linearVelocity.VectorVelocity = Vector3.new(0,-5,0)
	linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	linearVelocity.MaxAxesForce = Vector3.new(0,math.huge,0);
	linearVelocity.Parent = primaryPart;
	linearVelocity.Attachment0 = primaryPart:FindFirstChild("RootAttachment") :: Attachment;
	linearVelocity:SetAttribute("PlayerControls", false);

	task.wait(0.3)

	linearVelocity.VectorVelocity = Vector3.new(0,50,0)

	local tween = TweenService:Create(linearVelocity, TweenInfo.new(1.0, Enum.EasingStyle.Sine), {VectorVelocity = Vector3.new(0,5,0)});
	tween:Play()
	task.wait(0.6)
	linearVelocity:SetAttribute("PlayerControls", true)
	local humanoid = (primaryPart.Parent :: Instance):FindFirstChild("Humanoid") :: Humanoid;
	local connection
	connection = humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function(change)

		if humanoid.FloorMaterial ~= Enum.Material.Air then

			connection:Disconnect()
			linearVelocity:Destroy()

		end

	end)

	repeat 

		task.wait(0.25)
		contestant:updateStamina(math.max(0, contestant.currentStamina - 2));

	until not linearVelocity:GetAttribute("PlayerControls") or contestant.currentStamina <= 0 or not primaryPart:FindFirstChild("FlightConstraint")

	if contestant.currentStamina <= 0 then

		linearVelocity:SetAttribute("PlayerControls", false)
		linearVelocity.LineDirection = Vector3.new(0, -8, 0);

	end
	
end

return startFlight;