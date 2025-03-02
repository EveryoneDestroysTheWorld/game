--!strict
-- Programmer: Hati (hati_bati)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local LockOnClientAction = require(ReplicatedStorage.Client.Classes.Actions.LockOnClientAction);
local ILockOnServerAction = require(ServerStorage.Interfaces.ILockOnServerAction);
local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);
local IServerRound = require(ServerStorage.Interfaces.IServerRound);

local lookAtTarget = require(ReplicatedStorage.Shared.Modules.lookAtTarget);
local searchForLockOnTarget = require(ReplicatedStorage.Shared.Modules.searchForLockOnTarget);
local createInventoryRemoteEvent = require(ServerStorage.Modules.createInventoryRemoteEvent);

type ILockOnServerAction = ILockOnServerAction.ILockOnServerAction;
type IServerContestant = IServerContestant.IServerContestant;
type IServerRound = IServerRound.IServerRound;

local LockOnServerAction = {
	id = LockOnClientAction.id;
	name = LockOnClientAction.name;
	description = LockOnClientAction.description;
};

function LockOnServerAction.new(contestant: IServerContestant, round: IServerRound): ILockOnServerAction

	local previousTargets = {};

	local function activate(self: ILockOnServerAction, shouldReleaseLock: boolean?)

		local character = contestant.character;
		assert(character);

		local target;

		if shouldReleaseLock then
			
			lookAtTarget(character)
			contestant.attributes.draconicKnightTargetModel = nil;

		else

			target = searchForLockOnTarget(character, previousTargets);
			lookAtTarget(character, target);

		end
		
		contestant.attributes.draconicKnightTargetModel = target;

	end;

	local function breakdown(self: ILockOnServerAction)

		if self.remoteEvent then

			self.remoteEvent:Destroy();
	
		end;
	
		if contestant.player then
	
			ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(contestant.player, self.id);
	
		end;

	end;

  local action: ILockOnServerAction = {
		attributes = {};
		contestantID = contestant.id;
		description = LockOnServerAction.description;
		id = LockOnServerAction.id;
		name = LockOnServerAction.name;
		activate = activate;
		breakdown = breakdown;
	}

	local player = contestant.player
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

			print("target changed")
			contestant.attributes.draconicKnightTargetModel = target;

		end);

		action.remoteEvent = remoteEvent;
		
		ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

	end;
	
	return action;

end;

return LockOnServerAction;