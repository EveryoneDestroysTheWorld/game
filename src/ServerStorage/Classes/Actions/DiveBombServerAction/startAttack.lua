--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney) and Hati (hati_bati)
-- © 2024 – 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");
local TweenService = game:GetService("TweenService");

local damageFramework = require(ServerStorage.Modules.DamageFramework);
local types = require(ServerStorage.Classes.types);

return function(action: types.DiveBombServerAction, primaryPart: BasePart, animations, coords: Vector3)

  local flightConstraint = primaryPart:FindFirstChild("FlightConstraint");

	if flightConstraint then

		flightConstraint:SetAttribute("PlayerControls", false);
    flightConstraint:Destroy()

	end
  
	primaryPart.CFrame = CFrame.lookAt((primaryPart.CFrame.Position), (coords * Vector3.new(1,0,1) + Vector3.new(0,primaryPart.CFrame.Position.Y, 0)));

	--perhaps some of this could be clientside
	local animData = Vector3.new(0.1,1,1)
	animations["Right"]:Play(animData.X,animData.Y,animData.Z);
	animations["Left"]:Play(animData.X,animData.Y,animData.Z);
	animations["Player"]:Play(animData.X,animData.Y,animData.Z);

	local part = Instance.new("Part");
	part.Parent = workspace.Terrain;
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1;

	local rigidConstraint = Instance.new("RigidConstraint");
	rigidConstraint.Parent = part;
	rigidConstraint.Attachment0 = Instance.new("Attachment", part);

	part.CFrame = primaryPart.CFrame
	rigidConstraint.Attachment1 = primaryPart:FindFirstChild("RootAttachment") :: Attachment;

	local expectedPos;

	for i = 1, 5 do

		expectedPos = part.Position + (( part.CFrame.LookVector * -1 + Vector3.new(0,1/5,0)) * (5-i)) + ((part.CFrame.LookVector + Vector3.new(0,1/5,0)) * (i))
		local tween = TweenService:Create(part, TweenInfo.new(0.75/5, Enum.EasingStyle.Linear), {Position = expectedPos})
		tween:Play()
		task.wait(0.75/5);

	end
	animations["Right"]:AdjustSpeed(1.5);
	animations["Left"]:AdjustSpeed(1.5);
	animations["Player"]:AdjustSpeed(1.5);
	
	local travelTime = 8/15
	local tween = TweenService:Create(part, TweenInfo.new(travelTime, Enum.EasingStyle.Linear), {
		Position = coords + Vector3.new(0, 0, 0);
	});
	tween:Play();
	task.wait(travelTime*0.8);

	local data = {}
	damageFramework.explosionEvent(coords, data, action.round, action.contestant, action)

	task.wait(travelTime*0.2);
	
	animations["Right"]:AdjustSpeed(1);
	animations["Left"]:AdjustSpeed(1);
	animations["Player"]:AdjustSpeed(1);
	task.wait(0.2)
	part:Destroy();

end;