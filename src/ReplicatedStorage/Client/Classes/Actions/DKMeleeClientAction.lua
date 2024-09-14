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
type ClientAction = ClientAction.ClientAction;

local MeleeAction = {
	ID = 8;
	iconImage = "rbxassetid://17771917538";
	name = "Beast Slash";
	description = "Attack!!";
};

function MeleeAction.new(): ClientAction

	local player = Players.LocalPlayer;
	local remoteName: string;

	local function breakdown(self: ClientAction)

		ContextActionService:UnbindAction("ActivateMelee");
		ReplicatedStorage.Client.Functions.DestroyHUDButton:Invoke("Action", self.ID);

	end;

	local function activate(self: ClientAction)

		ReplicatedStorage.Shared.Functions.ActionFunctions:FindFirstChild(remoteName):InvokeServer();

	end;

	local function initialize(self: ClientAction)

		local allowedToToggle = true
		ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Action", React.createElement(HUDButton, {
			type = "Action";
			onActivate = function()

				self:activate("Input");

			end;
			shortcutCharacter = "1";
			iconImage = "rbxassetid://17771917538";
		}));

		remoteName = `{player.UserId}_{self.ID}`;
		local debounce = false
		local function checkJump(_, inputState: Enum.UserInputState)
			if inputState == Enum.UserInputState.Begin then

				self:activate();

			elseif inputState == Enum.UserInputState.End then
				self:activate();
			end
		end;

		ContextActionService:BindActionAtPriority("ActivateMelee", checkJump, false, 2, Enum.UserInputType.MouseButton1);

	end;

	return ClientAction.new({
		ID = MeleeAction.ID;
		iconImage = MeleeAction.iconImage;
		name = MeleeAction.name;
		description = MeleeAction.description;
		activate = activate;
		breakdown = breakdown;
		initialize = initialize;
	});

end

return MeleeAction;