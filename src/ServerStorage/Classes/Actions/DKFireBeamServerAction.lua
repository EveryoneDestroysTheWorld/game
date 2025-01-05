--!strict
-- Programmer: Hati (hati_bati)
-- Designer: Christian Toney (Christian_Toney)
-- 
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService")
local ServerContestant = require(script.Parent.Parent.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerAction = require(script.Parent.Parent.ServerAction);
type ServerAction = ServerAction.ServerAction;
local FireBeamClientAction = require(ReplicatedStorage.Client.Classes.Actions.DKFireBeamClientAction);
local ServerRound = require(script.Parent.Parent.ServerRound);
type ServerRound = ServerRound.ServerRound;
local ServerStorage = game:GetService("ServerStorage");
local displayObjects = ReplicatedStorage.Client.InGameDisplayObjects

local FireBeamServerAction = {
	id = FireBeamClientAction.id;
	name = FireBeamClientAction.name;
	description = FireBeamClientAction.description;
};


function FireBeamServerAction.new(): ServerAction

	local _contestant;
	local _round;

	local function activate(self: ServerAction)
		
	end;

	local executeActionRemoteFunction: RemoteFunction? = nil;

	local function breakdown()

		if executeActionRemoteFunction then

			executeActionRemoteFunction:Destroy();

		end

	end;

	local function initialize(self: ServerAction, newContestant: ServerContestant, newRound: ServerRound)
		
		_contestant = newContestant;
		_round = newRound;

		assert(_contestant.character);
		if _contestant.player then

			local remoteFunction = Instance.new("RemoteFunction");
			remoteFunction.Name = `{_contestant.player.UserId}_{self.id}`;
			remoteFunction.OnServerInvoke = function(player)

				if player == _contestant.player then

					self:activate();

				else

					-- That's weird.
					error("Unauthorized.");

				end

			end;
			remoteFunction.Parent = ReplicatedStorage.Shared.Functions.ActionFunctions;
			executeActionRemoteFunction = remoteFunction;

		end

	end;

	return ServerAction.new({
		name = FireBeamServerAction.name;
		id = FireBeamServerAction.id;
		description = FireBeamServerAction.description;
		breakdown = breakdown;
		activate = activate;
		initialize = initialize;
	});

end;

return FireBeamServerAction;