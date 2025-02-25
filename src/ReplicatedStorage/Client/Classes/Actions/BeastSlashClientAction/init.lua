--!strict
-- Programmer: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");

local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local ClientAction = require(ReplicatedStorage.Client.Interfaces.ClientAction);
type ClientAction = ClientAction.ClientAction;

local BeastSlashClientAction = {
	id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
	iconImage = "rbxassetid://17771917538";
	name = "Beast Slash";
	description = "Attack!!";
};

function BeastSlashClientAction.new(): ClientAction

	local player = Players.LocalPlayer;
	local remoteName = `{player.UserId}_{BeastSlashClientAction.id}`;
  local action: ClientAction = {
		id = BeastSlashClientAction.id;
		iconImage = BeastSlashClientAction.iconImage;
		name = BeastSlashClientAction.name;
		description = BeastSlashClientAction.description;
		remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
		attributes = {};
		activate = function(self: ClientAction)

			self.remoteFunction:InvokeServer();
		
		end;
		breakdown = function(self: ClientAction)

			ContextActionService:UnbindAction("ActivateMelee");
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
