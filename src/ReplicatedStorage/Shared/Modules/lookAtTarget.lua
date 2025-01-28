--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local Players = game:GetService("Players");

local function lookAtTarget(character: Model, targetModel: Model?, targetingGUI: BillboardGui?): ()

	if targetModel and targetingGUI then

		targetingGUI.Adornee = targetModel

	end;

	local player = Players.LocalPlayer;
	local characterHead = character:FindFirstChild("Head");
	local characterNeck = if characterHead then characterHead:FindFirstChild("Neck") else nil;
	assert(characterHead and characterHead:IsA("BasePart"));
	assert(characterNeck and characterNeck:IsA("Motor6D"));

	local function updateCameraToTarget()

		assert(targetModel);
		local targetPrimaryPart = targetModel.PrimaryPart;
		local characterPrimaryPart = character.PrimaryPart;
		local targetHead = targetModel:FindFirstChild("Head");
		local characterHumanoid = character:FindFirstChild("Humanoid");
		assert(targetPrimaryPart);
		assert(characterPrimaryPart);
		assert(targetHead and targetHead:IsA("BasePart"));
		assert(characterHumanoid and characterHumanoid:IsA("Humanoid"));

		if player then

			workspace.Camera.CameraType = Enum.CameraType.Scriptable
			local cameraPosition = (CFrame.lookAt(targetPrimaryPart.Position, characterPrimaryPart.Position).Rotation + characterPrimaryPart.Position) * CFrame.new(Vector3.new(0,10,-15)).Position
			workspace.Camera.CFrame = workspace.Camera.CFrame:Lerp(CFrame.lookAt(cameraPosition, targetPrimaryPart.Position + characterHumanoid.MoveDirection * ((targetPrimaryPart.Position - characterPrimaryPart.Position).Magnitude * 0.4)), 0.1)
			workspace.Camera.Focus = targetPrimaryPart.CFrame

		end;

		-- this is what causes the player's head to move
		local rotation = CFrame.lookAt(characterHead.Position, targetHead.Position).Rotation:Inverse() * (characterPrimaryPart.CFrame.Rotation) 
		local _, y = rotation:ToOrientation()

		characterNeck.C1 = (
			if math.abs(y) < 2.2 then
				characterNeck.C1:Lerp((rotation + characterNeck.C1.Position), 0.1)
			else
				characterNeck.C1:Lerp(CFrame.new(characterNeck.C1.Position), 0.05)
		)

		if targetingGUI then
			
			(targetingGUI:FindFirstChild("TargetIcon") :: ImageLabel).ImageTransparency = 1 - (targetPrimaryPart.Position - characterPrimaryPart.Position).Magnitude / 50
			(targetingGUI:FindFirstChild("TeamColor") :: ImageLabel).ImageTransparency = 1 - (targetPrimaryPart.Position - characterPrimaryPart.Position).Magnitude / 50

		end;
		
	end

	if targetModel then

		local targetLocal: ObjectValue;
		local existingTargetLocal = character:FindFirstChild("TargetLocal");
		if existingTargetLocal and existingTargetLocal:IsA("ObjectValue") then

			targetLocal = existingTargetLocal;

		else

			local newTargetLocal = Instance.new("ObjectValue", character)
			newTargetLocal.Name = "TargetLocal"
			targetLocal = newTargetLocal;

		end
		
		targetLocal.Value = targetModel
		game:GetService("RunService"):UnbindFromRenderStep("updateCam")
		game:GetService("RunService"):BindToRenderStep("updateCam", 2, updateCameraToTarget)

	else

		local targetLocal = character:FindFirstChild("TargetLocal");
		if targetLocal then
			
			targetLocal:Destroy();

		end

		game:GetService("RunService"):UnbindFromRenderStep("updateCam");

		if player then

			workspace.Camera.CameraType = Enum.CameraType.Follow

		end;

		local connection
		local i = 0
		connection = game:GetService("RunService").RenderStepped:Connect(function()

			i+=1

			characterNeck.C1 = characterNeck.C1:Lerp(
				CFrame.new(characterNeck.C1.Position), 0.025 * i
			)
			
			if i > 40 then

				connection:Disconnect()

			end

		end)
		
	end
	
end

return lookAtTarget;