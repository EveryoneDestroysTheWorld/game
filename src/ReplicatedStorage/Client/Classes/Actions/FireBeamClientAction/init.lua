--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");
local UserInputService = game:GetService("UserInputService");
local RunService = game:GetService("RunService");

local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local targetingFramework = require(ReplicatedStorage.Client.Modules.EasyTargetingFramework);
local LocalTypes = require(script.types);

local FireBeamClientAction = {
	id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
	iconImage = "rbxassetid://17771917538";
	name = "Fire Beam";
	description = "Charge by holding down while flying, and release to fire a beam that lights the ground on fire.";
};

local player = Players.LocalPlayer;

function FireBeamClientAction.new(): LocalTypes.FireBeamClientAction

	local remoteName = `{player.UserId}_{FireBeamClientAction.id}`;
	local remoteEvent = ReplicatedStorage.Shared.Events.ActionEvents:WaitForChild(remoteName);
	local action: LocalTypes.FireBeamClientAction = {
		id = FireBeamClientAction.id;
		iconImage = FireBeamClientAction.iconImage;
		name = FireBeamClientAction.name;
		description = FireBeamClientAction.description;
		remoteEvent = remoteEvent;
		remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
		attributes = {
			isCharging = false;
		};
		activate = function(self: LocalTypes.FireBeamClientAction)

			self.remoteFunction:InvokeServer(self.attributes.isCharging);

		end;
		breakdown = function(self: LocalTypes.FireBeamClientAction)

			ContextActionService:UnbindAction("ActivateFireBeam");
			HUDService:removeHUDButton("Action", self.id);

		end;
	};

	local shouldIgnoreInput = false;
	local function checkInput(_, inputState: Enum.UserInputState)

		if inputState == Enum.UserInputState.Begin then
			
			targetingFramework.displayTarget("Start");
			action.attributes.isCharging = true;
			action:activate();

		elseif inputState == Enum.UserInputState.End then

			if shouldIgnoreInput then

				shouldIgnoreInput = false;

			else

				targetingFramework.displayTarget("Release");
				action.attributes.isCharging = false;
				action:activate();

			end;

		end

	end;

	remoteEvent.OnClientEvent:Connect(function(shouldActivateUpdateTask)

		if shouldActivateUpdateTask then

			action.attributes.updateTask = action.attributes.updateTask or task.spawn(function()

				while RunService.RenderStepped:Wait() do

					local mousePosition = UserInputService:GetMouseLocation();
					local unitRay = workspace.CurrentCamera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
					local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000);
					local position = if raycastResult then raycastResult.Position else unitRay.Direction * 1000;
					remoteEvent:FireServer(position);

				end;
			
			end);

		else

			if action.attributes.updateTask then

				task.cancel(action.attributes.updateTask);
				action.attributes.updateTask = nil;
				
			end;

		end;

	end);

	HUDService:addHUDButton({
		type = "Action";
		key = action.id;
		onActivate = function()

			action.attributes.isCharging = not action.attributes.isCharging;
			action:activate();

		end;
		shortcutCharacter = "1";
		iconImage = action.iconImage;
	});

	ContextActionService:BindAction("ActivateFireBeam", checkInput, false, Enum.KeyCode.Two, Enum.KeyCode.KeypadTwo);

	return action;

end

return FireBeamClientAction;