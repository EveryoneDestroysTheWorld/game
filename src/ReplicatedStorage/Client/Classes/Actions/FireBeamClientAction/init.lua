--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");
local UserInputService = game:GetService("UserInputService");
local RunService = game:GetService("RunService");

local React = require(ReplicatedStorage.Shared.Packages.react);
local HUDButton = require(ReplicatedStorage.Client.ReactComponents.HUDButton);
local targetingFramework = require(ReplicatedStorage.Client.Modules.EasyTargetingFramework);
local types = require(ReplicatedStorage.Client.Modules.types);

local FireBeamClientAction = {
	id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
	iconImage = "rbxassetid://17771917538";
	name = "Fire Beam";
	description = "Charge by holding down while flying, and release to fire a beam that lights the ground on fire.";
	__index = {} :: types.FireBeamClientAction;
};

local player = Players.LocalPlayer;

function FireBeamClientAction.new(): types.FireBeamClientAction

	local remoteName = `{player.UserId}_{FireBeamClientAction.id}`;

	local overwrittenProperties = {
		id = FireBeamClientAction.id;
		iconImage = FireBeamClientAction.iconImage;
		name = FireBeamClientAction.name;
		description = FireBeamClientAction.description;
		remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
		isCharging = false;
	};

  local action = (setmetatable(overwrittenProperties, FireBeamClientAction) :: any) :: types.FireBeamClientAction;
	local updateTask: thread?;

	local remoteEvent = ReplicatedStorage.Shared.Events.ActionEvents:WaitForChild(remoteName);
	assert(remoteEvent:IsA("RemoteEvent"));
	
	local shouldIgnoreInput = false;
	local function checkJump(_, inputState: Enum.UserInputState)

		if inputState == Enum.UserInputState.Begin then
			
			targetingFramework.displayTarget("Start")
			action:activate(true);

		elseif inputState == Enum.UserInputState.End then

			if shouldIgnoreInput then

				shouldIgnoreInput = false;

			else

				if action.chargeNotificationTask then

					task.cancel(action.chargeNotificationTask);
					action.chargeNotificationTask = nil;

				end;

				targetingFramework.displayTarget("Release")
				action:activate(false, nil, true);

			end;

		end

	end;

	ContextActionService:BindAction("ActivateFireBeam", checkJump, false, Enum.KeyCode.Two, Enum.KeyCode.KeypadTwo);

	action.remoteEvent = remoteEvent.OnClientEvent:Connect(function(shouldActivateUpdateTask)

		if shouldActivateUpdateTask then

			updateTask = updateTask or task.spawn(function()

				while RunService.RenderStepped:Wait() do

					local mousePosition = UserInputService:GetMouseLocation();
					local unitRay = workspace.CurrentCamera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
					local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000);
					local position = if raycastResult then raycastResult.Position else unitRay.Direction * 1000;
					remoteEvent:FireServer(position);

				end;
			
			end);

		else

			if updateTask then

				task.cancel(updateTask);
				updateTask = nil;
				
			end;

		end;

	end);

	ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Action", React.createElement(HUDButton, {
		type = "Action";
		key = action.id;
		onActivate = function()

			action:activate("Input");

		end;
		shortcutCharacter = "1";
		iconImage = "rbxassetid://81218648792587";
	}));

	return action;

end

function FireBeamClientAction.__index:activate(shouldCharge: boolean)

	self.remoteFunction:InvokeServer(shouldCharge);

end

function FireBeamClientAction.__index:breakdown()

	ContextActionService:UnbindAction("ActivateFireBeam");
	ReplicatedStorage.Client.Functions.DestroyHUDButton:Invoke("Action", self.id);

end

return FireBeamClientAction;