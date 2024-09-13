--!strict
-- Writer: Hati ---- Heavily modified edit of ExplosivePunch
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");
local InsertService = game:GetService("InsertService")
local ClientAction = require(script.Parent.Parent.ClientAction);
local React = require(ReplicatedStorage.Shared.Packages.react);
local ActionButton = require(script.Parent.Parent.Parent.ReactComponents.ActionButton);
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

	end;

	local function activate(self: ClientAction)
		ReplicatedStorage.Shared.Functions.ActionFunctions:FindFirstChild(remoteName):InvokeServer();
	end;

	local action = ClientAction.new({
		ID = MeleeAction.ID;
		iconImage = MeleeAction.iconImage;
		name = MeleeAction.name;
		description = MeleeAction.description;
		activate = activate;
		breakdown = breakdown;
	});
	local allowedToToggle = true
	ReplicatedStorage.Client.Functions.AddActionButton:Invoke(React.createElement(ActionButton, {
		onActivate = function()
			action:activate("Input");
		end;
		shortcutCharacter = "1";
		iconImage = "rbxassetid://17771917538";
	}));

	remoteName = `{player.UserId}_{action.ID}`;
	local debounce = false
	local function checkJump(_, inputState: Enum.UserInputState)
		if inputState == Enum.UserInputState.Begin then
			action:activate();
		elseif inputState == Enum.UserInputState.End then

		end
	end;

	ContextActionService:BindActionAtPriority("ActivateMelee", checkJump, false, 2, Enum.UserInputType.MouseButton1);

	return action;

end

return MeleeAction;