--!strict
-- Programmer: Hati (hati_bati)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");

local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local targetingFramework = require(ReplicatedStorage.Client.Modules.EasyTargetingFramework);
local SharedTypes = require(ReplicatedStorage.Client.Modules.SharedTypes);

local DiveBombClientAction = {
	id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
	iconImage = "rbxassetid://17771917538";
	name = "Dive Bomb";
	description = "Rush to target location, stunning enemies in an area and dealing damage to EVERYONE nearby.";
};

local player = Players.LocalPlayer;

function DiveBombClientAction.new(): SharedTypes.DiveBombClientAction

	local remoteName = `{player.UserId}_{DiveBombClientAction.id}`;

	local action: SharedTypes.DiveBombClientAction = {
		id = DiveBombClientAction.id;
		iconImage = DiveBombClientAction.iconImage;
		name = DiveBombClientAction.name;
		description = DiveBombClientAction.description;
		remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
		attributes = {};
		activate = function(self: SharedTypes.DiveBombClientAction)

			local coordinates, shouldUseTarget = targetingFramework:getData()
			self.remoteFunction:InvokeServer(coordinates, shouldUseTarget);
		
		end;
		breakdown = function(self: SharedTypes.DiveBombClientAction)

			ContextActionService:UnbindAction("ActivateDiveBomb");
			HUDService:removeHUDButton("Action", self.id);
		
		end;
	};

	HUDService:addHUDButton({
		type = "Action";
		key = action.id;
		onActivate = function()

			action:activate();

		end;
		shortcutCharacter = "1";
		iconImage = "rbxassetid://87098535403201";
	});

	player = Players.LocalPlayer;

	local function checkJump(_, inputState: Enum.UserInputState)

		if inputState == Enum.UserInputState.Begin then
			
			targetingFramework.displayTarget("Start")

		elseif inputState == Enum.UserInputState.End then

			targetingFramework.displayTarget("Release")
			action:activate();

		end

	end;

	ContextActionService:BindActionAtPriority("ActivateDiveBomb", checkJump, false, 2, Enum.KeyCode.Q);

	return action;

end

return DiveBombClientAction;