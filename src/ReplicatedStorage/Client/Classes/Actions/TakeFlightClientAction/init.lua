--!strict
-- Programmers: Hati (hati_bati)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");

local React = require(ReplicatedStorage.Shared.Packages.react);
local HUDButton = require(ReplicatedStorage.Client.ReactComponents.HUDButton);
local types = require(ReplicatedStorage.Client.Modules.types);

local TakeFlightClientAction = {
	id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
	iconImage = "rbxassetid://17771917538";
	name = "Take Flight";
	description = "You are great at flying! I'm surprised those wings can carry you.";
	__index = {} :: types.TakeFlightClientAction;
};

local player = Players.LocalPlayer;

function TakeFlightClientAction.new(): types.TakeFlightClientAction

	local remoteName = `{player.UserId}_{TakeFlightClientAction.id}`;

	local overwrittenProperties = {
		id = TakeFlightClientAction.id;
		iconImage = TakeFlightClientAction.iconImage;
		name = TakeFlightClientAction.name;
		description = TakeFlightClientAction.description;
		remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
	};

  local action = (setmetatable(overwrittenProperties, TakeFlightClientAction) :: any) :: types.TakeFlightClientAction;

	ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Action", React.createElement(HUDButton, {
		type = "Action";
		key = action.id;
		onActivate = function()

			action:activate();

		end;
		shortcutCharacter = "Space";
		iconImage = "rbxassetid://92011231218008";
	}));

	local function checkJump(_, inputState: Enum.UserInputState)
		
		if inputState == Enum.UserInputState.Begin then

			action:activate();

		end;

	end;

	ContextActionService:BindActionAtPriority("ActivateTakeFlight", checkJump, false, 2, Enum.KeyCode.Space);

	return action;

end

function TakeFlightClientAction.__index:activate()

	self.remoteFunction:InvokeServer();

end;

function TakeFlightClientAction.__index:breakdown()

	ContextActionService:UnbindAction("ActivateTakeFlight");
	ReplicatedStorage.Client.Functions.DestroyHUDButton:Invoke("Action", self.id);

end;

return TakeFlightClientAction;