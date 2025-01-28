--!strict
-- Programmer: Hati (hati_bati)
-- © 2024 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");
local ClientAction = require(script.Parent.Parent.ClientAction);
local React = require(ReplicatedStorage.Shared.Packages.react);

local targetingGUI

local previousTargets = {}
local held = false

local LockOnClientAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
	iconImage = "rbxassetid://17771917538";
	name = "Lock On";
	description = "Lock on to enemies and friends";
};

local function targetCamera(target)
	local recentMoveDirection = {}
	if not targetingGUI then
		targetingGUI = ReplicatedStorage.Client:WaitForChild("InGameDisplayObjects"):WaitForChild("TargetingFrame"):Clone()
		targetingGUI.Parent = workspace.Terrain
	end
	targetingGUI.Adornee = target
	local previousCFrame = Players.LocalPlayer.Character.Head.Neck.C1
	local function updateCameraToTarget()
		workspace.Camera.CameraType = Enum.CameraType.Scriptable
		local cameraPosition = (CFrame.lookAt(target.HumanoidRootPart.Position, Players.LocalPlayer.Character.HumanoidRootPart.Position).Rotation + Players.LocalPlayer.Character.HumanoidRootPart.Position) * CFrame.new(Vector3.new(0,10,-15)).Position
		workspace.Camera.CFrame = workspace.Camera.CFrame:Lerp(CFrame.lookAt(cameraPosition, target.HumanoidRootPart.Position + Players.LocalPlayer.Character.Humanoid.MoveDirection * ((target.HumanoidRootPart.Position - Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude * 0.4)), 0.1)
		workspace.Camera.Focus = target.HumanoidRootPart.CFrame

		-- this is what causes the player's head to move
		local rotation = CFrame.lookAt(Players.LocalPlayer.Character.Head.Position,target.Head.Position).Rotation:Inverse() * (Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Rotation) 
		local x,y,z = rotation:ToOrientation()

		if math.abs(y) < 2.2 then
			Players.LocalPlayer.Character.Head.Neck.C1 = Players.LocalPlayer.Character.Head.Neck.C1:Lerp((rotation + Players.LocalPlayer.Character.Head.Neck.C1.Position), 0.1)
		else
			Players.LocalPlayer.Character.Head.Neck.C1 = Players.LocalPlayer.Character.Head.Neck.C1:Lerp(CFrame.new(Players.LocalPlayer.Character.Head.Neck.C1.Position), 0.05)
		end	
		targetingGUI.TargetIcon.ImageTransparency = 1 - (target.HumanoidRootPart.Position - Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude /50
		targetingGUI.TeamColor.ImageTransparency = 1 - (target.HumanoidRootPart.Position - Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude /50
		previousCFrame = Players.LocalPlayer.Character.Head.Neck.C1
		
	end


	if target then
		if not Players.LocalPlayer.Character:FindFirstChild("TargetLocal") then
			local targetValue = Instance.new("ObjectValue", Players.LocalPlayer.Character)
			targetValue.Name = "TargetLocal"
		end	
		Players.LocalPlayer.Character:FindFirstChild("TargetLocal").Value = target
		game:GetService("RunService"):UnbindFromRenderStep("updateCam")
		game:GetService("RunService"):BindToRenderStep("updateCam", 2, updateCameraToTarget)
	else
		Players.LocalPlayer.Character:FindFirstChild("TargetLocal"):Destroy()
		game:GetService("RunService"):UnbindFromRenderStep("updateCam")
		workspace.Camera.CameraType = Enum.CameraType.Follow
		local connection
		local i = 0
		connection = game:GetService("RunService").RenderStepped:Connect(function()
			i+=1
			Players.LocalPlayer.Character.Head.Neck.C1 = Players.LocalPlayer.Character.Head.Neck.C1:Lerp(CFrame.new(Players.LocalPlayer.Character.Head.Neck.C1.Position), 0.025*i)
			if i > 40 then
				connection:Disconnect()
			end
		end)
	end
end

function lockOn()
	local target

	local Oparams = OverlapParams.new()
	local validTargets = {}
	Oparams.FilterType = Enum.RaycastFilterType.Include
	for i, item in ipairs(workspace:GetChildren()) do
		if item:IsA("Model") and item:FindFirstChild("Humanoid") and item.Name ~= Players.LocalPlayer.Name then
			table.insert(validTargets,item.HumanoidRootPart)
		end
	end
	Oparams.FilterDescendantsInstances = validTargets
	local possibleTargets = workspace:GetPartBoundsInRadius(Players.LocalPlayer.Character.HumanoidRootPart.Position, 100, Oparams)
	if #possibleTargets > 0 then
		if #possibleTargets > 1 then

			local RParams = RaycastParams.new()
			RParams.FilterType = Enum.RaycastFilterType.Include
			local exclude = possibleTargets
			local raycastResult
			local size = 20
			repeat 
				local rayorgin
				if size < 20 then
					rayorgin = workspace.Camera.CFrame.Rotation + (Vector3.new(0, 4, 0) + Players.LocalPlayer.Character.HumanoidRootPart.Position)
					size += 20
				else
					size += 20
					rayorgin = workspace.Camera.CFrame
				end

				local rayDirection = (rayorgin * CFrame.new(Vector3.new(0, 20, -size))).Position
				rayDirection -= rayorgin.Position
				RParams.FilterDescendantsInstances = exclude
				raycastResult = workspace:Blockcast(rayorgin, Vector3.new(size,size,size), rayDirection, RParams)


				if raycastResult then
					if table.find(previousTargets, raycastResult.Instance) then
						--print(raycastResult.Instance.Parent.Name .. " was targeted previously, searching for new target")
						local i = 0
						repeat
							i+= 1
							if raycastResult then
								table.remove(exclude, table.find(exclude, raycastResult.Instance))

								if i >= #possibleTargets then
									--print("All possible targets were targeted previously, resetting previous targets")
									previousTargets = {}
									exclude = possibleTargets
								end
								RParams.FilterDescendantsInstances = exclude
								raycastResult = workspace:Blockcast(rayorgin, Vector3.new(size,size,size), rayDirection, RParams)
							end
							task.wait()
						until raycastResult and not table.find(previousTargets, raycastResult.Instance) or i > #possibleTargets * 2
					end

				end
				if not raycastResult then
					task.wait()
				end

			until raycastResult or size > 200
			if raycastResult then
			target = raycastResult.Instance:FindFirstAncestorOfClass("Model")
			end
		else
			target = possibleTargets[1]:FindFirstAncestorOfClass("Model")
		end
		if target then
		table.insert(previousTargets, target.HumanoidRootPart)
		end
	else
		--warn("no valid targets")
	end

	return target
end

type ClientAction = ClientAction.ClientAction;

function LockOnClientAction.new(): ClientAction

	local target = nil
	local player = Players.LocalPlayer;

	local function breakdown(self: ClientAction)

		ContextActionService:UnbindAction("ActivateMelee");

	end;

	local inputCount = 0
	local function initialize(self: ClientAction)

		remoteName = `{player.UserId}_{self.id}`;
		
		local function checkJump(_, inputState: Enum.UserInputState)

			if inputState == Enum.UserInputState.Begin then

				local savedValue = inputCount
				target = lockOn()
				task.delay(0.3, function()

					if inputCount == savedValue then

						held = true
						targetCamera()

					end
				end)
				targetCamera(target)

			elseif inputState == Enum.UserInputState.End then

				if held then

					held = false

				else

					self:activate()

				end

				inputCount += 1
				
			end
		end;

		ContextActionService:BindActionAtPriority("Lock On", checkJump, false, 2, Enum.KeyCode.Tab);

	end;

	return ClientAction.new({
		id = LockOnClientAction.id;
		iconImage = LockOnClientAction.iconImage;
		name = LockOnClientAction.name;
		description = LockOnClientAction.description;
		breakdown = breakdown;
		initialize = initialize;
	});

end

return LockOnClientAction;