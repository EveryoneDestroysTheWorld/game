--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designer: Hati (hati_bati)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local RunService = game:GetService("RunService")
local Players = game:GetService("Players");

local targetingFramework = {}

local playerDisplay = {
	isFree = false;
}

playerDisplay["charge"] = 0
function targetingFramework:getData(): (Vector3, boolean)

	local coordinates;
	local shouldUseTarget = false;
	--data request received from server
	if playerDisplay.isFree or not Players.LocalPlayer.Character:FindFirstChild("TargetLocal") then

		coordinates = Players.LocalPlayer:GetMouse().Hit.Position;

	else
		
		coordinates = Players.LocalPlayer.Character.TargetLocal.Value.PrimaryPart.Position;
		shouldUseTarget = true;

	end
	
	return coordinates, shouldUseTarget;

end

function targetingFramework.displayTarget(state: "Start" | "Release"): ()

	if state == "Start" then

		playerDisplay["obj"] = ReplicatedStorage.Shared.InGameDisplayObjects.DiveBombIndicator:Clone()
	--	playerDisplay["obj"].Root.Position = Players.LocalPlayer:GetMouse().Hit.Position + Vector3.new(0,0.5,0)
		playerDisplay["obj"].Parent = workspace.Terrain
		playerDisplay["obj"]:FindFirstChild("Beam", true).Attachment1 = Players.LocalPlayer.Character.HumanoidRootPart.RootAttachment
		local target = Players.LocalPlayer.Character:FindFirstChild("Target") or Players.LocalPlayer.Character:FindFirstChild("LocalTarget")
		if target and target.Value ~= nil then
			playerDisplay.isFree = false
		end

		playerDisplay["mouseCon"] = Players.LocalPlayer:GetMouse().Move:Connect(function()
			playerDisplay.isFree = true
			playerDisplay["mouseCon"]:Disconnect()
		end)

		playerDisplay["con"] = RunService.Stepped:Connect(function()
			local target = Players.LocalPlayer.Character:FindFirstChild("Target") or Players.LocalPlayer.Character:FindFirstChild("LocalTarget")
			if target and not target.Value and not playerDisplay.isFree then
				
				playerDisplay["obj"].Root.Position = target.Value.PrimaryPart.Position + Vector3.new(0, -0.5, 0)

			else

				playerDisplay["obj"].Root.Position = Players.LocalPlayer:GetMouse().Hit.Position + Vector3.new(0, 0.5, 0)

			end
		end)
		
	else

		playerDisplay["obj"]:Destroy()
		playerDisplay["con"]:Disconnect()
		playerDisplay["mouseCon"]:Disconnect()
		
	end

end

return targetingFramework