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
	chargeTime = 0;
}

playerDisplay["charge"] = 0
function targetingFramework:getData(): (Vector3, boolean, number)

	local coordinates;
	local shouldUseTarget = false;
	local chargeTime = playerDisplay.chargeTime;

	--data request received from server
	if playerDisplay.isFree or not Players.LocalPlayer.Character:FindFirstChild("TargetLocal") then

		coordinates = Players.LocalPlayer:GetMouse().Hit.Position;

	else
		
		coordinates = Players.LocalPlayer.Character.TargetLocal.Value.PrimaryPart.Position;
		shouldUseTarget = true;

	end

	--sent data back to server
	playerDisplay.chargeTime = 0;
	
	return coordinates, shouldUseTarget, chargeTime;

end

function targetingFramework.displayTarget(state: "Start" | "Release"): ()

	if state == "Start" then
		playerDisplay["obj"] = ReplicatedStorage.Client.InGameDisplayObjects.DraconicKnight.DiveBombIndicator:Clone()
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
				playerDisplay["obj"].Root.Position = target.Value.PrimaryPart.Position + Vector3.new(0,-0.5,0)
			else
				playerDisplay["obj"].Root.Position = Players.LocalPlayer:GetMouse().Hit.Position + Vector3.new(0,0.5,0)
			end
		end)
		task.delay(0.1, function()
			playerDisplay["charge"] = 0
			repeat 
				playerDisplay["charge"] += 2
				task.wait(1/15)
			until playerDisplay["charge"] == 0 or playerDisplay["charge"] >= 100
		end)
	else
		playerDisplay["obj"]:Destroy()
		playerDisplay["con"]:Disconnect()
		playerDisplay["mouseCon"]:Disconnect()
	end

end






return targetingFramework