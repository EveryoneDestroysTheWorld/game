--!strict
-- Programmer: Hati (hati_bati)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local LockOnClientAction = require(ReplicatedStorage.Client.Classes.Actions.LockOnClientAction);
local types = require(ServerStorage.Modules.types);

local lookAtTarget = require(ReplicatedStorage.Shared.Modules.lookAtTarget);
local searchForLockOnTarget = require(ReplicatedStorage.Shared.Modules.searchForLockOnTarget);
local createInventoryRemoteEvent = require(ServerStorage.Modules.createInventoryRemoteEvent);

local LockOnServerAction = {
	id = LockOnClientAction.id;
	name = LockOnClientAction.name;
	description = LockOnClientAction.description;
	__index = {
		name = LockOnClientAction.name;
		id = LockOnClientAction.id;
		description = LockOnClientAction.description;
		previousTargets = {};
	} :: types.LockOnServerAction;
};

function LockOnServerAction.new(properties: types.ServerActionConstructorProperties): types.LockOnServerAction

	local overwrittenProperties = {
		contestant = properties.contestant;
	};

  local action = (setmetatable(overwrittenProperties, LockOnServerAction) :: any) :: types.LockOnServerAction;

	local player = properties.contestant.player
	if player then

		local remoteEvent = createInventoryRemoteEvent(player, "Action", `{player.UserId}_{action.id}`);
		remoteEvent.OnServerEvent:Connect(function(possiblePlayer: Player, targetModelName: string?)
		
			assert(possiblePlayer == player)
			assert(not targetModelName or typeof(targetModelName) == "string");
			local target;

			if targetModelName then

				local possibleTarget = workspace:FindFirstChild(targetModelName);
				if possibleTarget and possibleTarget:IsA("Model") then

					target = possibleTarget;

				end;

			end;

			action.contestant.attributes.draconicKnightTargetModel = target;

		end);

		action.remoteEvent = remoteEvent;

	end;
	
	return action;

end;

function LockOnServerAction.__index:activate(shouldReleaseLock: boolean?)

	local character = self.contestant.character;
	assert(character);

	local target;

	if shouldReleaseLock then
		
		lookAtTarget(character)
		self.contestant.attributes.draconicKnightTargetModel = nil;

	else

		target = searchForLockOnTarget(character, self.previousTargets);
		lookAtTarget(character, target);

	end
	
	self.contestant.attributes.draconicKnightTargetModel = target;

end;

function LockOnServerAction.__index:breakdown()

	if self.remoteEvent then

		self.remoteEvent:Destroy();

	end;

end

return LockOnServerAction;