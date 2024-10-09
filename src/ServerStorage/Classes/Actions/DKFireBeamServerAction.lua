--!strict
-- Programmer: Hati (hati_bati)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 Beastslash LLC

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
	ID = FireBeamClientAction.ID;
	name = FireBeamClientAction.name;
	description = FireBeamClientAction.description;
};


function FireBeamServerAction.new(): ServerAction

	local function activate(self: ServerAction)
		
	end;

	local executeActionRemoteFunction: RemoteFunction? = nil;

	local function breakdown()

		if executeActionRemoteFunction then

			executeActionRemoteFunction:Destroy();

		end

	end;

	local function initialize(self: ServerAction, newContestant: ServerContestant, newRound: ServerRound)
		contestant = newContestant;
		round = newRound;

		assert(contestant.character);
		local humanoid = contestant.character:FindFirstChild("Humanoid") :: Humanoid;
		if contestant.player then

			local remoteFunction = Instance.new("RemoteFunction");
			remoteFunction.Name = `{contestant.player.UserId}_{self.ID}`;
			remoteFunction.OnServerInvoke = function(player)

				if player == contestant.player then

					self:activate();

				else

					-- That's weird.
					error("Unauthorized.");

				end

			end;
			remoteFunction.Parent = ReplicatedStorage.Shared.Functions.ActionFunctions;
			executeActionRemoteFunction = remoteFunction;

		end

		_humanoid = humanoid;
		contestant = contestant;

	end;

	return ServerAction.new({
		name = FireBeamServerAction.name;
		ID = FireBeamServerAction.ID;
		description = FireBeamServerAction.description;
		breakdown = breakdown;
		activate = activate;
		initialize = initialize;
	});

end;

return FireBeamServerAction;