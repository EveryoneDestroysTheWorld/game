--!strict
-- Programmer: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");

local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local SharedTypes = require(ReplicatedStorage.Client.Modules.SharedTypes);

local activate = require(script.activate);
local breakdown = require(script.breakdown);

local BeastSlashClientAction = {
	id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
	iconImage = "rbxassetid://17771917538";
	name = "Beast Slash";
	description = "Attack!!";
};

function BeastSlashClientAction.new(): SharedTypes.BeastSlashClientAction

	local player = Players.LocalPlayer;
	local remoteName = `{player.UserId}_{BeastSlashClientAction.id}`;
  local action: SharedTypes.BeastSlashClientAction = {
		id = BeastSlashClientAction.id;
		iconImage = BeastSlashClientAction.iconImage;
		name = BeastSlashClientAction.name;
		description = BeastSlashClientAction.description;
		remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
		attributes = {};
		activate = activate;
		breakdown = breakdown;
	};

	HUDService:addHUDButton({
		type = "Action";
		key = action.id;
		onActivate = function()

			action:activate();

		end;
		shortcutCharacter = "1";
		iconImage = "rbxassetid://104334768004371";
	});

	local function checkInput(_, inputState: Enum.UserInputState)

		if inputState == Enum.UserInputState.Begin then

			action:activate();

		elseif inputState == Enum.UserInputState.End then

			action:activate();

		end

	end;

	ContextActionService:BindActionAtPriority("ActivateMelee", checkInput, false, 2, Enum.UserInputType.MouseButton1);

	return action;

end

return BeastSlashClientAction;
