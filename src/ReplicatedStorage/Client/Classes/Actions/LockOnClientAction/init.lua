--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designers: Hati (hati_bati)
-- © 2024 – 2025 Beastslash LLC

-- TODO: Convert this into a module. A dedicated action is unnecessary

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ContextActionService = game:GetService("ContextActionService");

local SharedTypes = require(ReplicatedStorage.Client.Modules.SharedTypes);

local lookAtTarget = require(ReplicatedStorage.Shared.Modules.lookAtTarget);
local searchForLockOnTarget = require(ReplicatedStorage.Shared.Modules.searchForLockOnTarget);

local LockOnClientAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
	iconImage = "rbxassetid://17771917538";
	name = "Lock On";
	description = "Lock on to enemies and friends";
};

function LockOnClientAction.new(): SharedTypes.LockOnClientAction

	local action: SharedTypes.LockOnClientAction = {
		id = LockOnClientAction.id;
		iconImage = LockOnClientAction.iconImage;
		name = LockOnClientAction.name;
		description = LockOnClientAction.description;
		attributes = {
			previousTargets = {};
			targetingGUI = ReplicatedStorage.Shared:WaitForChild("InGameDisplayObjects"):WaitForChild("TargetingFrameGUI"):Clone();
			shouldLock = false;
		};
		remoteFunction = Instance.new("RemoteFunction"); -- temporary fix
		activate = function(self: SharedTypes.LockOnClientAction)

			local shouldReleaseLock = false;
			local character = Players.LocalPlayer.Character;
			assert(character);
		
			if shouldReleaseLock then
				
				lookAtTarget(character)
		
			else
		
				local target = searchForLockOnTarget(character, self.attributes.previousTargets);
				lookAtTarget(character, target);
		
			end
		
		end;
		breakdown = function(self: SharedTypes.LockOnClientAction)

			self.attributes.targetingGUI:Destroy();
		
			ContextActionService:UnbindAction("LockOn");
		
		end;
	};
		
	local function checkButton(_, inputState: Enum.UserInputState)

		if inputState == Enum.UserInputState.Begin then

			action.attributes.shouldLock = true;
			action:activate();

		elseif inputState == Enum.UserInputState.End then

			action.attributes.shouldLock = false;
			action:activate();

		end

	end;

	action.attributes.targetingGUI.Parent = workspace;

	ContextActionService:BindActionAtPriority("LockOn", checkButton, false, 2, Enum.KeyCode.Tab);

	return action;

end

return LockOnClientAction;