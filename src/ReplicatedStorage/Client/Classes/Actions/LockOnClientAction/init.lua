--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designers: Hati (hati_bati)
-- © 2024 – 2025 Beastslash LLC

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ContextActionService = game:GetService("ContextActionService");

local types = require(ReplicatedStorage.Client.Modules.types);

local lookAtTarget = require(ReplicatedStorage.Shared.Modules.lookAtTarget);
local searchForLockOnTarget = require(ReplicatedStorage.Shared.Modules.searchForLockOnTarget);

local LockOnClientAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
	iconImage = "rbxassetid://17771917538";
	name = "Lock On";
	description = "Lock on to enemies and friends";
	__index = {} :: types.LockOnClientAction;
};

function LockOnClientAction.new(): types.LockOnClientAction

	local overwrittenProperties = {
		id = LockOnClientAction.id;
		iconImage = LockOnClientAction.iconImage;
		name = LockOnClientAction.name;
		description = LockOnClientAction.description;
	};
	
  local action = (setmetatable(overwrittenProperties, LockOnClientAction) :: any) :: types.LockOnClientAction;
		
	local function checkButton(_, inputState: Enum.UserInputState)

		if inputState == Enum.UserInputState.Begin then

			action:activate();

		else

			action:activate(true);

		end

	end;

	local targetingGUI = ReplicatedStorage.Client:WaitForChild("InGameDisplayObjects"):WaitForChild("TargetingFrame"):Clone()
	targetingGUI.Parent = workspace;
	action.targetingGUI = targetingGUI;

	ContextActionService:BindActionAtPriority("LockOn", checkButton, false, 2, Enum.KeyCode.Tab);

	return action;

end

function LockOnClientAction.__index:activate(shouldReleaseLock: boolean?)

	local character = Players.LocalPlayer.Character;
	assert(character);

	if shouldReleaseLock then
		
		lookAtTarget(character)

	else

		local target = searchForLockOnTarget(character, self.previousTargets);
		lookAtTarget(character, target);

	end

end

function LockOnClientAction.__index:breakdown()

	self.targetingGUI:Destroy();

	ContextActionService:UnbindAction("LockOn");

end

return LockOnClientAction;