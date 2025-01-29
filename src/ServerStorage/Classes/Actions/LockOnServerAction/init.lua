--!strict
-- Programmer: Hati (hati_bati)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local LockOnClientAction = require(ReplicatedStorage.Client.Classes.Actions.LockOnClientAction);
local types = require(ServerStorage.Modules.types);

local lookAtTarget = require(ReplicatedStorage.Shared.Modules.lookAtTarget);
local searchForLockOnTarget = require(ReplicatedStorage.Shared.Modules.searchForLockOnTarget);

local LockOnServerAction = {
	id = LockOnClientAction.id;
	name = LockOnClientAction.name;
	description = LockOnClientAction.description;
	__index = {} :: types.LockOnServerAction;
};

function LockOnServerAction.new(properties: types.ServerActionConstructorProperties): types.LockOnServerAction

	local overwrittenProperties = {
		name = LockOnServerAction.name;
		id = LockOnServerAction.id;
		description = LockOnServerAction.description;
		previousTargets = {};
	};

  local action = (setmetatable(overwrittenProperties, LockOnServerAction) :: any) :: types.LockOnServerAction;
	
	return action;

end;

function LockOnServerAction.__index:activate(shouldReleaseLock: boolean?)

	local character = self.contestant.character;
	assert(character);

	if shouldReleaseLock then
		
		lookAtTarget(character)

	else

		local target = searchForLockOnTarget(character, self.previousTargets);
		lookAtTarget(character, target);

	end

end;

function LockOnServerAction.__index:breakdown()

	-- There's nothing to break down.

end

return LockOnServerAction;