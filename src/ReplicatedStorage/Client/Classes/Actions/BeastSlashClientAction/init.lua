--!strict
-- Programmer: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");

local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local types = require(ReplicatedStorage.Client.Modules.types);

local BeastSlashClientAction = {
	id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
	iconImage = "rbxassetid://17771917538";
	name = "Beast Slash";
	description = "Attack!!";
	__index = {} :: types.BeastSlashClientAction;
};

function BeastSlashClientAction.new(): types.BeastSlashClientAction

	local player = Players.LocalPlayer;
	local remoteName = `{player.UserId}_{BeastSlashClientAction.id}`;

	local overwrittenProperties = {
		id = BeastSlashClientAction.id;
		iconImage = BeastSlashClientAction.iconImage;
		name = BeastSlashClientAction.name;
		description = BeastSlashClientAction.description;
		remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
	}

  local action = (setmetatable(overwrittenProperties, BeastSlashClientAction) :: any) :: types.BeastSlashClientAction;

	HUDService:addHUDButton({
		type = "Action";
		key = action.id;
		onActivate = function()

			action:activate();

		end;
		shortcutCharacter = "1";
		iconImage = "rbxassetid://104334768004371";
	});

	local function checkJump(_, inputState: Enum.UserInputState)

		if inputState == Enum.UserInputState.Begin then

			action:activate();

		elseif inputState == Enum.UserInputState.End then

			action:activate();

		end

	end;

	ContextActionService:BindActionAtPriority("ActivateMelee", checkJump, false, 2, Enum.UserInputType.MouseButton1);

	return action;

end

function BeastSlashClientAction.__index:activate()

	self.remoteFunction:InvokeServer();

end

function BeastSlashClientAction.__index:breakdown()

	ContextActionService:UnbindAction("ActivateMelee");
	HUDService:removeHUDButton("Action", self.id);

end

return BeastSlashClientAction;
