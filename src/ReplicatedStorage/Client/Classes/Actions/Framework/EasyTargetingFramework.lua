--!strict
-- Programmer: Hati (hati_bati)
-- Designer: Hati (hati_bati)
-- © 2024 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local RunService = game:GetService("RunService")
local Players = game:GetService("Players");

targetingFramework = {}

local playerDisplay = {}
playerDisplay["charge"] = 0
function targetingFramework.waitForServerResponse(actionName, charge): ()

	local connection: RBXScriptConnection;

	connection = Players.LocalPlayer.ChildAdded:Connect(function(child: Instance)

		if child:IsA("RemoteEvent") and child.Name == "GetData" then
			local charge  = playerDisplay["charge"]
			--data request recieved from server
			connection:Disconnect()
			if playerDisplay["free"] == true or not Players.LocalPlayer.Character:FindFirstChild("TargetLocal") then
				print(charge)
				child:FireServer(Players.LocalPlayer:GetMouse().Hit.Position + Vector3.new(0,4,0), false, charge)
			else
				local useTarget = true
				print(charge)
				child:FireServer(Players.LocalPlayer.Character.TargetLocal.Value.PrimaryPart.Position, useTarget, charge)
			end
			playerDisplay["charge"] = 0
			--sent data back to server

		end

	end)

end


function targetingFramework.displayTarget(state: "Start" | "Release"): ()

	if state == "Start" then
		playerDisplay["obj"] = ReplicatedStorage.Client.InGameDisplayObjects.DraconicKnight.DiveBombIndicator:Clone()
	--	playerDisplay["obj"].Root.Position = Players.LocalPlayer:GetMouse().Hit.Position + Vector3.new(0,0.5,0)
		playerDisplay["obj"].Parent = workspace.Terrain
		playerDisplay["obj"]:FindFirstChild("Beam", true).Attachment1 = Players.LocalPlayer.Character.HumanoidRootPart.RootAttachment
		local target = Players.LocalPlayer.Character:FindFirstChild("Target") or Players.LocalPlayer.Character:FindFirstChild("LocalTarget")
		if target and target.Value ~= nil then
			playerDisplay["free"] = false
		end

		playerDisplay["mouseCon"] = Players.LocalPlayer:GetMouse().Move:Connect(function()
			playerDisplay["free"] = true
			playerDisplay["mouseCon"]:Disconnect()
		end)

		playerDisplay["con"] = RunService.Stepped:Connect(function()
			local target = Players.LocalPlayer.Character:FindFirstChild("Target") or Players.LocalPlayer.Character:FindFirstChild("LocalTarget")
			if target and target.Value ~= nil and playerDisplay["free"] ~= true then
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