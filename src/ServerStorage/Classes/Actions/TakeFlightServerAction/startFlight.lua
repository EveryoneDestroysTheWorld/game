--!strict
-- Programmer: Hati (hati_bati)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local RunService = game:GetService("RunService");
local ServerStorage = game:GetService("ServerStorage");
local TweenService = game:GetService("TweenService");

local types = require(ServerStorage.Modules.types);

local function startFlight(action: types.TakeFlightServerAction, contestant: types.ServerContestant, primaryPart: BasePart)

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
	action.linearVelocity = linearVelocity;

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

	task.spawn(function()
	
		while action.linearVelocity == linearVelocity and RunService.Stepped:Wait() do

			local verticalVelocity = if humanoid.Jump then 0.8 else 0;
			local value = (humanoid.MoveDirection) + Vector3.new(0,verticalVelocity,0)
			local tween = TweenService:Create(linearVelocity, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {VectorVelocity = value * 20})
			tween:Play()

		end;

	end);

	while contestant.currentStamina <= 0 or not primaryPart:FindFirstChild("FlightConstraint") or action.linearVelocity ~= linearVelocity and task.wait(0.25) do

		contestant:updateStamina(math.max(0, contestant.currentStamina - 2), {
			actionID = action.id;
			contestantID = contestant.id;
		});

	end;

	if contestant.currentStamina <= 0 then

		linearVelocity.LineDirection = Vector3.new(0, -8, 0);

	end
	
end

return startFlight;