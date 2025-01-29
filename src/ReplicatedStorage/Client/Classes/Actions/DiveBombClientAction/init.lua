--!strict
-- Programmer: Hati (hati_bati)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");

local React = require(ReplicatedStorage.Shared.Packages.react);
local HUDButton = require(ReplicatedStorage.Client.ReactComponents.HUDButton);
local targetingFramework = require(ReplicatedStorage.Client.Modules.EasyTargetingFramework);
local types = require(ReplicatedStorage.Client.Modules.types);

local DiveBombClientAction = {
	id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
	iconImage = "rbxassetid://17771917538";
	name = "Dive Bomb";
	description = "Rush to target location, stunning enemies in an area and dealing damage to EVERYONE nearby.";
	__index = {} :: types.DiveBombClientAction;
};

local player = Players.LocalPlayer;

function DiveBombClientAction.new(): types.DiveBombClientAction

	local remoteName = `{player.UserId}_{DiveBombClientAction.id}`;

	local overwrittenProperties = {
		id = DiveBombClientAction.id;
		iconImage = DiveBombClientAction.iconImage;
		name = DiveBombClientAction.name;
		description = DiveBombClientAction.description;
		remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
	};

  local action = (setmetatable(overwrittenProperties, DiveBombClientAction) :: any) :: types.DiveBombClientAction;

	ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Action", React.createElement(HUDButton, {
		type = "Action";
		key = action.id;
		onActivate = function()

			action:activate();

		end;
		shortcutCharacter = "1";
		iconImage = "rbxassetid://17771917538";
	}));

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

function DiveBombClientAction.__index:activate()
    
	local coordinates, shouldUseTarget = targetingFramework:getData()
	self.remoteFunction:InvokeServer(coordinates, shouldUseTarget);

end

function DiveBombClientAction.__index:breakdown()

	ContextActionService:UnbindAction("ActivateDiveBomb");
	ReplicatedStorage.Client.Functions.DestroyHUDButton:Invoke("Action", self.id);

end

return DiveBombClientAction;