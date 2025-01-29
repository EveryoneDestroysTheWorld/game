--!strict
-- Programmer: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");

local React = require(ReplicatedStorage.Shared.Packages.react);
local HUDButton = require(ReplicatedStorage.Client.ReactComponents.HUDButton);
local targetingFramework = require(ReplicatedStorage.Client.Modules.EasyTargetingFramework);
local types = require(ReplicatedStorage.Client.Modules.types);

local TarBombClientAction = {
	id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
	iconImage = "rbxassetid://17771917538";
	name = "Tar Bomb";
	description = "Launch a projectile at the target location which explodes after a small amount of time, spreading tar onto nearby targets. Tar covered targets are slowed and take flat additional damage from all sources.";
	__index = {} :: types.TarBombClientAction;
};

function TarBombClientAction.new(): types.TarBombClientAction

	local player = Players.LocalPlayer;
	local remoteName = `{player.UserId}_{TarBombClientAction.id}`

	local overwrittenProperties = {
		id = TarBombClientAction.id;
		iconImage = TarBombClientAction.iconImage;
		name = TarBombClientAction.name;
		description = TarBombClientAction.description;
		remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
	}

	local action = (setmetatable(overwrittenProperties, TarBombClientAction) :: any) :: types.TarBombClientAction;

	ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Action", React.createElement(HUDButton, {
		type = "Action";
		key = action.id;
		onActivate = function()

			action:activate(false);

		end;
		shortcutCharacter = "1";
		iconImage = "rbxassetid://73246050129377";
	}));

	local function checkJump(_, inputState: Enum.UserInputState)

		if inputState == Enum.UserInputState.Begin then
			
			targetingFramework.displayTarget("Start")
			action:activate(true);

		elseif inputState == Enum.UserInputState.End then

			targetingFramework.displayTarget("Release")
			action:activate(false, nil, true);

		end

	end;

	ContextActionService:BindActionAtPriority("ActivateTarBomb", checkJump, false, 2, Enum.KeyCode.One);

	workspace.Terrain.ChildAdded:Connect(function(child)

		if child.Name == "TarBomb" then

			task.wait(0.2)
			child.Touched:Once(function(touched)

				child.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

			end)
		end
	
	end)

	return action;

end

function TarBombClientAction.__index:activate(shouldCharge: boolean, coordinates: boolean)

	self.remoteFunction:InvokeServer(shouldCharge, Players.LocalPlayer:GetMouse().Hit.Position);

end

function TarBombClientAction.__index:breakdown()

	ContextActionService:UnbindAction("ActivateTarBomb");
	ReplicatedStorage.Client.Functions.DestroyHUDButton:Invoke("Action", self.id);

end

return TarBombClientAction;