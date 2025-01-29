--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney) and Hati (hati_bati)
-- © 2024 – 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");
local TweenService = game:GetService("TweenService");

local damageFramework = require(ServerStorage.Modules.DamageFramework);
local types = require(ServerStorage.Modules.types);

return function(action: types.DiveBombServerAction, primaryPart: BasePart, animations, coords: Vector3, shouldUseTarget: boolean)
  
	local character = action.contestant.character;
	assert(character);

  if shouldUseTarget then 

		local objectValue = character:FindFirstChild("Target") :: ObjectValue;
		if objectValue.Value and objectValue.Value:IsA("Model") and objectValue.Value.PrimaryPart then

			coords = objectValue.Value.PrimaryPart.Position;

		end;

	end

	local targetCoords
	local originalCoords = coords
	primaryPart.CFrame = CFrame.lookAt((primaryPart.CFrame.Position), (coords * Vector3.new(1,0,1) + Vector3.new(0,primaryPart.CFrame.Position.Y, 0)));
	if (coords - primaryPart.Position).Magnitude > 50 then
		
		coords = (primaryPart.CFrame * CFrame.new(Vector3.new(0,0,-1 * (50)))).Position
		targetCoords = coords
		originalCoords = targetCoords
	else
		targetCoords = coords
		coords = CFrame.lookAt(coords, primaryPart.Position) * CFrame.new(Vector3.new(0,0,10)).Position
	end

	--perhaps some of this could be clientside
	local animData = Vector3.new(0.2,1,3)
	animations["Right"]:Play(animData.X,animData.Y,animData.Z);
	animations["Left"]:Play(animData.X,animData.Y,animData.Z);
	animations["Player"]:Play(animData.X,animData.Y,animData.Z);
	
	local part = Instance.new("Part");
	part.Parent = workspace.Terrain;
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1;
	task.wait(0.1)
	local rigidConstraint = Instance.new("RigidConstraint");
	rigidConstraint.Parent = part;
	rigidConstraint.Attachment0 = Instance.new("Attachment", part);

	part.CFrame = primaryPart.CFrame
	rigidConstraint.Attachment1 = primaryPart:FindFirstChild("RootAttachment") :: Attachment;
	
	animations["Right"]:AdjustSpeed(2);
	animations["Left"]:AdjustSpeed(2);
	animations["Player"]:AdjustSpeed(2);
	
	local travelTime = 8/15
	local tween = TweenService:Create(part, TweenInfo.new(travelTime, Enum.EasingStyle.Linear), {
		Position = coords + Vector3.new(0, 1, 0);
	});
	tween:Play();
	task.wait(travelTime*0.6);
	local data = {}
	damageFramework.explosionEvent(originalCoords, data, action.contestant.round, action.contestant, action);
	task.wait(travelTime*0.4);

	
	animations["Right"]:AdjustSpeed(1);
	animations["Left"]:AdjustSpeed(1);
	animations["Player"]:AdjustSpeed(1);
	task.wait(0.2)
	part:Destroy();

end;