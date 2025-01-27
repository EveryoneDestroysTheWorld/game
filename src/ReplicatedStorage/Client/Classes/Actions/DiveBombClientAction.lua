--!strict
-- Programmer: Hati (hati_bati)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");

local ClientAction = require(script.Parent.Parent.ClientAction);
local React = require(ReplicatedStorage.Shared.Packages.react);
local HUDButton = require(ReplicatedStorage.Client.ReactComponents.HUDButton);
local targetingFramework = require(script.Parent.Framework.EasyTargetingFramework);

type ClientAction = ClientAction.ClientAction;

local DiveBombAction = {
	id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
	iconImage = "rbxassetid://17771917538";
	name = "Dive Bomb";
	description = "Rush to target location, stunning enemies in an area and dealing damage to EVERYONE nearby.";
};

function DiveBombAction.new(): ClientAction

	local player: Player;
	local remoteName: string;

	local function breakdown(self: ClientAction)

		ContextActionService:UnbindAction("ActivateDiveBomb");
		ReplicatedStorage.Client.Functions.DestroyHUDButton:Invoke("Action", self.id);

	end;

	local function activate(self: ClientAction)
    
		local coordinates, shouldUseTarget = targetingFramework:getData()
		ReplicatedStorage.Shared.Functions.ActionFunctions:FindFirstChild(remoteName):InvokeServer(coordinates, shouldUseTarget);

	end;

	local function initialize(self: ClientAction)

		ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Action", React.createElement(HUDButton, {
			type = "Action";
      key = self.id;
			onActivate = function()

				self:activate();

			end;
			shortcutCharacter = "1";
			iconImage = "rbxassetid://17771917538";
		}));

		player = Players.LocalPlayer;
		remoteName = `{player.UserId}_{self.id}`;

		local function checkJump(_, inputState: Enum.UserInputState)

			if inputState == Enum.UserInputState.Begin then
				
				targetingFramework.displayTarget("Start")

			elseif inputState == Enum.UserInputState.End then

				targetingFramework.displayTarget("Release")
				self:activate();

			end

		end;

		ContextActionService:BindActionAtPriority("ActivateDiveBomb", checkJump, false, 2, Enum.KeyCode.Q);

	end;

	return ClientAction.new({
		id = DiveBombAction.id;
		iconImage = DiveBombAction.iconImage;
		name = DiveBombAction.name;
		description = DiveBombAction.description;
		activate = activate;
		breakdown = breakdown;
		initialize = initialize;
	});

end

return DiveBombAction;