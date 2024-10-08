--!strict
-- Programmer: Hati (hati_bati)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local RunService = game:GetService("RunService")
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");
local ClientAction = require(script.Parent.Parent.ClientAction);
local React = require(ReplicatedStorage.Shared.Packages.react);
local HUDButton = require(ReplicatedStorage.Client.ReactComponents.HUDButton);
type ClientAction = ClientAction.ClientAction;

local TarBombAction = {
	ID = 9;
	iconImage = "rbxassetid://17771917538";
	name = "Tar Bomb";
	description = "Launch a projectile at the target location which explodes after a small amount of time, spreading tar onto nearby targets. Tar covered targets are slowed and take flat additional damage from all sources.";
};

local function waitForServerResponse(coordinateData: Vector3): ()

	local connection: RBXScriptConnection;

	connection = Players.LocalPlayer.ChildAdded:Connect(function(child: Instance)

		if child:IsA("RemoteEvent") and child.Name == "GetData" then

			--data request recieved from server
			connection:Disconnect()
			child:FireServer(coordinateData)
			--sent data back to server

		end

	end)

end



local playerDisplay = {}
local function displayTarget(state: "Start" | "Release"): ()

	if state == "Start" then
		
		playerDisplay["obj"] = ReplicatedStorage.Client.InGameDisplayObjects.DraconicKnight.DiveBombIndicator:Clone()
		playerDisplay["obj"].Root.Position = Players.LocalPlayer:GetMouse().Hit.Position + Vector3.new(0,0.5,0)
		playerDisplay["obj"].Parent = workspace.Terrain
		playerDisplay["obj"]:FindFirstChild("Beam", true).Attachment1 = Players.LocalPlayer.Character.HumanoidRootPart.RootAttachment
		playerDisplay["con"] = RunService.Stepped:Connect(function()

			playerDisplay["obj"].Root.Position = Players.LocalPlayer:GetMouse().Hit.Position + Vector3.new(0,0.5,0)

		end)
		
	else

		playerDisplay["obj"]:Destroy()
		playerDisplay["con"]:Disconnect()

	end

end

function TarBombAction.new(): ClientAction

	local player: Player;
	local remoteName: string;

	local function breakdown(self: ClientAction)

		ContextActionService:UnbindAction("ActivateTarBomb");

	end;

	local function activate(self: ClientAction)

		waitForServerResponse(player:GetMouse().Hit.Position)
		ReplicatedStorage.Shared.Functions.ActionFunctions:FindFirstChild(remoteName):InvokeServer();

	end;

	local function initialize(self: ClientAction)

		ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Action", React.createElement(HUDButton, {
			type = "Action";
			onActivate = function()

				self:activate("Input");

			end;
			shortcutCharacter = "1";
			iconImage = "rbxassetid://17771917538";
		}));

		player = Players.LocalPlayer;
		remoteName = `{player.UserId}_{self.ID}`;

		local function checkJump(_, inputState: Enum.UserInputState)

			if inputState == Enum.UserInputState.Begin then
				
				displayTarget("Start")

			elseif inputState == Enum.UserInputState.End then

				displayTarget("Release")
				self:activate();

			end

		end;

		ContextActionService:BindActionAtPriority("ActivateTarBomb", checkJump, false, 2, Enum.KeyCode.Q);


		workspace.Terrain.ChildAdded:Connect(function(child)
			if child.Name == "TarBomb" then
				local connection
				task.wait(0.2)
				connection = child.Touched:Connect(function(touched)
					connection:Disconnect()
					child.AssemblyLinearVelocity = Vector3.new(0,0,0)
				end)
			end
		
		end)

		
	end;

	return ClientAction.new({
		ID = TarBombAction.ID;
		iconImage = TarBombAction.iconImage;
		name = TarBombAction.name;
		description = TarBombAction.description;
		activate = activate;
		breakdown = breakdown;
		initialize = initialize;
	});

end

return TarBombAction;