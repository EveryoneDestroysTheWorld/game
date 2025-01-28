--!strict
-- Programmer: Hati (hati_bati)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local LockOnClientAction = require(ReplicatedStorage.Client.Classes.Actions.LockOnClientAction);
local ServerAction = require(script.Parent.Parent.ServerAction);
local types = require(ServerStorage.Classes.types);

local LockOnServerAction = {
	id = LockOnClientAction.id;
	name = LockOnClientAction.name;
	description = LockOnClientAction.description;
	__index = {} :: types.LockOnServerAction;
};

local function getDataFromClient(player: Player): Vector3

	local event = Instance.new("RemoteEvent")
	local connect
	connect = event.OnServerEvent:Connect(function(_: Player, data: Instance)
		connect:Disconnect();
		if data then
			event:SetAttribute("Target", data.Name);
			local targetValue = player.Character:FindFirstChild("Target") or Instance.new("ObjectValue", player.Character)
			targetValue.Name = "Target"
			targetValue.Value = data
		else
			event:SetAttribute("Target", "nil");
			local targetValue = player.Character:FindFirstChild("Target") or Instance.new("ObjectValue", player.Character)
			targetValue.Name = "Target"
			targetValue.Value = nil
		end
	end)

	event.Name = "LockOnData"
	event.Parent = player

	--coords request sent to player
	event.AttributeChanged:Wait()

	--coords recieved by player
	return 

end

function LockOnServerAction.new(): types.LockOnServerAction

	local function initialize(self: types.ServerAction, newContestant: types.ServerContestant, newRound: types.ServerRound)
		
		contestant = newContestant;
		round = newRound;

		assert(contestant.character);
		local humanoid = contestant.character:FindFirstChild("Humanoid") :: Humanoid;
		if contestant.player then

			local remoteFunction = Instance.new("RemoteFunction");
			remoteFunction.Name = `{contestant.player.UserId}_{self.ID}`;
			remoteFunction.OnServerInvoke = function(player)

				if player == contestant.player then
					
					local target = getDataFromClient(player)

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
		name = LockOnServerAction.name;
		id = LockOnServerAction.id;
		description = LockOnServerAction.description;
		breakdown = breakdown;
		activate = activate;
		initialize = initialize;
	});

end;

function LockOnServerAction.__index:breakdown()

	if executeActionRemoteFunction then

		executeActionRemoteFunction:Destroy();

	end

end

return LockOnServerAction;